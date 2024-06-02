import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'db_helper.dart';

final databaseProvider = Provider((ref) => DatabaseHelper());

final getAllDataProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) async* {
  final databaseHelper = DatabaseHelper.instance;
  yield* Stream.periodic(Duration(seconds: 1), (_) async {
    return await databaseHelper.fetchData();
  }).asyncMap((event) async => await event);
});
