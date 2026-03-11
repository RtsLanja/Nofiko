import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import '../models/profile.dart';
import 'dart:typed_data';

// providers/profile_provider.dart

class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService;

  ProfileProvider(this._profileService);

  ProfileRead? profile;  
  bool isLoading = false;

  Future<void> fetchProfile() async {
    isLoading = true;
    notifyListeners();
    try {
      profile = await _profileService.getMyProfile();
    } catch (_) {
      profile = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> uploadCv(String filePath) async {
    isLoading = true;
    notifyListeners();
    try {
      await _profileService.uploadCv(filePath);
      await fetchProfile();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> uploadCvBytes(Uint8List bytes, String fileName) async {
  isLoading = true;
  notifyListeners();
  try {
    await _profileService.uploadCvBytes(bytes, fileName);
    await fetchProfile();
  } finally {
    isLoading = false;
    notifyListeners();
  }
}

  Future<void> updateProfile(Map<String, dynamic> data) async {
    isLoading = true;
    notifyListeners();
    try {
      profile = await _profileService.updateProfile(data);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}