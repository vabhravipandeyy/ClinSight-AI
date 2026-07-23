import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/patient_models.dart';
import '../state/app_state.dart';
import '../widgets/common_widgets.dart';
import '../widgets/rich_text_markdown.dart';

class PatientDetailScreen extends StatefulWidget {
  final String patientId;
  final Patient? initialPatient;
  const PatientDetailScreen({
    super.key,
    required this.patientId,
    this.initialPatient,
  });

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  Patient? _patient;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _patient = widget.initialPatient;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPatient());
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Color get _statusColor {
    final status = _patient?.status ?? 'stable';
    switch (status) {
      case 'critical':
        return AppTheme.danger;
      case 'warning':
        return AppTheme.warning;
      default:
        return AppTheme.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final patient = _patient;
    return Scaffold(
      backgroundColor: AppTheme.navyBg,
      appBar: AppBar(
        backgroundColor: AppTheme.navyBg,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios, color: AppTheme.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
            patient?.name.isNotEmpty == true ? patient!.name : 'Patient',
            style: GoogleFonts.ibmPlexSans(
                color: AppTheme.white,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: StatusBadge(status: patient?.status ?? 'stable'),
          )
        ],
      ),
      body: patient == null
          ? Center(
              child: _loading
                  ? const CircularProgressIndicator()
                  : Text(
                      'Patient details not available',
                      style: GoogleFonts.ibmPlexSans(color: AppTheme.textMuted),
                    ),
            )
          : Column(
              children: [
                // Patient header card
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _statusColor.withOpacity(0.15),
                        AppTheme.navyCard,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: _statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            patient.name
                                .split(' ')
                                .map((n) => n[0])
                                .take(2)
                                .join(),
                            style: GoogleFonts.ibmPlexSans(
                              color: _statusColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(patient.name,
                                style: GoogleFonts.ibmPlexSans(
                                  color: AppTheme.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                )),
                            const SizedBox(height: 4),
                            Text(
                              '${patient.age} yrs · ${patient.gender} · ${patient.bloodGroup}',
                              style: GoogleFonts.ibmPlexSans(
                                  color: AppTheme.textMuted, fontSize: 12),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: patient.diagnoses
                                  .map((d) => Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.navyLight,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                              color: AppTheme.borderColor),
                                        ),
                                        child: Text(d,
                                            style: GoogleFonts.ibmPlexSans(
                                                color: AppTheme.textSecondary,
                                                fontSize: 10)),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Text(patient.id,
                              style: GoogleFonts.ibmPlexSans(
                                  color: AppTheme.textMuted, fontSize: 11)),
                          const SizedBox(height: 4),
                          Text(patient.lastVisit,
                              style: GoogleFonts.ibmPlexSans(
                                  color: AppTheme.textMuted, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // AI Brief button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: _showAIBrief,
                      icon: const Icon(Icons.auto_awesome, size: 18),
                      label: Text('Generate 60-Second AI Brief',
                          style: GoogleFonts.ibmPlexSans(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.cyan,
                        foregroundColor: AppTheme.navyBg,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tabs
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.navyCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: TabBar(
                    controller: _tabCtrl,
                    indicatorColor: AppTheme.cyan,
                    indicatorWeight: 2,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: AppTheme.cyan,
                    unselectedLabelColor: AppTheme.textMuted,
                    labelStyle: GoogleFonts.ibmPlexSans(
                        fontSize: 11, fontWeight: FontWeight.w600),
                    unselectedLabelStyle: GoogleFonts.ibmPlexSans(
                        fontSize: 11, fontWeight: FontWeight.w500),
                    tabs: const [
                      Tab(text: 'Vitals'),
                      Tab(text: 'Labs'),
                      Tab(text: 'Meds'),
                      Tab(text: 'Body Map'),
                    ],
                  ),
                ),
                const SizedBox(height: 4),

                Expanded(
                  child: TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _VitalsTab(patient: patient),
                      _LabsTab(patient: patient),
                      _MedsTab(patient: patient),
                      _BodyMapTab(patient: patient),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _loadPatient() async {
    final data =
        await context.read<AppState>().fetchPatientDetails(widget.patientId);
    if (!mounted) return;
    setState(() {
      _patient = data ?? _patient;
      _loading = false;
    });
  }

  Future<void> _showAIBrief() async {
    final p = _patient;
    if (p == null) return;
    final appState = context.read<AppState>();
    final backendBrief = await appState.fetchPatientBrief(p.id);
    if (!mounted) return;
    final criticalLabs =
        p.labResults.where((l) => l.status == 'critical').toList();
    final interactions = p.medications.where((m) => m.hasInteraction).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.navyCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppTheme.cyan, size: 20),
                const SizedBox(width: 8),
                Text('AI Pre-Consultation Brief',
                    style: GoogleFonts.ibmPlexSans(
                      color: AppTheme.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    )),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.cyan.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('60s BRIEF',
                      style: GoogleFonts.ibmPlexSans(
                          color: AppTheme.cyan,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const Divider(color: AppTheme.borderColor, height: 24),
            _BriefSection(
              icon: Icons.person,
              title: 'Patient Summary',
              content: backendBrief.isNotEmpty
                  ? backendBrief
                  : '${p.name}, ${p.age}y ${p.gender}. Diagnosed with ${p.diagnoses.join(", ")}. Last visit: ${p.lastVisit}.',
              color: AppTheme.cyan,
            ),
            if (criticalLabs.isNotEmpty)
              _BriefSection(
                icon: Icons.warning_amber_rounded,
                title: 'Critical Lab Values',
                content: criticalLabs
                    .map((l) => '${l.name}: ${l.value} ${l.unit} (↑ rising)')
                    .join('\n'),
                color: AppTheme.danger,
              ),
            if (interactions.isNotEmpty)
              _BriefSection(
                icon: Icons.medication,
                title: 'Drug Interaction Warning',
                content:
                    '${interactions.map((m) => m.name).join(" + ")} — Review immediately.',
                color: AppTheme.warning,
              ),
            _BriefSection(
              icon: Icons.assignment_turned_in,
              title: 'Recommended Actions',
              content:
                  '• Review trending lab values\n• Adjust medication if needed\n• Consider follow-up in 2 weeks\n• Monitor kidney function',
              color: AppTheme.success,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.cyan,
                  foregroundColor: AppTheme.navyBg,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Got it — Start Consultation',
                    style:
                        GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _BriefSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color color;

  const _BriefSection({
    required this.icon,
    required this.title,
    required this.content,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.ibmPlexSans(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                RichTextMarkdown(
                  data: content,
                  style: GoogleFonts.ibmPlexSans(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      height: 1.5),
                  boldStyle: GoogleFonts.ibmPlexSans(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      height: 1.5,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Vitals Tab ───────────────────────────────────────────────
class _VitalsTab extends StatelessWidget {
  final Patient patient;
  const _VitalsTab({required this.patient});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: patient.vitals.length,
      itemBuilder: (_, i) {
        final v = patient.vitals[i];
        return VitalCard(
          name: v.name,
          value: v.value,
          unit: v.unit,
          status: v.status,
        );
      },
    );
  }
}

// ─── Labs Tab ─────────────────────────────────────────────────
class _LabsTab extends StatelessWidget {
  final Patient patient;
  const _LabsTab({required this.patient});

  Color _statusColor(String status) {
    switch (status) {
      case 'high':
      case 'critical':
        return AppTheme.danger;
      case 'borderline':
      case 'warning':
      case 'medium':
      case 'low':
        return AppTheme.warning;
      default:
        return AppTheme.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: patient.labResults.length,
      itemBuilder: (_, i) {
        final lab = patient.labResults[i];
        final color = _statusColor(lab.status);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.navyCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(lab.name,
                      style: GoogleFonts.ibmPlexSans(
                          color: AppTheme.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  StatusBadge(status: lab.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${lab.value}',
                    style: GoogleFonts.ibmPlexSans(
                        color: color,
                        fontSize: 26,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(lab.unit,
                        style: GoogleFonts.ibmPlexSans(
                            color: AppTheme.textMuted, fontSize: 12)),
                  ),
                  const Spacer(),
                  Text('Normal: ${lab.range}',
                      style: GoogleFonts.ibmPlexSans(
                          color: AppTheme.textMuted, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 10),
              // Mini trend chart
              SizedBox(
                height: 50,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(
                      leftTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: lab.trend
                            .asMap()
                            .entries
                            .map((e) => FlSpot(e.key.toDouble(), e.value))
                            .toList(),
                        isCurved: true,
                        color: color,
                        barWidth: 2,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: color.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                lab.status == 'critical' || lab.status == 'high'
                    ? '↑ Trending upward — attention needed'
                    : lab.status == 'low' ||
                            lab.status == 'borderline' ||
                            lab.status == 'medium'
                        ? '↓ Trending downward — monitor closely'
                        : '✓ Within normal range',
                style: GoogleFonts.ibmPlexSans(
                    color: color, fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Medications Tab ──────────────────────────────────────────
class _MedsTab extends StatelessWidget {
  final Patient patient;
  const _MedsTab({required this.patient});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (patient.medications.any((m) => m.hasInteraction))
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppTheme.danger.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.danger.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: AppTheme.danger, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Drug interaction detected — review before prescribing',
                    style: GoogleFonts.ibmPlexSans(
                        color: AppTheme.danger, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ...patient.medications.map((med) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.navyCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: med.hasInteraction
                      ? AppTheme.danger.withOpacity(0.4)
                      : AppTheme.borderColor,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: med.hasInteraction
                          ? AppTheme.danger.withOpacity(0.15)
                          : AppTheme.cyan.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.medication,
                      color:
                          med.hasInteraction ? AppTheme.danger : AppTheme.cyan,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(med.name,
                                style: GoogleFonts.ibmPlexSans(
                                    color: AppTheme.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600)),
                            if (med.hasInteraction) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.warning_amber_rounded,
                                  color: AppTheme.danger, size: 14),
                            ]
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text('${med.dose} · ${med.frequency}',
                            style: GoogleFonts.ibmPlexSans(
                                color: AppTheme.textMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

// ─── Body Map Tab ─────────────────────────────────────────────
class _BodyMapTab extends StatelessWidget {
  final Patient patient;
  const _BodyMapTab({required this.patient});

  @override
  Widget build(BuildContext context) {
    final organs = _getOrganStatus();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Organ Health Visualization',
              style: GoogleFonts.ibmPlexSans(
                  color: AppTheme.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Based on lab values and clinical history',
              style: GoogleFonts.ibmPlexSans(
                  color: AppTheme.textMuted, fontSize: 12)),
          const SizedBox(height: 16),
          // Legend
          Row(
            children: [
              _LegendDot(color: AppTheme.success, label: 'Healthy'),
              const SizedBox(width: 16),
              _LegendDot(color: AppTheme.warning, label: 'Monitor'),
              const SizedBox(width: 16),
              _LegendDot(color: AppTheme.danger, label: 'Critical'),
            ],
          ),
          const SizedBox(height: 20),
          // Body visualization - custom painted
          Center(
            child: SizedBox(
              height: 360,
              width: 220,
              child: CustomPaint(
                painter: BodyMapPainter(organs: organs),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Organ cards
          ...organs.map((organ) => _OrganCard(organ: organ)),
        ],
      ),
    );
  }

  List<OrganStatus> _getOrganStatus() {
    final results = <OrganStatus>[];
    final labs = patient.labResults;
    final vitals = patient.vitals;

    // Kidney
    final kidneyMatches = labs.where((l) => l.name == 'Creatinine');
    final kidney = kidneyMatches.isNotEmpty
        ? kidneyMatches.first
        : (labs.isNotEmpty
            ? labs.first
            : const LabResult(
                name: 'Creatinine',
                value: 0,
                unit: 'mg/dL',
                range: '',
                status: 'stable',
                trend: [0],
              ));
    results.add(OrganStatus(
      name: 'Kidney',
      icon: Icons.water_drop,
      status: kidney.status == 'high' || kidney.status == 'critical'
          ? 'critical'
          : 'normal',
      detail: 'Creatinine: ${kidney.value} ${kidney.unit}',
    ));

    // Heart
    final bpMatches = vitals.where((v) => v.name == 'Blood Pressure');
    final bp = bpMatches.isNotEmpty
        ? bpMatches.first
        : (vitals.isNotEmpty
            ? vitals.first
            : const VitalSign(
                name: 'Blood Pressure',
                value: '0/0',
                unit: 'mmHg',
                status: 'stable',
              ));
    results.add(OrganStatus(
      name: 'Heart',
      icon: Icons.favorite,
      status: bp.status == 'high' ? 'warning' : 'normal',
      detail: 'BP: ${bp.value} ${bp.unit}',
    ));

    // Blood/Glucose
    final hba1cMatches = labs.where((l) => l.name == 'HbA1c');
    final hba1c = hba1cMatches.isNotEmpty
        ? hba1cMatches.first
        : (labs.isNotEmpty
            ? labs.first
            : const LabResult(
                name: 'HbA1c',
                value: 0,
                unit: '%',
                range: '',
                status: 'stable',
                trend: [0],
              ));
    results.add(OrganStatus(
      name: 'Blood',
      icon: Icons.bloodtype,
      status: hba1c.status == 'critical'
          ? 'critical'
          : hba1c.status == 'high'
              ? 'warning'
              : 'normal',
      detail: 'HbA1c: ${hba1c.value} ${hba1c.unit}',
    ));

    // Liver
    results.add(OrganStatus(
      name: 'Liver',
      icon: Icons.health_and_safety,
      status: 'normal',
      detail: 'No abnormalities detected',
    ));

    // Lungs
    final spo2Matches = vitals.where((v) => v.name == 'SpO2');
    final spo2 = spo2Matches.isNotEmpty
        ? spo2Matches.first
        : (vitals.isNotEmpty
            ? vitals.first
            : const VitalSign(
                name: 'SpO2',
                value: '0',
                unit: '%',
                status: 'stable',
              ));
    results.add(OrganStatus(
      name: 'Lungs',
      icon: Icons.air,
      status: spo2.status == 'warning' ? 'warning' : 'normal',
      detail: 'SpO2: ${spo2.value} ${spo2.unit}',
    ));

    return results;
  }
}

class OrganStatus {
  final String name;
  final IconData icon;
  final String status;
  final String detail;

  OrganStatus({
    required this.name,
    required this.icon,
    required this.status,
    required this.detail,
  });

  Color get color {
    switch (status) {
      case 'critical':
        return AppTheme.danger;
      case 'warning':
        return AppTheme.warning;
      default:
        return AppTheme.success;
    }
  }
}

class BodyMapPainter extends CustomPainter {
  final List<OrganStatus> organs;
  BodyMapPainter({required this.organs});

  Color _getColor(String name) {
    final organ = organs.firstWhere((o) => o.name == name,
        orElse: () => OrganStatus(
            name: '', icon: Icons.circle, status: 'normal', detail: ''));
    return organ.color;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()
      ..color = AppTheme.navyLight
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = AppTheme.borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final cx = size.width / 2;

    // Head
    canvas.drawCircle(Offset(cx, 36), 34, bodyPaint);
    canvas.drawCircle(Offset(cx, 36), 34, borderPaint);

    // Neck
    final neckPath = Path()
      ..addRect(Rect.fromCenter(center: Offset(cx, 78), width: 28, height: 16));
    canvas.drawPath(neckPath, bodyPaint);

    // Torso
    final torsoPaint = Paint()
      ..color = AppTheme.navyLight
      ..style = PaintingStyle.fill;
    final torsoPath = Path()
      ..moveTo(cx - 62, 86)
      ..lineTo(cx + 62, 86)
      ..lineTo(cx + 54, 220)
      ..lineTo(cx - 54, 220)
      ..close();
    canvas.drawPath(torsoPath, torsoPaint);
    canvas.drawPath(torsoPath, borderPaint);

    // Left arm
    final leftArm = Path()
      ..moveTo(cx - 62, 90)
      ..lineTo(cx - 90, 100)
      ..lineTo(cx - 84, 195)
      ..lineTo(cx - 62, 195)
      ..close();
    canvas.drawPath(leftArm, bodyPaint);
    canvas.drawPath(leftArm, borderPaint);

    // Right arm
    final rightArm = Path()
      ..moveTo(cx + 62, 90)
      ..lineTo(cx + 90, 100)
      ..lineTo(cx + 84, 195)
      ..lineTo(cx + 62, 195)
      ..close();
    canvas.drawPath(rightArm, bodyPaint);
    canvas.drawPath(rightArm, borderPaint);

    // Left leg
    final leftLeg = Path()
      ..moveTo(cx - 52, 220)
      ..lineTo(cx - 8, 220)
      ..lineTo(cx - 10, 340)
      ..lineTo(cx - 52, 340)
      ..close();
    canvas.drawPath(leftLeg, bodyPaint);
    canvas.drawPath(leftLeg, borderPaint);

    // Right leg
    final rightLeg = Path()
      ..moveTo(cx + 8, 220)
      ..lineTo(cx + 52, 220)
      ..lineTo(cx + 52, 340)
      ..lineTo(cx + 10, 340)
      ..close();
    canvas.drawPath(rightLeg, bodyPaint);
    canvas.drawPath(rightLeg, borderPaint);

    // Organ indicators
    _drawOrgan(canvas, Offset(cx, 122), 18, _getColor('Heart'), 'Heart');
    _drawOrgan(canvas, Offset(cx - 26, 145), 14, _getColor('Lungs'), 'L');
    _drawOrgan(canvas, Offset(cx + 26, 145), 14, _getColor('Lungs'), 'R');
    _drawOrgan(canvas, Offset(cx, 168), 16, _getColor('Kidney'), 'Kidney');
    _drawOrgan(canvas, Offset(cx, 195), 14, _getColor('Liver'), 'Liver');
  }

  void _drawOrgan(
      Canvas canvas, Offset center, double radius, Color color, String label) {
    final glowPaint = Paint()
      ..color = color.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, radius + 4, glowPaint);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, paint);

    final tp = TextPainter(
      text: TextSpan(
        text: label.length > 2 ? label[0] : label,
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.7,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OrganCard extends StatelessWidget {
  final OrganStatus organ;
  const _OrganCard({required this.organ});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.navyCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: organ.color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: organ.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(organ.icon, color: organ.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(organ.name,
                    style: GoogleFonts.ibmPlexSans(
                        color: AppTheme.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                Text(organ.detail,
                    style: GoogleFonts.ibmPlexSans(
                        color: AppTheme.textMuted, fontSize: 11)),
              ],
            ),
          ),
          StatusBadge(status: organ.status),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label,
            style: GoogleFonts.ibmPlexSans(
                color: AppTheme.textMuted, fontSize: 11)),
      ],
    );
  }
}
