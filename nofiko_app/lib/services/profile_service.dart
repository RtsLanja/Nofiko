import 'package:dio/dio.dart';
import '../models/profile.dart';
import 'dart:typed_data';

class ProfileService {
  final Dio _dio;

  ProfileService(this._dio);

  Future<ProfileRead> getMyProfile() async {
    final response = await _dio.get('/profile/');
    return ProfileRead.fromJson(response.data);
  }

  Future<Map<String, dynamic>> uploadCv(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: filePath.split('/').last,
      ),
    });

    final response = await _dio.post(
      '/profile/upload-cv',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    return response.data;
  }

  Future<Map<String, dynamic>> uploadCvBytes(
    Uint8List bytes,
    String fileName,
  ) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
    });
    final response = await _dio.post('/profile/upload-cv', data: formData);
    return response.data;
  }

  Future<ProfileRead> updateProfile(Map<String, dynamic> data) async {
    print("Updating profile with data: $data");
    final response = await _dio.put('/profile/', data: data);
    return ProfileRead.fromJson(response.data);
  }
}
