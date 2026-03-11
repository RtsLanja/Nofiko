import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../utils/color.dart';
import '../widgets/custom_app_bar.dart';
import 'profile_screen.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class UploadCvScreen extends StatefulWidget {
  const UploadCvScreen({super.key});

  @override
  State<UploadCvScreen> createState() => _UploadCvScreenState();
}

class _UploadCvScreenState extends State<UploadCvScreen>
    with SingleTickerProviderStateMixin {
  String? _filePath;
  String? _fileName;
  Uint8List? _fileBytes;
  bool _isAnalyzing = false;

  late AnimationController _ac;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _ac, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ac, curve: Curves.easeOut));
    _ac.forward();
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  // ── Choisir le fichier ────────────────────────────────────────────────
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      withData: kIsWeb,
    );

    if (result == null) return;
    final file = result.files.single;

    setState(() {
      _fileName = file.name;
      _filePath = kIsWeb ? null : file.path;
      _fileBytes = kIsWeb ? file.bytes : null;
    });
  }

  // ── Analyser le CV ────────────────────────────────────────────────────
  Future<void> _analyzeCV() async {

    setState(() => _isAnalyzing = true);

    try { 
      final profileProvider = Provider.of<ProfileProvider>(
        context,
        listen: false,
      );

      if (kIsWeb) {
        // Web → envoie les bytes
        await profileProvider.uploadCvBytes(_fileBytes!, _fileName!);
      } else {
        // Mobile → envoie le path
        await profileProvider.uploadCv(_filePath!);
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade900,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          content: Text(
            "Erreur : ${e.toString()}",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.bg,
      appBar: const CustomAppBar(title: "Mon CV"),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 36),

                  // ── Titre ─────────────────────────────────────────
                  const Text(
                    "Importe ton CV",
                    style: TextStyle(
                      color: ColorPalette.text,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Notre IA analyse ton CV et construit\nton profil automatiquement.",
                    style: TextStyle(
                      color: ColorPalette.hint,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // ── Zone de sélection ─────────────────────────────
                  GestureDetector(
                    onTap: _pickFile,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: _filePath != null
                            ? ColorPalette.teal.withOpacity(0.06)
                            : ColorPalette.field,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _filePath != null
                              ? ColorPalette.teal
                              : ColorPalette.border,
                          width: _filePath != null ? 1.5 : 1.2,
                        ),
                      ),
                      child: _filePath == null
                          ? _EmptyDropZone()
                          : _FilePreview(fileName: _fileName!),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Formats acceptés
                  Center(
                    child: Text(
                      "PDF, DOC, DOCX  •  Max 10 Mo",
                      style: TextStyle(
                        color: ColorPalette.hint.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // ── Bouton analyser ───────────────────────────────
                  _AnalyzeButton(
                    enabled: _filePath != null || _fileBytes != null,
                    isAnalyzing: _isAnalyzing,
                    onTap: _analyzeCV,
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Zone vide ───────────────────────────────────────────────────────────────
class _EmptyDropZone extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColorPalette.teal.withOpacity(0.10),
          ),
          child: const Icon(
            Icons.upload_file_rounded,
            color: ColorPalette.teal,
            size: 28,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "Appuie pour sélectionner",
          style: TextStyle(
            color: ColorPalette.text,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "ou glisse ton fichier ici",
          style: TextStyle(color: ColorPalette.hint, fontSize: 13),
        ),
      ],
    );
  }
}

// ─── Aperçu fichier sélectionné ──────────────────────────────────────────────
class _FilePreview extends StatelessWidget {
  const _FilePreview({required this.fileName});
  final String fileName;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColorPalette.teal.withOpacity(0.15),
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: ColorPalette.teal,
            size: 30,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          fileName,
          style: const TextStyle(
            color: ColorPalette.text,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          "Fichier prêt à être analysé",
          style: TextStyle(
            color: ColorPalette.teal.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// ─── Bouton analyser ──────────────────────────────────────────────────────────
class _AnalyzeButton extends StatelessWidget {
  const _AnalyzeButton({
    required this.enabled,
    required this.isAnalyzing,
    required this.onTap,
  });
  final bool enabled;
  final bool isAnalyzing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled && !isAnalyzing ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: enabled
              ? const LinearGradient(
                  colors: [
                    ColorPalette.tealDark,
                    ColorPalette.teal,
                    ColorPalette.tealLight,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: enabled ? null : ColorPalette.field,
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: ColorPalette.teal.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isAnalyzing
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  "Analyser avec l'IA",
                  style: TextStyle(
                    color: enabled ? Colors.white : ColorPalette.hint,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }
}
