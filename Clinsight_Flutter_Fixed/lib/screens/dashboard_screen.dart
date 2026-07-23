import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/patient_models.dart';
import '../state/app_state.dart';
import '../widgets/common_widgets.dart';
import 'patient_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<AppState>();
      if (state.patients.isEmpty && !state.dataLoading) {
        state.refreshDashboard();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final patients = appState.patients;
    final interactions = appState.interactions;
    final criticalCount = patients.where((p) => p.status == 'critical').length;
    final warningCount = patients.where((p) => p.status == 'warning').length;
    final userName =
        appState.user?.name.isNotEmpty == true ? appState.user!.name : 'Doctor';

    return Scaffold(
      backgroundColor: AppTheme.navyBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Good Morning,',
                          style: GoogleFonts.ibmPlexSans(
                              color: AppTheme.textMuted, fontSize: 13)),
                      Text(userName,
                          style: GoogleFonts.ibmPlexSerif(
                            color: AppTheme.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          )),
                    ],
                  ),
                  Row(
                    children: [
                      _NotifButton(),
                      const SizedBox(width: 10),
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppTheme.navyLight,
                        child: Text('DV',
                            style: GoogleFonts.ibmPlexSans(
                                color: AppTheme.cyan,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // AI Brief Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.navyCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.borderColor),
                  boxShadow: [
                    const BoxShadow(
                      color: Color(0x0D0F172A),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.navyLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.auto_awesome,
                          color: AppTheme.cyan, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AI Pre-Consultation Brief Ready',
                              style: GoogleFonts.ibmPlexSerif(
                                  color: AppTheme.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                          Text('$criticalCount critical alerts · Tap to review',
                              style: GoogleFonts.ibmPlexSans(
                                  color: AppTheme.textMuted, fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        color: AppTheme.textMuted, size: 16),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Stats Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  StatCard(
                    title: 'Total Patients',
                    value: '${patients.length}',
                    subtitle: 'Scheduled today',
                    color: AppTheme.cyan,
                    icon: Icons.people_alt_outlined,
                  ),
                  StatCard(
                    title: 'Critical Alerts',
                    value: '$criticalCount',
                    subtitle: 'Immediate attention',
                    color: AppTheme.danger,
                    icon: Icons.warning_amber_rounded,
                  ),
                  StatCard(
                    title: 'Drug Warnings',
                    value: '${interactions.length}',
                    subtitle: 'Interactions found',
                    color: AppTheme.warning,
                    icon: Icons.medication_outlined,
                  ),
                  StatCard(
                    title: 'Monitoring',
                    value: '$warningCount',
                    subtitle: 'Needs follow-up',
                    color: AppTheme.success,
                    icon: Icons.monitor_heart_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // HbA1c Trend Chart
              SectionHeader(
                title: 'HbA1c Trend Analysis',
                subtitle: 'Last 6 visits — AI detected rising pattern',
              ),
              const SizedBox(height: 12),
              Container(
                height: 180,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.navyCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (v) => FlLine(
                        color: AppTheme.borderColor,
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (v, _) => Text(
                            v.toStringAsFixed(1),
                            style: GoogleFonts.ibmPlexSans(
                                color: AppTheme.textMuted, fontSize: 9),
                          ),
                        ),
                      ),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            final labels = ['V1', 'V2', 'V3', 'V4', 'V5', 'V6'];
                            final idx = v.toInt();
                            if (idx < 0 || idx >= labels.length)
                              return const SizedBox();
                            return Text(labels[idx],
                                style: GoogleFonts.ibmPlexSans(
                                    color: AppTheme.textMuted, fontSize: 9));
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      _lineData(_pickTrend(patients, 0), AppTheme.danger,
                          label: 'P1'),
                      _lineData(_pickTrend(patients, 1), AppTheme.warning,
                          label: 'P2'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Patients List
              SectionHeader(
                title: 'Today\'s Patients',
                subtitle: '${patients.length} scheduled',
                action: GlowButton(
                  label: 'View All',
                  onTap: () {},
                  outlined: true,
                  color: AppTheme.cyan,
                ),
              ),
              const SizedBox(height: 12),
              if (appState.dataLoading && patients.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (patients.isEmpty)
                Text(
                  appState.errorMessage ?? 'No patients found.',
                  style: GoogleFonts.ibmPlexSans(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                )
              else
                ...patients.map((p) => _PatientListCard(patient: p)).toList(),

              const SizedBox(height: 24),

              // Drug Interactions
              SectionHeader(
                title: 'Drug Interaction Alerts',
                subtitle: '${interactions.length} warnings detected',
              ),
              const SizedBox(height: 12),
              ...interactions
                  .map((i) => DrugInteractionCard(
                        drug1: i.drug1,
                        drug2: i.drug2,
                        severity: i.severity,
                        description: i.description,
                      ))
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }

  List<double> _pickTrend(List<Patient> patients, int index) {
    if (patients.length <= index) {
      return const [0, 0, 0, 0, 0, 0];
    }
    final labs = patients[index].labResults;
    if (labs.isEmpty) {
      return const [0, 0, 0, 0, 0, 0];
    }
    final trend = labs.first.trend;
    if (trend.length < 2) {
      return [labs.first.value, labs.first.value];
    }
    return trend;
  }

  LineChartBarData _lineData(List<double> values, Color color,
      {required String label}) {
    return LineChartBarData(
      spots: values
          .asMap()
          .entries
          .map((e) => FlSpot(e.key.toDouble(), e.value))
          .toList(),
      isCurved: true,
      color: color,
      barWidth: 2.5,
      dotData: FlDotData(
        getDotPainter: (spot, percent, barData, index) {
          if (index == values.length - 1) {
            return FlDotCirclePainter(
              radius: 4,
              color: color,
              strokeWidth: 2,
              strokeColor: AppTheme.navyCard,
            );
          }
          return FlDotCirclePainter(radius: 0, color: Colors.transparent);
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        color: color.withOpacity(0.08),
      ),
    );
  }
}

class _NotifButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.navyCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: const Icon(Icons.notifications_outlined,
              color: AppTheme.white, size: 20),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
                color: AppTheme.danger, shape: BoxShape.circle),
          ),
        ),
      ],
    );
  }
}

class _PatientListCard extends StatelessWidget {
  final Patient patient;
  const _PatientListCard({required this.patient});

  Color get _statusColor {
    switch (patient.status) {
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
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PatientDetailScreen(
            patientId: patient.id,
            initialPatient: patient,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.navyCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  patient.name.split(' ').map((n) => n[0]).take(2).join(),
                  style: GoogleFonts.ibmPlexSans(
                    color: _statusColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(patient.name,
                          style: GoogleFonts.ibmPlexSans(
                            color: AppTheme.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          )),
                      const SizedBox(width: 8),
                      StatusBadge(status: patient.status),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${patient.age}y · ${patient.gender} · ${patient.diagnoses.first}',
                    style: GoogleFonts.ibmPlexSans(
                        color: AppTheme.textMuted, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(patient.id,
                    style: GoogleFonts.ibmPlexSans(
                        color: AppTheme.textMuted, fontSize: 10)),
                const SizedBox(height: 4),
                const Icon(Icons.arrow_forward_ios,
                    color: AppTheme.textMuted, size: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
