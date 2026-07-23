import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

// ─── Stat Card ───────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;
  final Widget? trailing;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.navyCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.ibmPlexSans(
              color: AppTheme.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.ibmPlexSans(
              color: AppTheme.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.ibmPlexSans(
              color: color,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.ibmPlexSerif(
                  color: AppTheme.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: GoogleFonts.ibmPlexSans(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

// ─── Status Badge ─────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  Color get _color {
    switch (status.toLowerCase()) {
      case 'critical':
        return AppTheme.danger;
      case 'warning':
      case 'borderline':
      case 'medium':
        return AppTheme.warning;
      case 'stable':
        return AppTheme.success;
      case 'high':
        return AppTheme.danger;
      case 'low':
        return AppTheme.warning;
      case 'normal':
        return AppTheme.success;
      default:
        return AppTheme.textMuted;
    }
  }

  Color get _textColor {
    switch (status.toLowerCase()) {
      case 'critical':
      case 'high':
        return AppTheme.dangerText;
      case 'warning':
      case 'borderline':
      case 'medium':
      case 'low':
        return AppTheme.warningText;
      case 'stable':
      case 'normal':
        return AppTheme.successText;
      default:
        return AppTheme.textMuted;
    }
  }

  Color get _bgColor {
    switch (status.toLowerCase()) {
      case 'critical':
      case 'high':
        return AppTheme.dangerBg;
      case 'warning':
      case 'borderline':
      case 'medium':
      case 'low':
        return AppTheme.warningBg;
      case 'stable':
      case 'normal':
        return AppTheme.successBg;
      default:
        return AppTheme.navyLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.35)),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.ibmPlexSans(
          color: _textColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─── Vital Card ───────────────────────────────────────────────
class VitalCard extends StatelessWidget {
  final String name;
  final String value;
  final String unit;
  final String status;

  const VitalCard({
    super.key,
    required this.name,
    required this.value,
    required this.unit,
    required this.status,
  });

  Color get _statusColor {
    switch (status.toLowerCase()) {
      case 'critical':
        return AppTheme.danger;
      case 'high':
        return AppTheme.danger;
      case 'warning':
        return AppTheme.warning;
      case 'low':
        return AppTheme.warning;
      default:
        return AppTheme.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.navyLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  name,
                  style: GoogleFonts.ibmPlexSans(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.ibmPlexSans(
              color: AppTheme.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            unit,
            style: GoogleFonts.ibmPlexSans(
              color: AppTheme.textMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Glowing Button ───────────────────────────────────────────
class GlowButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final Color? color;
  final bool outlined;

  const GlowButton({
    super.key,
    required this.label,
    this.icon,
    required this.onTap,
    this.color,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final btnColor = color ?? AppTheme.cyan;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : btnColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: btnColor),
          boxShadow: outlined
              ? null
              : [
                  BoxShadow(
                      color: btnColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  color: outlined ? btnColor : AppTheme.navyBg, size: 16),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.ibmPlexSans(
                color: outlined ? btnColor : AppTheme.navyBg,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Info Row ─────────────────────────────────────────────────
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.ibmPlexSans(
                  color: AppTheme.textMuted, fontSize: 13)),
          Text(value,
              style: GoogleFonts.ibmPlexSans(
                  color: valueColor ?? AppTheme.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─── Drug Interaction Warning ─────────────────────────────────
class DrugInteractionCard extends StatelessWidget {
  final String drug1;
  final String drug2;
  final String severity;
  final String description;

  const DrugInteractionCard({
    super.key,
    required this.drug1,
    required this.drug2,
    required this.severity,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final color = severity == 'high' ? AppTheme.danger : AppTheme.warning;
    final bgColor = severity == 'high' ? AppTheme.dangerBg : AppTheme.warningBg;
    final textColor =
        severity == 'high' ? AppTheme.dangerText : AppTheme.warningText;
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(drug1,
                        style: GoogleFonts.ibmPlexSans(
                            color: AppTheme.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(Icons.add, color: color, size: 12),
                    ),
                    Text(drug2,
                        style: GoogleFonts.ibmPlexSans(
                            color: AppTheme.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    const Spacer(),
                    StatusBadge(status: severity),
                  ],
                ),
                const SizedBox(height: 4),
                Text(description,
                    style: GoogleFonts.ibmPlexSans(
                        color: textColor, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
