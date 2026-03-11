import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_app_bar.dart';
import '../providers/profile_provider.dart';
import '../models/profile.dart';
import './upload_cv_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ProfileRead profile;

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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Accueil", showLogout: true),
      body: const Center(child: Text("Bienvenue sur Home 🚀")),
    );
  }
}
