import '../sources/activity_data_source.dart';
import '../../domain/models/user_model.dart';

abstract class ActivityRepository {
  Future<List<User>> getWhoLikedMe();

  Future<List<User>> getVisitors();
}

class ActivityRepositoryImpl implements ActivityRepository {
  final ActivityDataSource dataSource;

  ActivityRepositoryImpl(this.dataSource);

  @override
  Future<List<User>> getWhoLikedMe() => dataSource.getWhoLikedMe();

  @override
  Future<List<User>> getVisitors() => dataSource.getVisitors();
}
