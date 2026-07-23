import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/patient_models.dart';
import '../state/app_state.dart';
import '../widgets/common_widgets.dart';
import 'patient_detail_screen.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  String _filter = 'all';
  String _search = '';

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

  List<Patient> get _filtered {
    final patients = context.read<AppState>().patients;
    return patients.where((p) {
      final matchFilter = _filter == 'all' || p.status == _filter;
      final matchSearch = _search.isEmpty ||
          p.name.toLowerCase().contains(_search.toLowerCase()) ||
          p.id.toLowerCase().contains(_search.toLowerCase());
      return matchFilter && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: AppTheme.navyBg,
      appBar: AppBar(
        backgroundColor: AppTheme.navyBg,
        title: Text('Patients',
            style: GoogleFonts.ibmPlexSans(
                color: AppTheme.white,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppTheme.cyan),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                // Search
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.navyCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _search = v),
                    style: GoogleFonts.ibmPlexSans(
                        color: AppTheme.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search patients...',
                      hintStyle: GoogleFonts.ibmPlexSans(
                          color: AppTheme.textMuted, fontSize: 13),
                      prefixIcon: const Icon(Icons.search,
                          color: AppTheme.textMuted, size: 18),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Filter chips
                Row(
                  children: [
                    _FilterChip(
                      label: 'All',
                      selected: _filter == 'all',
                      onTap: () => setState(() => _filter = 'all'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Critical',
                      selected: _filter == 'critical',
                      color: AppTheme.danger,
                      onTap: () => setState(() => _filter = 'critical'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Warning',
                      selected: _filter == 'warning',
                      color: AppTheme.warning,
                      onTap: () => setState(() => _filter = 'warning'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Stable',
                      selected: _filter == 'stable',
                      color: AppTheme.success,
                      onTap: () => setState(() => _filter = 'stable'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: appState.dataLoading && appState.patients.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.person_search,
                                color: AppTheme.textMuted, size: 48),
                            const SizedBox(height: 12),
                            Text('No patients found',
                                style: GoogleFonts.ibmPlexSans(
                                    color: AppTheme.textMuted, fontSize: 14)),
                            if (appState.errorMessage != null) ...[
                              const SizedBox(height: 8),
                              Text(appState.errorMessage!,
                                  style: GoogleFonts.ibmPlexSans(
                                      color: AppTheme.danger, fontSize: 11)),
                            ],
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final p = filtered[i];
                          return _PatientCard(patient: p);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.cyan;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? c.withOpacity(0.2) : AppTheme.navyCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? c : AppTheme.borderColor),
        ),
        child: Text(label,
            style: GoogleFonts.ibmPlexSans(
              color: selected ? c : AppTheme.textMuted,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            )),
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final Patient patient;
  const _PatientCard({required this.patient});

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
                )),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.navyCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      patient.name.split(' ').map((n) => n[0]).take(2).join(),
                      style: GoogleFonts.ibmPlexSans(
                        color: _statusColor,
                        fontSize: 16,
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
                          Expanded(
                            child: Text(patient.name,
                                style: GoogleFonts.ibmPlexSans(
                                  color: AppTheme.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                )),
                          ),
                          StatusBadge(status: patient.status),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${patient.id} · ${patient.age} yrs · ${patient.gender} · ${patient.bloodGroup}',
                        style: GoogleFonts.ibmPlexSans(
                            color: AppTheme.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: AppTheme.borderColor, height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: patient.diagnoses
                        .map((d) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.navyLight,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(d,
                                  style: GoogleFonts.ibmPlexSans(
                                      color: AppTheme.textMuted, fontSize: 10)),
                            ))
                        .toList(),
                  ),
                ),
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
