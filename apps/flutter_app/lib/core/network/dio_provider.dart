import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'dio_client.dart';

final dioProvider = FutureProvider<Dio>((ref) async {
  return await DioClient.initialize();
});
