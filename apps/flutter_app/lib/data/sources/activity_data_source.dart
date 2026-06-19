import 'package:dio/dio.dart';
import '../../domain/models/user_model.dart';
import '../../core/constants/api_constants.dart';

abstract class ActivityDataSource {
  Future<List<User>> getWhoLikedMe();

  Future<List<User>> getVisitors();
}

class ActivityDataSourceImpl implements ActivityDataSource {
  final Dio dio;

  ActivityDataSourceImpl(this.dio);

  @override
  Future<List<User>> getWhoLikedMe() async {
    try {
      final response = await dio.get(ApiConstants.activityWhoLikedMe);

      final raw = response.data['users'];
      final users = (raw is List ? raw : const <dynamic>[])
          .map((u) => User.fromJson(Map<String, dynamic>.from(u as Map)))
          .toList();

      return users;
    } on DioException catch (e) {
      throw Exception('Failed to fetch who liked me: ${e.message}');
    }
  }

  @override
  Future<List<User>> getVisitors() async {
    try {
      final response = await dio.get(ApiConstants.activityVisitors);

      final raw = response.data['users'];
      final users = (raw is List ? raw : const <dynamic>[])
          .map((u) => User.fromJson(Map<String, dynamic>.from(u as Map)))
          .toList();

      return users;
    } on DioException catch (e) {
      throw Exception('Failed to fetch visitors: ${e.message}');
    }
  }
}
