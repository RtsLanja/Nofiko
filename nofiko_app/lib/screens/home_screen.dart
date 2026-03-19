import 'package:flutter/material.dart';
import 'package:nofiko_app/utils/color.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_app_bar.dart';
import '../providers/profile_provider.dart';
import '../providers/job_matched_provider.dart';
import '../models/profile.dart';
import './upload_cv_screen.dart';
import '../widgets/job_match_card.dart';
import 'job_detail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ProfileRead profile;
  bool _isCheckingProfile = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkProfile();
    });
  }

  void _checkProfile() async {
    if (!mounted) return;
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    if (!mounted) return;
    await profileProvider.fetchProfile();
    if (profileProvider.profile == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UploadCvScreen()),
      );
    } else {
      print("Profile loaded: ${profileProvider.profile!.name}");
      Provider.of<JobMatchedProvider>(context, listen: false).fetchMatches();
      if (mounted) setState(() => _isCheckingProfile = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobMatchedProvider>(context);

    if (_isCheckingProfile) {
      return Scaffold(
        backgroundColor: ColorPalette.bg,
        body: const Center(
          child: CircularProgressIndicator(color: ColorPalette.teal),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ColorPalette.bg,
      appBar: const CustomAppBar(
        title: "Nofiko",
        showLogout: true,
        showLogo: true,
      ),
      body: jobProvider.isLoading
          // ── Chargement ────────────────────────────────────────────
          ? const Center(
              child: CircularProgressIndicator(color: ColorPalette.teal),
            )
          // ── Erreur ────────────────────────────────────────────────
          : jobProvider.error != null
          ? _ErrorState(onRetry: () => jobProvider.fetchMatches())
          // ── Liste vide ────────────────────────────────────────────
          : jobProvider.matches.isEmpty
          ? const _EmptyState()
          // ── Liste des matches ─────────────────────────────────────
          : RefreshIndicator(
              color: ColorPalette.teal,
              backgroundColor: ColorPalette.field,
              onRefresh: () => jobProvider.fetchMatches(),
              child: CustomScrollView(
                slivers: [
                  // ── En-tête ──────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Offres pour toi",
                            style: TextStyle(
                              color: ColorPalette.text,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${jobProvider.matches.length} correspondance${jobProvider.matches.length > 1 ? 's' : ''} trouvée${jobProvider.matches.length > 1 ? 's' : ''}",
                            style: const TextStyle(
                              color: ColorPalette.hint,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Filtre par score
                          _ScoreFilter(
                            selected: jobProvider.scoreFilter,
                            onChanged: (v) => jobProvider.setScoreFilter(v),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Cards ────────────────────────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final match = jobProvider.filteredMatches[index];
                        return JobMatchCard(
                          match: match,
                          onTap: () => {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => JobDetailScreen(jobDetail: match.jobOffer),
                              ),
                            ),
                          },
                        );
                      }, childCount: jobProvider.filteredMatches.length),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            ),
    );
  }
}

// ─── Filtre par score ─────────────────────────────────────────────────────────
class _ScoreFilter extends StatelessWidget {
  const _ScoreFilter({required this.selected, required this.onChanged});
  final String selected;
  final ValueChanged<String> onChanged;

  static const _filters = [
    {'label': 'Tous', 'value': 'all'},
    {'label': '75+', 'value': 'high'},
    {'label': '50–74', 'value': 'mid'},
    {'label': '< 50', 'value': 'low'},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((f) {
          final isSelected = selected == f['value'];
          return GestureDetector(
            onTap: () => onChanged(f['value']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? ColorPalette.teal : ColorPalette.field,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? ColorPalette.teal : ColorPalette.border,
                ),
              ),
              child: Text(
                f['label']!,
                style: TextStyle(
                  color: isSelected ? Colors.white : ColorPalette.hint,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── État vide ────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ColorPalette.teal.withOpacity(0.10),
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: ColorPalette.teal,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Aucune offre trouvée",
            style: TextStyle(
              color: ColorPalette.text,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Complète ton profil pour\ntrouver de meilleures offres",
            textAlign: TextAlign.center,
            style: TextStyle(color: ColorPalette.hint, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ─── État erreur ──────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            color: ColorPalette.hint,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            "Impossible de charger\nles offres",
            textAlign: TextAlign.center,
            style: TextStyle(color: ColorPalette.text, fontSize: 16),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: ColorPalette.teal),
              ),
              child: const Text(
                "Réessayer",
                style: TextStyle(
                  color: ColorPalette.teal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
