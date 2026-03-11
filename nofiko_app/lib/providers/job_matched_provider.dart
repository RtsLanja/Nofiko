import 'package:flutter/material.dart';
import '../models/job_matched.dart';
import '../services/job_matched_service.dart';

class JobMatchedProvider extends ChangeNotifier {
  final JobMatchedService _service;
  JobMatchedProvider(this._service);

  List<JobMatch> matches = [];
  bool isLoading = false;
  String? error;
  String scoreFilter = 'all';

  List<JobMatch> get filteredMatches {
    switch (scoreFilter) {
      case 'high': return matches.where((m) => m.score >= 75).toList();
      case 'mid':  return matches.where((m) => m.score >= 50 && m.score < 75).toList();
      case 'low':  return matches.where((m) => m.score < 50).toList();
      default:     return matches;
    }
  }

  void setScoreFilter(String filter) {
    scoreFilter = filter;
    notifyListeners();
  }

  Future<void> fetchMatches() async {
    isLoading = true;
    notifyListeners();
    try {
      matches = await _service.getMyMatches();
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
