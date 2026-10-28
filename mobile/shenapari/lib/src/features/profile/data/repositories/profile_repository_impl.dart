import 'package:flutter/cupertino.dart';
import 'package:shenapari/src/features/profile/data/models/update_name_request.dart';

import '../data_sources/remote/profile_api_service.dart';

class ProfileRepositoryImpl {
  final ProfileApiService _apiService;

  ProfileRepositoryImpl({required ProfileApiService apiService})
    : _apiService = apiService;

  Future<void> test() async {
    final response = await _apiService.updateName(
      UpdateNameRequest(fullName: "Vlad"),
    );
    debugPrint("Response: $response");
  }
}
