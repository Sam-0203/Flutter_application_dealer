import 'package:flutter/material.dart';
import 'package:dealershub_/src/services/state_and_cities.dart';
import 'package:dealershub_/src/models/regester%20forms/state_model.dart';
import 'package:dealershub_/src/models/regester%20forms/cities_model.dart';
import 'package:dealershub_/src/utils/helper/error_message_helper.dart';

// ViewModel to manage states
class StateViemodel extends ChangeNotifier {
  final StateServices _stateServices = StateServices();

  bool isLoading = false;
  String? error;
  List<StateDatum> stateslist = [];

  Future<void> fetchStates() async {
    print('Fetching states...');
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _stateServices.fetchStates();
      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final states = statesListFromJson(response.body);
        stateslist = states.data;
        print('States loaded: ${stateslist.length}');
      } else {
        error = 'Failed to load states';
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

// ViewModel to manage cities
class CitiesViemodel extends ChangeNotifier {
  final CitiesServices _citiesServices = CitiesServices();

  bool isLoading = false;
  String? error;
  List<CitiesDatum> citieslist = [];

  Future<void> fetchCitiesByState(int stateId) async {
    isLoading = true;
    citieslist = [];
    notifyListeners();

    try {
      final response = await _citiesServices.fetchCities(stateId);

      if (response.statusCode == 200) {
        final cities = citiesListFromJson(response.body);
        citieslist = cities.data;
      } else {
        error = 'Failed to load cities';
      }
    } catch (e) {
      error = ErrorMessageHelper.userMessage(e);
    }

    isLoading = false;
    notifyListeners();
  }

  void clearCities() {
    citieslist = [];
    notifyListeners();
  }
}
