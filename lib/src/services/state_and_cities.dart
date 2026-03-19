import 'package:dealershub_/src/utils/api_urls.dart';
import 'package:http/http.dart' as http;

// States Service to fetch states
class StateServices {
  Future<http.Response> fetchStates() async {
    final response = await http.get(Uri.parse(ApiUrls.states));
    return response;
  }
}

// Cities Service to fetch cities
class CitiesServices {
  Future<http.Response> fetchCities(int stateId) async {
    final url = "${ApiUrls.cities}$stateId";
    return await http.get(Uri.parse(url));
  }
}

