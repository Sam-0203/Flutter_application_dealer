import 'package:dealershub_/src/models/regester%20forms/languages_model.dart';
import 'package:dealershub_/src/services/user_service.dart';
import 'package:dealershub_/src/utils/helper/error_message_helper.dart';
import 'package:flutter/material.dart';

class LanguageViewModel extends ChangeNotifier {
  final LanguageService _languageService = LanguageService();

  bool isLoading = false;
  String? error;
  List<Datum> languages = [];

  Future<void> fetchLanguages() async {
    print('Fetching languages...');
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _languageService.fetchLanguages();
      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final langs = languagesFromJson(response.body);
        languages = langs.data;
        print('Languages loaded: ${languages.length}');
      } else {
        error = 'Failed to load languages';
        print('Error: $error');
      }
    } catch (e) {
      error = ErrorMessageHelper.userMessage(e);
      print('Exception: $error');
    }

    isLoading = false;
    notifyListeners();
  }
}
