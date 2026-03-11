// widgets/job_match_card.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/job_matched.dart';
import '../utils/color.dart';

class JobMatchCard extends StatelessWidget {
  final JobMatch match;
  final VoidCallback? onTap;

  const JobMatchCard({
    super.key,
    required this.match,
    this.onTap,
  });

  // ── Couleur selon le score ──────────────────────────────────────────
  Color _scoreColor(int score) {
    if (score >= 75) return const Color(0xFF00C896); // vert
    if (score >= 50) return ColorPalette.teal;        // teal
    return const Color(0xFFFFB347);                   // orange
  }

  // ── Label selon le score ────────────────────────────────────────────
  String _scoreLabel(int score) {
    if (score >= 75) return "Excellent";
    if (score >= 50) return "Bon match";
    return "Partiel";
  }

  @override
  Widget build(BuildContext context) {
    final color = _scoreColor(match.score);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color:        ColorPalette.field,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ColorPalette.border, width: 1.2),
          boxShadow: [
            BoxShadow(
              color:      Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset:     const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── En-tête : titre + score ───────────────────────────
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: color.withOpacity(0.06),
                borderRadius: const BorderRadius.only(
                  topLeft:  Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                border: Border(
                  bottom: BorderSide(
                      color: ColorPalette.border, width: 1),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icône entreprise
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      color:        color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: color.withOpacity(0.3), width: 1),
                    ),
                    child: Center(
                      child: Text(
                        match.jobOffer.company.isNotEmpty
                            ? match.jobOffer.company[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color:      color,
                          fontSize:   20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Titre + entreprise
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          match.jobOffer.title,
                          style: const TextStyle(
                            color:      ColorPalette.text,
                            fontSize:   15,
                            fontWeight: FontWeight.w600,
                            height:     1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.business_outlined,
                              color: ColorPalette.hint, size: 13),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              match.jobOffer.company,
                              style: const TextStyle(
                                  color:    ColorPalette.hint,
                                  fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Score circulaire
                  _ScoreCircle(
                    score: match.score,
                    color: color,
                    label: _scoreLabel(match.score),
                  ),
                ],
              ),
            ),

            // ── Infos rapides ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 12),
              child: Row(children: [
                _InfoChip(
                  icon:  Icons.location_on_outlined,
                  label: match.jobOffer.location,
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon:  Icons.work_outline,
                  label: "${match.jobOffer.minXp} ans min",
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon:  Icons.category_outlined,
                  label: match.jobOffer.category,
                  maxWidth: 100,
                ),
              ]),
            ),

            // ── Points forts ──────────────────────────────────────
            if (match.explanation.pointsForts.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SmallTitle(label: "Points forts"),
                    const SizedBox(height: 8),
                    ...match.explanation.pointsForts
                        .take(2) // max 2 pour ne pas surcharger
                        .map((point) => _BulletPoint(text: point)),
                  ],
                ),
              ),
            ],

            // ── Avis expert ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ColorPalette.teal.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: ColorPalette.teal.withOpacity(0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline,
                        color: ColorPalette.teal, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        match.explanation.avisExpert,
                        style: const TextStyle(
                          color:    ColorPalette.hint,
                          fontSize: 12,
                          height:   1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Score circulaire ─────────────────────────────────────────────────────────
class _ScoreCircle extends StatelessWidget {
  const _ScoreCircle({
    required this.score,
    required this.color,
    required this.label,
  });
  final int    score;
  final Color  color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 52, height: 52,
          child: CustomPaint(
            painter: _CirclePainter(
              progress: score / 100,
              color:    color,
            ),
            child: Center(
              child: Text(
                "$score",
                style: TextStyle(
                  color:      color,
                  fontSize:   15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color:    color,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CirclePainter extends CustomPainter {
  final double progress;
  final Color  color;

  _CirclePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width  / 2;
    final cy = size.height / 2;
    final r  = size.width  / 2 - 4;

    // Fond du cercle
    canvas.drawCircle(
      Offset(cx, cy), r,
      Paint()
        ..color       = color.withOpacity(0.12)
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    // Arc de progression
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color       = color
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap   = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Chip info ────────────────────────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    this.maxWidth,
  });
  final IconData icon;
  final String   label;
  final double?  maxWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:        ColorPalette.border.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: ColorPalette.hint, size: 12),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: maxWidth ?? 80),
            child: Text(
              label,
              style: const TextStyle(
                  color: ColorPalette.hint, fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Titre de sous-section ────────────────────────────────────────────────────
class _SmallTitle extends StatelessWidget {
  const _SmallTitle({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color:         ColorPalette.hint,
        fontSize:      10,
        fontWeight:    FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

// ─── Point fort ───────────────────────────────────────────────────────────────
class _BulletPoint extends StatelessWidget {
  const _BulletPoint({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 5, height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ColorPalette.teal,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color:    ColorPalette.text,
                fontSize: 13,
                height:   1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}