import 'package:dio/dio.dart';
import '../models/job_matched.dart';

class JobMatchedService {
  final Dio _dio;
  JobMatchedService(this._dio);

  Future<List<JobMatch>> getMyMatches() async {
    final response = await _dio.get('/match/my-matches');
    return (response.data as List)
        .map((json) => JobMatch.fromJson(json))
        .toList();
  }
}