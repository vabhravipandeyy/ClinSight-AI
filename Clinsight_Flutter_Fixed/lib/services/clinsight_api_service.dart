import '../models/patient_models.dart';
import 'api_client.dart';

class ClinSightApiService {
  ClinSightApiService({ApiClient? client})
      : _client = client ?? ApiClient(baseUrl: _defaultBaseUrl);

  static const String _defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:4000',
  );

  final ApiClient _client;

  Future<AppUser> login({
    required String email,
    required String password,
    required String role,
  }) async {
    // Hardcoded dummy doctor account
    if (email == 'nandakumar@kathir.in' &&
        password == 'doctor123' &&
        role.toLowerCase() == 'doctor') {
      return const AppUser(
        name: 'Dr. Nandakumar',
        email: 'nandakumar@kathir.in',
        role: 'doctor',
      );
    }

    // Try real backend if available, otherwise fall back to dummy user
    try {
      final res = await _client.post('/api/auth/login', body: {
        'email': email,
        'password': password,
        'role': role,
      });
      final map = _asMap(res);
      return AppUser.fromJson(
        _asMap(map['user']),
        roleFallback: '${map['role'] ?? role}',
      );
    } catch (_) {
      return AppUser(
        name: 'Doctor',
        email: email,
        role: role,
      );
    }
  }

  Future<AppUser> register({
    required String role,
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await _client.post('/api/auth/register', body: {
      'role': role,
      'name': name,
      'email': email,
      'password': password,
    });
    final map = _asMap(res);
    return AppUser.fromJson(
      _asMap(map['user']),
      roleFallback: '${map['role'] ?? role}',
    );
  }

  Future<List<Patient>> fetchPatients() async {
    final res = await _client.get('/api/patients');
    final items = _asList(res);
    return items
        .whereType<Map<String, dynamic>>()
        .map(Patient.fromJson)
        .toList();
  }

  Future<Map<String, dynamic>> fetchDashboardData() async {
    final res = await _client.get('/api/dashboard/data');
    return _asMap(res);
  }

  Future<Patient> fetchPatient(String id) async {
    try {
      final res = await _client.get('/api/patient/$id');
      return Patient.fromJson(_asMap(res));
    } catch (_) {
      final record = await fetchRecordPatient(id);
      if (record == null) {
        rethrow;
      }
      return record;
    }
  }

  Future<Map<String, dynamic>> fetchPatientBrief(String id) async {
    try {
      final res = await _client.get('/api/patient/$id/brief');
      return _asMap(res);
    } catch (_) {
      return fetchRecordBrief(id);
    }
  }

  Future<Map<String, dynamic>> fetchPatientLabTrend(
    String id,
    String testName,
  ) async {
    final res = await _client.get('/api/patient/$id/labs/$testName');
    return _asMap(res);
  }

  Future<List<dynamic>> fetchPatientFlags(String id) async {
    final res = await _client.get('/api/patient/$id/flags');
    return _asList(res);
  }

  Future<List<dynamic>> fetchOverdueTests(String id) async {
    try {
      final res = await _client.get('/api/patient/$id/overdue-tests');
      return _asList(res);
    } catch (_) {
      return fetchRecordOverdueTests(id);
    }
  }

  Future<Map<String, dynamic>> searchPatientHistory(
    String id,
    String query,
  ) async {
    final res =
        await _client.post('/api/patient/$id/search', body: {'query': query});
    return _asMap(res);
  }

  Future<Map<String, dynamic>> fetchRecord(String id) async {
    final res = await _client.get('/api/records/$id');
    return _asMap(res);
  }

  Future<Map<String, dynamic>> fetchRecordBrief(String id) async {
    final res = await _client.get('/api/records/$id/brief');
    return _asMap(res);
  }

  Future<List<dynamic>> fetchRecordLabs(String id) async {
    final res = await _client.get('/api/records/$id/labs');
    return _asList(res);
  }

  Future<List<dynamic>> fetchRecordFlags(String id) async {
    final res = await _client.get('/api/records/$id/flags');
    return _asList(res);
  }

  Future<List<dynamic>> fetchRecordOverdueTests(String id) async {
    final res = await _client.get('/api/records/$id/overdue-tests');
    return _asList(res);
  }

  Future<Patient?> fetchRecordPatient(String id) async {
    try {
      final record = await fetchRecord(id);
      if (record.isEmpty) return null;
      final labs = await fetchRecordLabs(id);
      final flags = await fetchRecordFlags(id);
      return _recordToPatient(record, labs: labs, flags: flags);
    } catch (_) {
      return null;
    }
  }

  Future<List<Patient>> discoverRecordPatients({int maxId = 30}) async {
    final patients = <Patient>[];
    int misses = 0;
    for (int i = 1; i <= maxId; i++) {
      final id = 'P${i.toString().padLeft(3, '0')}';
      final patient = await fetchRecordPatient(id);
      if (patient != null) {
        patients.add(patient);
        misses = 0;
      } else {
        misses++;
      }
      if (misses >= 10 && patients.isNotEmpty) {
        break;
      }
    }
    return patients;
  }

  Future<Map<String, dynamic>> searchRecords({
    required String patientId,
    required String query,
  }) async {
    final res = await _client.post('/api/records/search', body: {
      'patientId': patientId,
      'query': query,
    });
    return _asMap(res);
  }

  Future<Map<String, dynamic>> checkDrugs({
    required List<String> medications,
    String? patientId,
  }) async {
    final res = await _client.post('/api/drugs/check', body: {
      'medications': medications,
      if (patientId != null && patientId.isNotEmpty) 'patientId': patientId,
    });
    return _asMap(res);
  }

  Future<Map<String, dynamic>> fetchPharmacyLinks(String medicineName) async {
    final res = await _client.get('/api/pharmacy/$medicineName');
    return _asMap(res);
  }

  Future<Map<String, dynamic>> agentQuery({
    String? patientId,
    String? query,
    String? prompt,
    String? apiKey,
    String? model,
    bool? allPatients,
  }) async {
    final res = await _client.post('/api/agent/query', body: {
      if (patientId != null) 'patientId': patientId,
      if (query != null) 'query': query,
      if (prompt != null) 'prompt': prompt,
      if (apiKey != null) 'apiKey': apiKey,
      if (model != null) 'model': model,
      if (allPatients != null) 'allPatients': allPatients,
    });
    return _asMap(res);
  }

  Future<Map<String, dynamic>> ragSummary({
    required String patientId,
    String? apiKey,
    String? model,
  }) async {
    final res = await _client.post('/api/agent/rag-summary', body: {
      'patientId': patientId,
      if (apiKey != null) 'apiKey': apiKey,
      if (model != null) 'model': model,
    });
    return _asMap(res);
  }

  Future<Map<String, dynamic>> ragQuery({
    required String patientId,
    required String query,
    String? apiKey,
    String? model,
  }) async {
    final res = await _client.post('/api/agent/rag-query', body: {
      'patientId': patientId,
      'query': query,
      if (apiKey != null) 'apiKey': apiKey,
      if (model != null) 'model': model,
    });
    return _asMap(res);
  }

  Future<Map<String, dynamic>> secondOpinion({
    required String patientId,
    required String proposedDiagnosis,
    String? apiKey,
    String? model,
  }) async {
    final res = await _client.post('/api/agent/second-opinion', body: {
      'patientId': patientId,
      'proposedDiagnosis': proposedDiagnosis,
      if (apiKey != null) 'apiKey': apiKey,
      if (model != null) 'model': model,
    });
    return _asMap(res);
  }

  Future<Map<String, dynamic>> triage({
    required String patientId,
    String? apiKey,
  }) async {
    final res = await _client.post('/api/agent/triage', body: {
      'patientId': patientId,
      if (apiKey != null) 'apiKey': apiKey,
    });
    return _asMap(res);
  }

  Future<Map<String, dynamic>> receptionist({
    required String message,
    List<Map<String, dynamic>>? history,
    String? apiKey,
  }) async {
    final res = await _client.post('/api/agent/receptionist', body: {
      'message': message,
      if (history != null) 'history': history,
      if (apiKey != null) 'apiKey': apiKey,
    });
    return _asMap(res);
  }

  Future<Map<String, dynamic>> nutrition({
    String? foodDescription,
    String? patientId,
    String? apiKey,
  }) async {
    final res = await _client.post('/api/agent/nutrition', body: {
      if (foodDescription != null) 'foodDescription': foodDescription,
      if (patientId != null) 'patientId': patientId,
      if (apiKey != null) 'apiKey': apiKey,
    });
    return _asMap(res);
  }

  Future<Map<String, dynamic>> ingest({
    required String patientId,
    required Map<String, dynamic> structuredOCRData,
  }) async {
    final res = await _client.post('/api/agent/ingest', body: {
      'patientId': patientId,
      'structuredOCRData': structuredOCRData,
    });
    return _asMap(res);
  }

  Future<Map<String, dynamic>> transfer({
    required String patientId,
    required String fromDoctor,
    required String toSpecialty,
    String? reason,
    bool? includeAnalysis,
    String? analysisQuery,
    String? apiKey,
    String? model,
  }) async {
    final res = await _client.post('/api/agent/transfer', body: {
      'patientId': patientId,
      'fromDoctor': fromDoctor,
      'toSpecialty': toSpecialty,
      if (reason != null) 'reason': reason,
      if (includeAnalysis != null) 'includeAnalysis': includeAnalysis,
      if (analysisQuery != null) 'analysisQuery': analysisQuery,
      if (apiKey != null) 'apiKey': apiKey,
      if (model != null) 'model': model,
    });
    return _asMap(res);
  }

  Future<Map<String, dynamic>> referral({
    required String patientId,
    required String fromDoctor,
    required String toSpecialty,
    String? reason,
    String? apiKey,
    String? model,
  }) async {
    final res = await _client.post('/api/referral', body: {
      'patientId': patientId,
      'fromDoctor': fromDoctor,
      'toSpecialty': toSpecialty,
      if (reason != null) 'reason': reason,
      if (apiKey != null) 'apiKey': apiKey,
      if (model != null) 'model': model,
    });
    return _asMap(res);
  }

  Future<Map<String, dynamic>> uploadOcr({
    required String filePath,
    String fileField = 'document',
    String? patientId,
    bool? autoIngest,
    String? apiKey,
    String? model,
  }) async {
    final res = await _client.multipartPost(
      '/api/agent/ocr',
      fileField: fileField,
      filePath: filePath,
      fields: {
        if (patientId != null) 'patientId': patientId,
        if (autoIngest != null) 'autoIngest': '$autoIngest',
        if (apiKey != null) 'apiKey': apiKey,
        if (model != null) 'model': model,
      },
    );
    return _asMap(res);
  }

  Future<Map<String, dynamic>> uploadIntake({
    required String filePath,
    required String patientId,
    String? query,
    String? fromDoctor,
    String? toSpecialty,
    String? reason,
    String? apiKey,
    String? model,
  }) async {
    final res = await _client.multipartPost(
      '/api/agent/intake',
      fileField: 'document',
      filePath: filePath,
      fields: {
        'patientId': patientId,
        if (query != null) 'query': query,
        if (fromDoctor != null) 'fromDoctor': fromDoctor,
        if (toSpecialty != null) 'toSpecialty': toSpecialty,
        if (reason != null) 'reason': reason,
        if (apiKey != null) 'apiKey': apiKey,
        if (model != null) 'model': model,
      },
    );
    return _asMap(res);
  }

  Future<Map<String, dynamic>> fetchBlockchainChain() async {
    final res = await _client.get('/api/blockchain/chain');
    return _asMap(res);
  }

  Future<Map<String, dynamic>> verifyBlockchain() async {
    final res = await _client.get('/api/blockchain/verify');
    return _asMap(res);
  }

  Future<dynamic> exportBlockchain() {
    return _client.get('/api/blockchain/export');
  }

  Future<Map<String, dynamic>> logEmergency({
    String? patientId,
    String? actorId,
  }) async {
    final res = await _client.post('/api/emergency', body: {
      if (patientId != null) 'patientId': patientId,
      if (actorId != null) 'actorId': actorId,
    });
    return _asMap(res);
  }

  Future<Map<String, dynamic>> whatsappIncoming(
    Map<String, dynamic> payload,
  ) async {
    final res = await _client.post('/api/whatsapp/incoming', body: payload);
    return _asMap(res);
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    return <String, dynamic>{};
  }

  List<dynamic> _asList(dynamic data) {
    if (data is List<dynamic>) {
      return data;
    }
    if (data is Map<String, dynamic>) {
      for (final key in const ['data', 'patients', 'items', 'results']) {
        final value = data[key];
        if (value is List<dynamic>) {
          return value;
        }
      }
    }
    return const [];
  }

  Patient? _recordToPatient(
    Map<String, dynamic> record, {
    required List<dynamic> labs,
    required List<dynamic> flags,
  }) {
    final patientId = '${record['patient_id'] ?? record['patientId'] ?? ''}';
    if (patientId.isEmpty) return null;

    final prescriptions = (record['prescriptions'] is List)
        ? (record['prescriptions'] as List).whereType<Map<String, dynamic>>()
        : const Iterable<Map<String, dynamic>>.empty();

    final visits = (record['visits'] is List)
        ? (record['visits'] as List).whereType<Map<String, dynamic>>().toList()
        : <Map<String, dynamic>>[];

    final medications = prescriptions.map((med) {
      final drug = '${med['drug'] ?? med['name'] ?? 'Medication'}';
      final dose = '${med['dose'] ?? ''}'.trim();
      final frequency = '${med['frequency'] ?? ''}'.trim();
      return Medication(
        name: drug,
        dose: dose.isEmpty ? '-' : dose,
        frequency: frequency.isEmpty ? 'As advised' : frequency,
        hasInteraction: false,
      );
    }).toList();

    final labResults = _buildLabResults(labs);
    final vitals = _buildVitals(labResults);
    final status = _derivePatientStatus(labResults, flags);
    final doctor =
        visits.isNotEmpty ? '${visits.last['doctor'] ?? ''}'.trim() : '';
    final lastVisit =
        visits.isNotEmpty ? '${visits.last['date'] ?? ''}'.trim() : '';

    return Patient(
      id: patientId,
      name: '${record['name'] ?? 'Unknown'}',
      age: _toInt(record['age']),
      gender: '${record['gender'] ?? 'Unknown'}',
      bloodGroup: '',
      diagnoses: _stringList(record['diagnoses']),
      status: status,
      labResults: labResults,
      medications: medications,
      vitals: vitals,
      lastVisit: lastVisit,
      doctor: doctor,
    );
  }

  List<LabResult> _buildLabResults(List<dynamic> labsRaw) {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final item in labsRaw) {
      if (item is! Map<String, dynamic>) continue;
      final test = '${item['test'] ?? item['name'] ?? ''}'.trim();
      if (test.isEmpty) continue;
      grouped.putIfAbsent(test, () => <Map<String, dynamic>>[]).add(item);
    }

    final results = <LabResult>[];
    grouped.forEach((test, entries) {
      final trend = entries
          .map((e) => _toDouble(e['value']))
          .where((v) => v != null)
          .cast<double>()
          .toList();
      final latest = entries.last;
      final raw = latest['raw'];
      final reference =
          raw is Map<String, dynamic> ? '${raw['referenceRange'] ?? ''}' : '';
      final unit = '${latest['unit'] ?? ''}';
      final status = '${latest['status'] ?? 'normal'}'.toLowerCase();

      results.add(
        LabResult(
          name: test,
          value: trend.isNotEmpty ? trend.last : 0,
          unit: unit,
          range: reference,
          status: status,
          trend: trend.isNotEmpty ? trend : [0],
        ),
      );
    });
    return results;
  }

  List<VitalSign> _buildVitals(List<LabResult> labs) {
    final vitals = <VitalSign>[];
    for (final lab in labs) {
      if (lab.name.toLowerCase().contains('bloodpressure')) {
        vitals.add(
          VitalSign(
            name: 'Blood Pressure',
            value: lab.value.toStringAsFixed(0),
            unit: lab.unit.isEmpty ? 'mmHg' : lab.unit,
            status: lab.status,
          ),
        );
      }
    }
    if (vitals.isEmpty && labs.isNotEmpty) {
      final lab = labs.first;
      vitals.add(
        VitalSign(
          name: lab.name,
          value: lab.value.toStringAsFixed(1),
          unit: lab.unit,
          status: lab.status,
        ),
      );
    }
    return vitals;
  }

  String _derivePatientStatus(List<LabResult> labs, List<dynamic> flags) {
    final labStatuses = labs.map((e) => e.status.toLowerCase()).toList();
    final flagSeverities = flags
        .whereType<Map<String, dynamic>>()
        .map((e) => '${e['severity'] ?? ''}'.toLowerCase())
        .toList();

    if (labStatuses.any((s) => s == 'critical' || s == 'high') ||
        flagSeverities.any((s) => s == 'high' || s == 'critical')) {
      return 'critical';
    }
    if (labStatuses.any((s) => s == 'borderline' || s == 'medium') ||
        flagSeverities.any((s) => s == 'medium')) {
      return 'warning';
    }
    return 'stable';
  }

  int _toInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse('$value') ?? 0;
  }

  double? _toDouble(Object? value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse('$value');
  }

  List<String> _stringList(Object? value) {
    if (value is List) {
      return value.map((e) => '$e').toList();
    }
    return const [];
  }
}
