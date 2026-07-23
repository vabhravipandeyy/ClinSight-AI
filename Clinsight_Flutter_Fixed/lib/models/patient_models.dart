class Patient {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String bloodGroup;
  final List<String> diagnoses;
  final String status;
  final List<LabResult> labResults;
  final List<Medication> medications;
  final List<VitalSign> vitals;
  final String lastVisit;
  final String doctor;

  const Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.bloodGroup,
    required this.diagnoses,
    required this.status,
    required this.labResults,
    required this.medications,
    required this.vitals,
    required this.lastVisit,
    required this.doctor,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    final labsRaw = _firstList(
      json,
      const ['labResults', 'labs', 'lab_results'],
    );
    final medsRaw = _firstList(
      json,
      const ['medications', 'meds', 'currentMedications'],
    );
    final vitalsRaw = _firstList(
      json,
      const ['vitals', 'vitalSigns', 'vital_signs'],
    );

    return Patient(
      id: _firstString(json, const ['id', 'patientId', 'patient_id']),
      name: _firstString(json, const ['name', 'fullName', 'patientName']),
      age: _firstInt(json, const ['age']),
      gender: _firstString(json, const ['gender', 'sex']),
      bloodGroup: _firstString(json, const ['bloodGroup', 'blood_group']),
      diagnoses: _toStringList(
        _firstValue(json, const ['diagnoses', 'conditions', 'diagnosis']),
      ),
      status: _normalizeStatus(
        _firstString(json, const ['status', 'riskStatus', 'risk']),
      ),
      labResults: labsRaw
          .whereType<Map<String, dynamic>>()
          .map(LabResult.fromJson)
          .toList(),
      medications: medsRaw
          .whereType<Map<String, dynamic>>()
          .map(Medication.fromJson)
          .toList(),
      vitals: vitalsRaw
          .whereType<Map<String, dynamic>>()
          .map(VitalSign.fromJson)
          .toList(),
      lastVisit: _firstString(
        json,
        const ['lastVisit', 'last_visit', 'lastConsultationDate'],
      ),
      doctor: _firstString(json, const ['doctor', 'assignedDoctor']),
    );
  }

  Patient copyWith({
    List<LabResult>? labResults,
    List<Medication>? medications,
    List<VitalSign>? vitals,
    String? status,
    String? lastVisit,
  }) {
    return Patient(
      id: id,
      name: name,
      age: age,
      gender: gender,
      bloodGroup: bloodGroup,
      diagnoses: diagnoses,
      status: status ?? this.status,
      labResults: labResults ?? this.labResults,
      medications: medications ?? this.medications,
      vitals: vitals ?? this.vitals,
      lastVisit: lastVisit ?? this.lastVisit,
      doctor: doctor,
    );
  }
}

class LabResult {
  final String name;
  final double value;
  final String unit;
  final String range;
  final String status;
  final List<double> trend;

  const LabResult({
    required this.name,
    required this.value,
    required this.unit,
    required this.range,
    required this.status,
    required this.trend,
  });

  factory LabResult.fromJson(Map<String, dynamic> json) {
    final rawTrend = _firstList(json, const ['trend', 'values', 'history']);
    final trend = rawTrend
        .map((e) => _toDouble(e))
        .where((e) => e != null)
        .cast<double>()
        .toList();

    final currentValue = _toDouble(
          _firstValue(json, const ['value', 'result', 'current']),
        ) ??
        0;

    return LabResult(
      name: _firstString(json, const ['name', 'testName', 'test']),
      value: currentValue,
      unit: _firstString(json, const ['unit']),
      range: _firstString(json, const ['range', 'normalRange']),
      status: _normalizeStatus(_firstString(json, const ['status', 'flag'])),
      trend: trend.isEmpty ? [currentValue] : trend,
    );
  }
}

class Medication {
  final String name;
  final String dose;
  final String frequency;
  final bool hasInteraction;

  const Medication({
    required this.name,
    required this.dose,
    required this.frequency,
    required this.hasInteraction,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      name: _firstString(json, const ['name', 'medicine', 'drug']),
      dose: _firstString(json, const ['dose', 'dosage']),
      frequency: _firstString(json, const ['frequency', 'schedule']),
      hasInteraction: _firstBool(
        json,
        const ['hasInteraction', 'interaction', 'isInteracting'],
      ),
    );
  }
}

class VitalSign {
  final String name;
  final String value;
  final String unit;
  final String status;

  const VitalSign({
    required this.name,
    required this.value,
    required this.unit,
    required this.status,
  });

  factory VitalSign.fromJson(Map<String, dynamic> json) {
    final value = _firstValue(json, const ['value', 'reading', 'result']);
    return VitalSign(
      name: _firstString(json, const ['name', 'vital', 'label']),
      value: value == null ? '' : '$value',
      unit: _firstString(json, const ['unit']),
      status: _normalizeStatus(_firstString(json, const ['status', 'flag'])),
    );
  }
}

class DrugInteraction {
  final String drug1;
  final String drug2;
  final String severity;
  final String description;

  const DrugInteraction({
    required this.drug1,
    required this.drug2,
    required this.severity,
    required this.description,
  });

  factory DrugInteraction.fromJson(Map<String, dynamic> json) {
    return DrugInteraction(
      drug1: _firstString(json, const ['drug1', 'medicineA', 'drugA']),
      drug2: _firstString(json, const ['drug2', 'medicineB', 'drugB']),
      severity: _firstString(json, const ['severity', 'risk']),
      description: _firstString(json, const ['description', 'message', 'note']),
    );
  }
}

class AppUser {
  final String name;
  final String email;
  final String role;

  const AppUser({
    required this.name,
    required this.email,
    required this.role,
  });

  factory AppUser.fromJson(Map<String, dynamic> json, {String? roleFallback}) {
    return AppUser(
      name: _firstString(json, const ['name', 'fullName']),
      email: _firstString(json, const ['email']),
      role: roleFallback ?? _firstString(json, const ['role']),
    );
  }
}

String _normalizeStatus(String value) {
  final lower = value.toLowerCase();
  if (lower == 'high' || lower == 'critical' || lower == 'severe') {
    return 'critical';
  }
  if (lower == 'moderate' || lower == 'warning' || lower == 'risk') {
    return 'warning';
  }
  if (lower == 'monitoring') {
    return 'warning';
  }
  if (lower == 'low') {
    return 'low';
  }
  if (lower == 'normal' || lower == 'stable') {
    return 'stable';
  }
  return value.isEmpty ? 'stable' : lower;
}

Object? _firstValue(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    if (json.containsKey(key) && json[key] != null) {
      return json[key];
    }
  }
  return null;
}

String _firstString(Map<String, dynamic> json, List<String> keys) {
  final value = _firstValue(json, keys);
  if (value == null) return '';
  return '$value';
}

int _firstInt(Map<String, dynamic> json, List<String> keys) {
  final value = _firstValue(json, keys);
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.round();
  return int.tryParse('$value') ?? 0;
}

bool _firstBool(Map<String, dynamic> json, List<String> keys) {
  final value = _firstValue(json, keys);
  if (value is bool) return value;
  if (value is num) return value > 0;
  return '$value'.toLowerCase() == 'true';
}

double? _toDouble(Object? value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value == null) return null;
  return double.tryParse('$value');
}

List<String> _toStringList(Object? value) {
  if (value is List) {
    return value.map((e) => '$e').where((e) => e.trim().isNotEmpty).toList();
  }
  if (value is String && value.trim().isNotEmpty) {
    return value
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
  return const [];
}

List<dynamic> _firstList(Map<String, dynamic> json, List<String> keys) {
  final value = _firstValue(json, keys);
  return value is List ? value : const [];
}
