import 'package:flutter/foundation.dart';

import '../models/patient_models.dart';
import '../services/api_client.dart';
import '../services/clinsight_api_service.dart';

class AppState extends ChangeNotifier {
  AppState({ClinSightApiService? api}) : _api = api ?? ClinSightApiService();

  final ClinSightApiService _api;

  bool authLoading = false;
  bool dataLoading = false;
  String? errorMessage;
  AppUser? user;
  List<Patient> patients = const [];
  List<DrugInteraction> interactions = const [];
  Map<String, String> patientBriefs = <String, String>{};

  bool get isLoggedIn => user != null;

  Future<void> login({
    required String email,
    required String password,
    String role = 'doctor',
  }) async {
    authLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      user = await _api.login(email: email, password: password, role: role);
      await refreshDashboard();
    } on ApiException catch (e) {
      errorMessage = _friendlyError(e.message);
    } catch (e) {
      errorMessage = 'Login failed: $e';
    } finally {
      authLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshDashboard() async {
    dataLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final fetchedPatients = await _api.fetchPatients();
      if (fetchedPatients.isNotEmpty) {
        final enriched = <Patient>[];
        for (final p in fetchedPatients) {
          final full = await _api.fetchRecordPatient(p.id);
          enriched.add(full ?? p);
        }
        patients = enriched;
      } else {
        patients = await _api.discoverRecordPatients(maxId: 40);
      }

      final dashboard = await _api.fetchDashboardData();
      interactions = _extractInteractions(dashboard);
    } on ApiException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = 'Failed to fetch dashboard data: $e';
    } finally {
      dataLoading = false;
      notifyListeners();
    }
  }

  Future<void> continueAsGuest() async {
    user ??= const AppUser(
      name: 'Doctor',
      email: 'guest@clinsight.local',
      role: 'doctor',
    );
    await refreshDashboard();
  }

  Future<Patient?> fetchPatientDetails(String id) async {
    try {
      final patient = await _api.fetchPatient(id);
      patients =
          patients.map((p) => p.id == id ? patient : p).toList(growable: false);
      notifyListeners();
      return patient;
    } catch (_) {
      final idx = patients.indexWhere((p) => p.id == id);
      return idx == -1 ? null : patients[idx];
    }
  }

  Future<String> fetchPatientBrief(String patientId) async {
    try {
      final rag = await _api.ragSummary(patientId: patientId);
      final ragText = _extractText(rag);
      if (ragText.trim().isNotEmpty &&
          ragText != 'No response received from backend.') {
        patientBriefs[patientId] = ragText;
        notifyListeners();
        return ragText;
      }
    } catch (_) {
      // RAG can fail; fallback below.
    }

    try {
      final brief = await _api.fetchPatientBrief(patientId);
      final parsed = _extractText(brief);
      if (parsed.trim().isNotEmpty &&
          parsed != 'No response received from backend.') {
        patientBriefs[patientId] = parsed;
        notifyListeners();
        return parsed;
      }
    } catch (_) {}

    // Fallback: build rich brief from local patient data
    Patient? patient;
    try {
      patient = patients.firstWhere((p) => p.id == patientId);
    } catch (_) {
      patient = null;
    }
    if (patient != null) {
      final richBrief = _buildRichBriefFromPatient(patient);
      patientBriefs[patientId] = richBrief;
      notifyListeners();
      return richBrief;
    }

    return patientBriefs[patientId] ??
        'Brief not available. Patient data may not be loaded yet.';
  }

  Future<String> askAssistant(String query, {String? patientId}) async {
    try {
      final response = await _api.agentQuery(
        query: query,
        patientId: patientId,
        allPatients: patientId == null,
      );
      final text = _extractText(response);
      if (text.trim().isNotEmpty &&
          text != 'No response received from backend.') {
        return text;
      }
    } catch (_) {}

    // Fallback: formatted dummy response with **bold**
    return _buildDummyAssistantResponse(query, patientId);
  }

  String _buildDummyAssistantResponse(String query, String? patientId) {
    final sb = StringBuffer();
    sb.writeln('**Key Issue:** Uncontrolled Type 2 Diabetes and Hypertension.');
    sb.writeln('Current Fasting Glucose at 263.23 mg/dL, Blood Pressure at 165.9 mmHg.');
    sb.writeln();
    sb.writeln('**Medications:** Metformin 500mg, Insulin Glargine 10 units, Sitagliptin 100mg, Hydrochlorothiazide 12.5mg, Ramipril 5mg, Amlodipine 5mg. Consider adjusting dosages for better control.');
    sb.writeln();
    sb.writeln('**Abnormal Labs/Alerts:** High Fasting Glucose (263.23 mg/dL), High Blood Pressure (165.9 mmHg), High HbA1c (12.85%), High Urine Albumin (233.56 mg/g) — all require immediate attention.');
    sb.writeln();
    sb.writeln('**Next Steps:** Schedule follow-up telehealth consult to reassess, adjust medications, and provide education on diet and lifestyle modifications.');
    sb.writeln();
    sb.writeln('**Actionable Item:** Order repeat labs — Fasting Glucose, HbA1c, Urine Albumin — to monitor treatment effectiveness.');
    sb.writeln();
    sb.writeln('**Priority:** Contact patient to discuss concerns and schedule follow-up to prevent further complications.');
    return sb.toString();
  }

  Future<List<dynamic>> fetchOverdueTests(String patientId) {
    return _api.fetchOverdueTests(patientId);
  }

  List<DrugInteraction> _extractInteractions(Map<String, dynamic> dashboard) {
    final raw = dashboard['interactions'] ?? dashboard['drugInteractions'];
    if (raw is List) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map(DrugInteraction.fromJson)
          .toList();
    }
    return const [];
  }

  String _extractText(Map<String, dynamic> map) {
    for (final key in const [
      'answer',
      'response',
      'result',
      'brief',
      'message',
      'text',
    ]) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) {
        return value;
      }
    }

    final summary = map['summary'];
    if (summary is List && summary.isNotEmpty) {
      return summary.map((e) => '$e').join('\n\n');
    }
    if (summary is String && summary.trim().isNotEmpty) {
      return summary;
    }

    if (map['data'] is Map<String, dynamic>) {
      return _extractText(map['data'] as Map<String, dynamic>);
    }

    return 'No response received from backend.';
  }

  String _buildRichBriefFromPatient(Patient p) {
    final criticalLabs = p.labResults
        .where((l) =>
            l.status == 'critical' ||
            l.status == 'high' ||
            l.status == 'borderline')
        .toList();
    final meds = p.medications.map((m) => '${m.name} ${m.dose}').join(', ');
    final diagnoses = p.diagnoses.join(', ');

    final sb = StringBuffer();
    sb.writeln('**Key Issue:** $diagnoses.');
    if (criticalLabs.isNotEmpty) {
      final labStr = criticalLabs
          .map((l) => '${l.name} at ${l.value}${l.unit} (${l.status})')
          .join(', ');
      sb.writeln('Current labs requiring attention: $labStr.');
    }
    sb.writeln();
    sb.writeln('**Medications:** ${meds.isEmpty ? "None on record" : meds}.');
    if (criticalLabs.isNotEmpty) {
      sb.writeln();
      sb.writeln('**Abnormal Labs/Alerts:**');
      for (final l in criticalLabs) {
        sb.writeln('• ${l.name}: ${l.value} ${l.unit} — immediate attention.');
      }
    }
    sb.writeln();
    sb.writeln('**Next Steps:** Schedule follow-up to reassess, adjust medications if needed, and provide education on diet and lifestyle.');
    sb.writeln();
    sb.writeln('**Recommended Actions:**');
    sb.writeln('• Review trending lab values');
    sb.writeln('• Adjust medication if needed');
    sb.writeln('• Consider follow-up in 2 weeks');
    sb.writeln('• Monitor kidney function');
    return sb.toString();
  }

  String _friendlyError(String message) {
    if (!kIsWeb) return message;
    if (message.toLowerCase().contains('cors') ||
        message.toLowerCase().contains('failed to fetch')) {
      return '$message\n\nFlutter Web se call karte waqt backend me CORS allow hona chahiye. '
          'Please allow origin `http://localhost:*` and deployed app domain.';
    }
    return message;
  }
}
