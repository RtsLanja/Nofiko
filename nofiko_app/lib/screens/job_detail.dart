import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/color.dart';
import '../models/job_offer.dart';
import '../widgets/custom_app_bar.dart';

class JobDetailScreen extends StatefulWidget {
  const JobDetailScreen({super.key, required this.jobDetail});
  final JobOffer jobDetail;

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl() async {
    final uri = Uri.tryParse(widget.jobDetail.rawUrl);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Impossible d'ouvrir le lien."),
            backgroundColor: ColorPalette.tealDark,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 30) return 'Il y a ${(diff.inDays / 30).floor()} mois';
    if (diff.inDays > 0) return 'Il y a ${diff.inDays} j';
    if (diff.inHours > 0) return 'Il y a ${diff.inHours} h';
    return "À l'instant";
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.jobDetail;

    return Scaffold(
      backgroundColor: ColorPalette.bg,
      appBar:
          const CustomAppBar(title: "Détail de l'offre", showBack: true),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeroHeader(job: job, timeAgo: _timeAgo(job.postedAt)),

                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          _InfoChip(
                            icon: Icons.workspace_premium_rounded,
                            label: job.levelRequired,
                            color: ColorPalette.teal,
                          ),
                          const SizedBox(width: 10),
                          _InfoChip(
                            icon: Icons.schedule_rounded,
                            label: '${job.minXp} ans exp.',
                            color: ColorPalette.tealDark,
                          ),
                          const SizedBox(width: 10),
                          _InfoChip(
                            icon: Icons.category_rounded,
                            label: job.category,
                            color: ColorPalette.hint,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    if (job.skillsRequired.isNotEmpty) ...[
                      _SectionTitle(icon: Icons.bolt_rounded, label: 'Compétences requises'),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: job.skillsRequired
                              .map((s) => _SkillChip(label: s))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    _SectionTitle(
                        icon: Icons.description_rounded,
                        label: 'Description du poste'),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: ColorPalette.field,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: ColorPalette.border),
                          boxShadow: [
                            BoxShadow(
                              color: ColorPalette.teal.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          job.description,
                          style: const TextStyle(
                            color: ColorPalette.text,
                            fontSize: 14.5,
                            height: 1.75,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _BottomActions(
                  onApply: _launchUrl,
                  onGenerateCv: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('🚧 Fonctionnalité bientôt disponible !'),
                        backgroundColor: ColorPalette.teal,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.job, required this.timeAgo});
  final JobOffer job;
  final String timeAgo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [ColorPalette.tealDark, ColorPalette.teal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Company badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.business_rounded,
                    size: 14, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  job.company,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Title
          Text(
            job.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),

          // Location + Date row
          Row(
            children: [
              const Icon(Icons.location_on_rounded,
                  size: 15, color: Colors.white70),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  job.location.isEmpty ? 'Localisation non précisée' : job.location,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
              ),
              const Icon(Icons.access_time_rounded,
                  size: 13, color: Colors.white54),
              const SizedBox(width: 4),
              Text(
                timeAgo,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: ColorPalette.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: ColorPalette.teal),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: ColorPalette.text,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip(
      {required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: ColorPalette.field,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ColorPalette.border),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  const _SkillChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: ColorPalette.teal.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorPalette.teal.withOpacity(0.25)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: ColorPalette.tealDark,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions(
      {required this.onApply, required this.onGenerateCv});
  final VoidCallback onApply;
  final VoidCallback onGenerateCv;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: ColorPalette.bg,
        border: Border(
            top: BorderSide(color: ColorPalette.border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.tealDark.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Générer CV
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onGenerateCv,
              icon: const Icon(Icons.auto_awesome_rounded, size: 17),
              label: const Text('Générer CV'),
              style: OutlinedButton.styleFrom(
                foregroundColor: ColorPalette.teal,
                side: const BorderSide(color: ColorPalette.teal, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Postuler
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: onApply,
              icon: const Icon(Icons.send_rounded, size: 17),
              label: const Text('Postuler maintenant'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.teal,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}