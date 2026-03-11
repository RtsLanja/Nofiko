import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../utils/color.dart';
import '../widgets/custom_app_bar.dart';
import 'home_screen.dart';
import '../models/profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  bool _isEditing = false;

  // Controllers
  late TextEditingController _nameCtrl;
  late TextEditingController _xpCtrl;
  late TextEditingController _levelCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _skillsCtrl; 

  late AnimationController _ac;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ac       = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _ac, curve: Curves.easeOut);
    _ac.forward();

    final profile =
        Provider.of<ProfileProvider>(context, listen: false).profile;
    _initControllers(profile);
  }

  void _initControllers(ProfileRead? p) {
    _nameCtrl     = TextEditingController(text: p?.name     ?? '');
    _xpCtrl       = TextEditingController(text: p?.xp.toString() ?? '0');
    _levelCtrl    = TextEditingController(text: p?.level    ?? '');
    _locationCtrl = TextEditingController(text: p?.location ?? '');
    _skillsCtrl   = TextEditingController(
        text: (p?.skills ?? []).join(', '));
  }

  @override
  void dispose() {
    _ac.dispose();
    _nameCtrl.dispose();
    _xpCtrl.dispose();
    _levelCtrl.dispose();
    _locationCtrl.dispose();
    _skillsCtrl.dispose();
    super.dispose();
  }

  // ── Confirmer (sans modif) ────────────────────────────────────────────
  void _confirm() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  // ── Sauvegarder les modifications ─────────────────────────────────────
  Future<void> _save() async {
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);

    final skills = _skillsCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    await profileProvider.updateProfile({
      'name':     _nameCtrl.text,
      'xp':       int.tryParse(_xpCtrl.text) ?? 0,
      'level':    _levelCtrl.text,
      'location': _locationCtrl.text,
      'skills':   skills,
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ColorPalette.tealDark,
        behavior:        SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)),
        content: const Row(children: [
          Icon(Icons.check_circle_outline, color: Colors.white),
          SizedBox(width: 10),
          Text("Profil mis à jour ✓",
              style: TextStyle(color: Colors.white)),
        ]),
      ),
    );

    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final profile         = profileProvider.profile;

    return Scaffold(
      backgroundColor: ColorPalette.bg,
      appBar: CustomAppBar(
        title:    "Mon Profil",
        showBack: false,
        actions: [
          // Toggle édition
          IconButton(
            icon: Icon(
              _isEditing ? Icons.close_rounded : Icons.edit_rounded,
              color: _isEditing ? ColorPalette.hint : ColorPalette.teal,
            ),
            onPressed: () => setState(() => _isEditing = !_isEditing),
          ),
        ],
      ),
      body: profileProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: ColorPalette.teal))
          : FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── En-tête profil ──────────────────────────────
                    _ProfileHeader(
                      name:     profile?.name ?? 'Inconnu',
                      level:    profile?.level ?? 'Junior',
                      location: profile?.location ?? '',
                    ),

                    const SizedBox(height: 32),

                    // ── Section informations ────────────────────────
                    _SectionTitle(title: "Informations"),
                    const SizedBox(height: 16),

                    _isEditing
                        ? _EditForm(
                            nameCtrl:     _nameCtrl,
                            xpCtrl:       _xpCtrl,
                            levelCtrl:    _levelCtrl,
                            locationCtrl: _locationCtrl,
                            skillsCtrl:   _skillsCtrl,
                          )
                        : _ProfileInfo(profile: profile),

                    const SizedBox(height: 32),

                    // ── Skills ──────────────────────────────────────
                    if (!_isEditing) ...[
                      _SectionTitle(title: "Compétences"),
                      const SizedBox(height: 16),
                      _SkillChips(
                          skills: List<String>.from(
                              profile?.skills ?? [])),
                      const SizedBox(height: 40),
                    ],

                    // ── Boutons d'action ────────────────────────────
                    if (_isEditing)
                      _SaveButton(
                          isLoading: profileProvider.isLoading,
                          onTap:     _save)
                    else
                      _ConfirmButton(onTap: _confirm),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }
}

// ─── En-tête ─────────────────────────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.level,
    required this.location,
  });
  final String name, level, location;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColorPalette.teal.withOpacity(0.15),
            border: Border.all(color: ColorPalette.teal, width: 1.5),
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                color:      ColorPalette.teal,
                fontSize:   28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 18),

        // Nom + infos
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(
                    color:      ColorPalette.text,
                    fontSize:   20,
                    fontWeight: FontWeight.w700,
                  )),
              const SizedBox(height: 4),
              // Badge niveau
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color:        ColorPalette.teal.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: ColorPalette.teal.withOpacity(0.3)),
                ),
                child: Text(level,
                    style: const TextStyle(
                        color: ColorPalette.teal, fontSize: 12)),
              ),
              if (location.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.location_on_outlined,
                      color: ColorPalette.hint, size: 14),
                  const SizedBox(width: 4),
                  Text(location,
                      style: const TextStyle(
                          color: ColorPalette.hint, fontSize: 13)),
                ]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Titre de section ─────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 3, height: 16,
          decoration: BoxDecoration(
            color:        ColorPalette.teal,
            borderRadius: BorderRadius.circular(2),
          )),
      const SizedBox(width: 10),
      Text(title,
          style: const TextStyle(
            color:         ColorPalette.text,
            fontSize:      15,
            fontWeight:    FontWeight.w600,
            letterSpacing: 0.5,
          )),
    ]);
  }
}

// ─── Affichage des infos (mode lecture) ──────────────────────────────────────
class _ProfileInfo extends StatelessWidget {
  const _ProfileInfo({required this.profile});
  final ProfileRead? profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:     const EdgeInsets.all(20),
      decoration:  BoxDecoration(
        color:        ColorPalette.field,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorPalette.border, width: 1.2),
      ),
      child: Column(children: [
        _InfoRow(icon: Icons.person_outline,
            label: "Nom",     value: profile?.name          ?? '-'),
        _Divider(),
        _InfoRow(icon: Icons.work_outline,
            label: "Niveau",  value: profile?.level         ?? '-'),
        _Divider(),
        _InfoRow(icon: Icons.star_outline,
            label: "XP",      value: "${profile?.xp ?? 0} ans"),
        _Divider(),
        _InfoRow(icon: Icons.location_on_outlined,
            label: "Lieu",    value: profile?.location       ?? '-'),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String   label, value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Icon(icon, color: ColorPalette.teal, size: 18),
        const SizedBox(width: 12),
        Text(label,
            style: const TextStyle(
                color: ColorPalette.hint, fontSize: 13)),
        const Spacer(),
        Text(value,
            style: const TextStyle(
                color: ColorPalette.text,
                fontSize:   14,
                fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Divider(color: ColorPalette.border, height: 1);
}

// ─── Formulaire d'édition ─────────────────────────────────────────────────────
class _EditForm extends StatelessWidget {
  const _EditForm({
    required this.nameCtrl,
    required this.xpCtrl,
    required this.levelCtrl,
    required this.locationCtrl,
    required this.skillsCtrl,
  });

  final TextEditingController nameCtrl, xpCtrl, levelCtrl,
      locationCtrl, skillsCtrl;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _EditField(ctrl: nameCtrl,     label: "Nom",
          icon: Icons.person_outline),
      const SizedBox(height: 12),
      _EditField(ctrl: levelCtrl,    label: "Niveau",
          icon: Icons.work_outline),
      const SizedBox(height: 12),
      _EditField(ctrl: xpCtrl,       label: "Années d'expérience",
          icon: Icons.star_outline,
          keyboardType: TextInputType.number),
      const SizedBox(height: 12),
      _EditField(ctrl: locationCtrl, label: "Localisation",
          icon: Icons.location_on_outlined),
      const SizedBox(height: 12),
      _EditField(ctrl: skillsCtrl,   label: "Compétences (séparées par ,)",
          icon: Icons.code_rounded,
          maxLines: 3),
      const SizedBox(height: 24),
    ]);
  }
}

class _EditField extends StatelessWidget {
  const _EditField({
    required this.ctrl,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
  });

  final TextEditingController ctrl;
  final String                label;
  final IconData              icon;
  final TextInputType?        keyboardType;
  final int                   maxLines;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:        ColorPalette.field,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorPalette.border, width: 1.2),
      ),
      child: TextField(
        controller:   ctrl,
        keyboardType: keyboardType,
        maxLines:     maxLines,
        style: const TextStyle(color: ColorPalette.text, fontSize: 14),
        cursorColor:  ColorPalette.teal,
        decoration: InputDecoration(
          prefixIcon:     Icon(icon, color: ColorPalette.teal, size: 20),
          labelText:      label,
          labelStyle:     const TextStyle(
              color: ColorPalette.hint, fontSize: 13),
          border:         InputBorder.none,
          focusedBorder:  InputBorder.none,
          enabledBorder:  InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              vertical: 14, horizontal: 16),
        ),
      ),
    );
  }
}

// ─── Chips compétences ────────────────────────────────────────────────────────
class _SkillChips extends StatelessWidget {
  const _SkillChips({required this.skills});
  final List<String> skills;

  @override
  Widget build(BuildContext context) {
    if (skills.isEmpty) {
      return const Text("Aucune compétence",
          style: TextStyle(color: ColorPalette.hint));
    }
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: skills.map((skill) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color:        ColorPalette.teal.withOpacity(0.10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: ColorPalette.teal.withOpacity(0.3), width: 1),
        ),
        child: Text(skill,
            style: const TextStyle(
                color: ColorPalette.teal, fontSize: 13)),
      )).toList(),
    );
  }
}

// ─── Bouton Confirmer ─────────────────────────────────────────────────────────
class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [ColorPalette.tealDark, ColorPalette.teal,
                ColorPalette.tealLight],
            begin: Alignment.centerLeft,
            end:   Alignment.centerRight,
          ),
          boxShadow: [BoxShadow(
            color:      ColorPalette.teal.withOpacity(0.35),
            blurRadius: 20,
            offset:     const Offset(0, 8),
          )],
        ),
        child: const Center(
          child: Text("Confirmer et continuer",
              style: TextStyle(
                color:         Colors.white,
                fontSize:      16,
                fontWeight:    FontWeight.w600,
                letterSpacing: 0.5,
              )),
        ),
      ),
    );
  }
}

// ─── Bouton Sauvegarder ───────────────────────────────────────────────────────
class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.isLoading, required this.onTap});
  final bool         isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [ColorPalette.tealDark, ColorPalette.teal,
                ColorPalette.tealLight],
            begin: Alignment.centerLeft,
            end:   Alignment.centerRight,
          ),
          boxShadow: [BoxShadow(
            color:      ColorPalette.teal.withOpacity(0.35),
            blurRadius: 20,
            offset:     const Offset(0, 8),
          )],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(width: 22, height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white))
              : const Text("Sauvegarder les modifications",
                  style: TextStyle(
                    color:         Colors.white,
                    fontSize:      16,
                    fontWeight:    FontWeight.w600,
                    letterSpacing: 0.5,
                  )),
        ),
      ),
    );
  }
}