import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reportesapp/core/utils/dio_client.dart';
import '../models/report.dart';

final reportsServiceProvider = Provider<ReportsService>((ref) => ReportsService());

class ReportsService {
  // se usa createHttp para bypassear la seguridad de android por certificado https en localhost
  // esto NO DEBE LLEGAR A PRODUCCIÓN
  final Dio _dio = DioClient.createHttp("/Reports");

  Future<Response> createReport({
    required String folio,
    required String title,
    required String description,
    required File image,
  }) async {
    final formData = FormData.fromMap({
      'Folio': folio,
      'Title': title,
      'Description': description,
      'File': await MultipartFile.fromFile(image.path,
          filename: image.path.split('/').last),
    });

    final response = await _dio.post('/', data: formData);

    return response;
  }

  Future<List<Report>> getMyReports() async {
    final response = await _dio.get('/my');
    if (response.statusCode == 200) {
      final data = response.data as List;
      return data.map((json) => Report.fromJson(json)).toList();
    } else {
      throw Exception("Error al cargar reportes: ${response.statusCode}");
    }
  }

}