import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:campusflow_app/core/api_config.dart';

/// Le client HTTP, configuré une seule fois pour toute l'application.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: adresseApi(),
    connectTimeout: const Duration(seconds: 5), // délai max avant d'abandonner
    receiveTimeout: const Duration(seconds: 10),
  ));
  ref.onDispose(dio.close);
  return dio;
});
