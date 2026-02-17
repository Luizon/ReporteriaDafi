import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reporteriadafi/reports/reports_page.dart';
import '../core/services/reports_service.dart';
import 'dart:async';

final newReportControllerProvider =
    AsyncNotifierProvider<NewReportController, void>(NewReportController.new);

class NewReportController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // estado inicial vacío
  }

  Future<Response?> submitReport({
    required String folio,
    required String title,
    required String description,
    required File image,
  }) async {
    state = const AsyncLoading();
    try {
      Response response = await ref.read(reportsServiceProvider).createReport(
        folio: folio,
        title: title,
        description: description,
        image: image,
      );
      ref.invalidate(myReportsProvider);
      ref.invalidate(reportsServiceProvider);
      state = const AsyncData(null);
      return response;
    } catch (e, st) {
      state = AsyncError(e, st);
    }
    return null;
  }
}