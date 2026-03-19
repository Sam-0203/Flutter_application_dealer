import 'dart:convert';

import 'package:dealershub_/src/models/add%20car/PostCarRequestModel.dart';
import 'package:dealershub_/src/models/add%20car/agent_fav_model.dart';
import 'package:dealershub_/src/models/add%20car/agent_remove_fav_model.dart';
import 'package:dealershub_/src/models/add%20car/car_details_model.dart';
import 'package:dealershub_/src/models/add%20car/car_fav_dealer_model.dart';
import 'package:dealershub_/src/models/add%20car/car_remove_fav_model.dart';
import 'package:dealershub_/src/models/add%20car/car_update_request_model.dart';
import 'package:dealershub_/src/models/add%20car/car_update_response_model.dart';
import 'package:dealershub_/src/models/add%20car/list_of_car_details_model.dart';
import 'package:dealershub_/src/models/add%20car/my_inventry_model.dart';
import 'package:dealershub_/src/models/add%20car/my_inventry_search_model.dart';
import 'package:dealershub_/src/models/add%20car/search_details_model.dart';
import 'package:dealershub_/src/utils/api_urls.dart';
import 'package:dealershub_/src/utils/helper/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// For Car Companies ====>
class CarCompanies {
  Future<http.Response> fetchCarCompanies() async {
    return await http.get(Uri.parse(ApiUrls.carCompany));
  }
}

// For Car Models ====>
class CarModels {
  Future<http.Response> fetchCarModels(int brandId) async {
    final url = '${ApiUrls.carModels}$brandId';
    return await http.get(Uri.parse(url));
  }
}

// For Car Fueltypes ====>
class CarFuelTypes {
  Future<http.Response> fetchCarFuelType() async {
    return await http.get(Uri.parse(ApiUrls.carFuelType));
  }
}

// For Car Transmission types ====>
class CarTrasmissionTypes {
  Future<http.Response> fetchCarTransmissionType() async {
    return await http.get(Uri.parse(ApiUrls.carTrasmissionTypes));
  }
}

// For Car Vrients types ====>
class CarVarientsTypes {
  Future<http.Response> fetchCarModelsVarients(int modelId) async {
    final url = '${ApiUrls.carVarietsTypes}$modelId';
    return await http.get(Uri.parse(url));
  }
}

// For Car Colors ====>
class CarColors {
  Future<http.Response> fetchedCarColors(int variantId) async {
    final url = '${ApiUrls.carColors}$variantId';
    return await http.get(Uri.parse(url));
  }
}

// For Car RTOs ====>
class CarRTOsRegistration {
  Future<http.Response> fetchCarRTOs() async {
    return await http.get(Uri.parse(ApiUrls.carRTOs));
  }
}

// For Car RTOs ====>
class CarNoofOwners {
  Future<http.Response> fetchOwners() async {
    return await http.get(Uri.parse(ApiUrls.carNumOfOwners));
  }
}

// <===== : Car Features : =====>

// For Safety Features : ====>
class SafetyFeatures {
  Future<http.Response> fetchSafetyFeatures() async {
    return await http.get(Uri.parse(ApiUrls.carSafetyFeatures));
  }
}

// For comfort Features : ====>
class ComfortConveience {
  Future<http.Response> fetchComfortFeatures() async {
    return await http.get(Uri.parse(ApiUrls.carComfort));
  }
}

// For carInfotainment Features : ====>
class CarInfotainment {
  Future<http.Response> fetchedCarInfotainment() async {
    return await http.get(Uri.parse(ApiUrls.carInfotainment));
  }
}

// For Interior Features : ====>
class CarInterior {
  Future<http.Response> fetchedInteriorFeatures() async {
    return await http.get(Uri.parse(ApiUrls.carInterior));
  }
}

// For Exterior Features : ====>
class CarExterior {
  Future<http.Response> fetchedExteriorFeatures() async {
    return await http.get(Uri.parse(ApiUrls.carExterior));
  }
}

// For Car posting : ====>
class PostCarService {
  Future<Map<String, dynamic>> postCar(PostCarRequestModel model) async {
    final token = await SecureStorage.getToken();

    final request = await model.toMultipartRequest(ApiUrls.postaNewCar);

    // 🔐 Headers if needed
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token', // if required
    });
    debugPrint('token : Bearer $token');

    // 🔍 DEBUG: Log request details
    debugPrint('📤 REQUEST URL: ${request.url}');
    debugPrint('📤 REQUEST FIELDS:');
    request.fields.forEach((key, value) {
      debugPrint(
        '  $key: ${value.length > 100 ? value.substring(0, 100) + '...' : value}',
      );
    });
    debugPrint('📤 REQUEST FILES: ${request.files.length} files');
    request.files.forEach((file) {
      debugPrint('  - ${file.field}: ${file.filename} (${file.contentType})');
    });

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    final contentType = response.headers['content-type'] ?? '';

    if (contentType.contains('application/json')) {
      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return decoded;
      } else {
        throw Exception(decoded['message'] ?? 'Failed to post car');
      }
    } else {
      // HTML or text error from backend
      debugPrint('❌ Server Error (${response.statusCode})');
      debugPrint(response.body);
      throw Exception('Server error ${response.statusCode}');
    }
  }
}

// For Car Details based on the TOKEN : ====>
class CarDetailsService {
  Future<MyInventryCarDetailsResponse> fetchedDealerCarDetails() async {
    final token = await SecureStorage.getToken();
    final uri = Uri.parse(ApiUrls.myPostDeatils);

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return myInventryCarDetailsResponseFromJson(response.body);
    } else {
      throw Exception('Failed to load car details (${response.statusCode})');
    }
  }
}

// For Car Details based on the car id : ====>
class SingleCarDetailsService {
  Future<CarDetailsResponse> fetchCarDetails(int carId) async {
    final token = await SecureStorage.getToken(); // TOKEN getting
    final uri = Uri.parse('${ApiUrls.carDetails}$carId');

    debugPrint('🔍 Fetching car details from: $uri');
    debugPrint(
      '🔐 Using token: Bearer ${token?.substring(0, 20) ?? 'NO TOKEN'}...',
    );

    try {
      final response = await http
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () =>
                throw Exception('Request timeout - Check internet connection'),
          );

      debugPrint('📥 Response Status Code: ${response.statusCode}');
      debugPrint('📥 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = carDetailsResponseFromJson(response.body);
        debugPrint('✅ Successfully parsed car details');
        return parsed;
      } else if (response.statusCode == 401) {
        throw Exception(
          'Unauthorized - Token may be expired. Please login again.',
        );
      } else if (response.statusCode == 404) {
        throw Exception('Car not found (ID: $carId)');
      } else {
        throw Exception(
          'Server error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('❌ Error fetching car details: $e');
      rethrow;
    }
  }
}

// For Car Deletion based on the car id : ====>
class DeleteCarService {
  Future<bool> deleteCar(int carId) async {
    final token = await SecureStorage.getToken();
    final uri = Uri.parse(ApiUrls.deleteCar);

    final response = await http.delete(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'car_id': carId.toString()},
    );

    debugPrint('🔍 Delete Response Status: ${response.statusCode}');
    debugPrint('🔍 Delete Response Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);

      if (decoded['status'] == true) {
        return true;
      } else {
        throw Exception(decoded['message'] ?? "Delete failed");
      }
    } else {
      final decoded = jsonDecode(response.body);
      throw Exception(
        decoded['message'] ?? 'Failed to delete car (${response.statusCode})',
      );
    }
  }
}

// For cars display ListOfCarsService based on token: ====>
class ListOfCarsService {
  Future<ListOfCarDetailsResponse> fetchListOfCars() async {
    final token = await SecureStorage.getToken();
    final uri = Uri.parse(ApiUrls.listOfCars);

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    debugPrint('ListOfCars status: ${response.statusCode}');
    debugPrint('ListOfCars response: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        return listOfCarDetailsResponseFromJson(response.body);
      } catch (e) {
        throw Exception('Failed to parse list of cars response: $e');
      }
    }

    if (response.statusCode == 401) {
      throw Exception('Unauthorized - please login again');
    }

    throw Exception('Failed to load list of cars (${response.statusCode})');
  }
}

// For search based (Token) on query : ====>
class SearchCarService {
  Future<SearchDetailsResponse> searchCars(String query) async {
    final token = await SecureStorage.getToken();
    final uri = Uri.parse(
      ApiUrls.search,
    ).replace(queryParameters: {'search': query});

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    debugPrint('Search status: ${response.statusCode}');
    debugPrint('Search response: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        return searchDetailsResponseFromJson(response.body);
      } catch (e) {
        throw Exception('Failed to parse search response: $e');
      }
    }

    throw Exception('Failed to search cars (${response.statusCode})');
  }
}

// For my inventory search based (Token) on query : ====>
class MyInvetrySearchCarService {
  Future<MyInventrySearchResponse> searchCars(String query) async {
    final token = await SecureStorage.getToken();
    final uri = Uri.parse(
      ApiUrls.myCarsSearch,
    ).replace(queryParameters: {'search': query});

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    debugPrint('Search status: ${response.statusCode}');
    debugPrint('Search response: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        return myInventrySearchResponseFromJson(response.body);
      } catch (e) {
        throw Exception('Failed to parse search response: $e');
      }
    }

    throw Exception('Failed to search cars (${response.statusCode})');
  }
}

// For fetching all car models : ====>
class AllCarModelsService {
  Future<http.Response> fetchAllCarModels() async {
    return await http.get(Uri.parse(ApiUrls.allCarModels));
  }
}

// For fetching all car models : ====>
class FilterCarService {
  Future<dynamic> fetchFilteredCars({
    List<int>? ownerTypeIds,
    List<int>? brandIds,
    List<int>? fuelTypeIds,
    List<int>? modelIds,
  }) async {
    final token = await SecureStorage.getToken();

    final queryParams = {
      if (ownerTypeIds != null && ownerTypeIds.isNotEmpty)
        "owner_type_id": ownerTypeIds.join(','),
      if (brandIds != null && brandIds.isNotEmpty)
        "brand_id": brandIds.join(','),
      if (fuelTypeIds != null && fuelTypeIds.isNotEmpty)
        "fuel_type_id": fuelTypeIds.join(','),
      if (modelIds != null && modelIds.isNotEmpty)
        "model_id": modelIds.join(','),
    };

    final uri = Uri.parse(ApiUrls.filter).replace(queryParameters: queryParams);
    debugPrint('Filter URI : $uri');

    final response = await http.get(
      uri,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      debugPrint('Response : ${response.body}');
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch filtered cars: ${response.body}");
    }
  }
}

// For updating car features using PUT : ====>
class UpdateCarFeaturesService {
  Future<CarUpdateResponse> updateCar(CarUpdateRequestModel model) async {
    if (model.carId == null || model.carId == 0) {
      throw Exception('Car ID is required');
    }

    final token = await SecureStorage.getToken();
    final uri = Uri.parse(ApiUrls.updateCarDetails);

    debugPrint('📤 Update Request - URL: $uri');
    debugPrint('📤 Update Request - CarId: ${model.carId}');
    debugPrint(
      '📤 Update Request - Safety Features: ${model.safetyFeatureIds}',
    );
    debugPrint(
      '📤 Update Request - Comfort Features: ${model.comfortFeatureIds}',
    );
    debugPrint(
      '📤 Update Request - Infotainment Features: ${model.infotainmentFeatureIds}',
    );
    debugPrint(
      '📤 Update Request - Interior Features: ${model.interiorFeatureIds}',
    );
    debugPrint(
      '📤 Update Request - Exterior Features: ${model.exteriorFeatureIds}',
    );

    // Use MultipartRequest for proper form-data handling with arrays
    var request = http.MultipartRequest('PUT', uri);

    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    // Add car_id
    request.fields['car_id'] = model.carId.toString();

    // Add feature IDs as array fields
    if (model.safetyFeatureIds != null && model.safetyFeatureIds!.isNotEmpty) {
      for (int id in model.safetyFeatureIds!) {
        request.fields['safety_feature_ids[]'] = id.toString();
      }
    }
    if (model.comfortFeatureIds != null &&
        model.comfortFeatureIds!.isNotEmpty) {
      for (int id in model.comfortFeatureIds!) {
        request.fields['comfort_feature_ids[]'] = id.toString();
      }
    }
    if (model.infotainmentFeatureIds != null &&
        model.infotainmentFeatureIds!.isNotEmpty) {
      for (int id in model.infotainmentFeatureIds!) {
        request.fields['infotainment_feature_ids[]'] = id.toString();
      }
    }
    if (model.interiorFeatureIds != null &&
        model.interiorFeatureIds!.isNotEmpty) {
      for (int id in model.interiorFeatureIds!) {
        request.fields['interior_feature_ids[]'] = id.toString();
      }
    }
    if (model.exteriorFeatureIds != null &&
        model.exteriorFeatureIds!.isNotEmpty) {
      for (int id in model.exteriorFeatureIds!) {
        request.fields['exterior_feature_ids[]'] = id.toString();
      }
    }

    // Add other_details if it exists
    if (model.otherDetails != null) {
      request.fields['other_details'] = jsonEncode(
        model.otherDetails!.toJson(),
      );
    }

    debugPrint('📤 Request Fields: ${request.fields}');

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    debugPrint('🔍 Update Response Status: ${response.statusCode}');
    debugPrint('🔍 Update Response Body: $responseBody');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return carUpdateResponseFromJson(responseBody);
    } else {
      throw Exception(responseBody);
    }
  }
}

// For updating car Images using PUT : ====>
class UpdateCarImagesService {
  Future<bool> addCarImages(int carId, List<String> imagePaths) async {
    final token = await SecureStorage.getToken();
    final uri = Uri.parse(ApiUrls.carAddImagesAfterUpdate);

    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      })
      ..fields['car_id'] = carId.toString();

    for (int i = 0; i < imagePaths.length; i++) {
      request.files.add(
        await http.MultipartFile.fromPath('image[${i + 1}]', imagePaths[i]),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Failed to add images: ${response.body}');
    }
  }
}

// For deleting car images after updating a car : ====>
class DeleteCarImageService {
  Future<bool> deleteCarImages({
    required int carId,
    required List<int> imageIds,
  }) async {
    final token = await SecureStorage.getToken();
    final uri = Uri.parse(ApiUrls.carDeleteImagesAfterUpdate);

    final request = http.MultipartRequest('DELETE', uri)
      ..headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      })
      ..fields['car_id'] = carId.toString();

    for (var id in imageIds) {
      request.fields['image_id'] = id.toString();
    }

    final response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw Exception("Failed to delete images");
    }
  }
}

// For posting a car favorite : ====>

// For fetching all favorite cars Dealer : ====>
class DealerFavoriteCarsService {
  Future<FavoriteCarsResponse> fetchDealerFavoriteCars() async {
    final token = await SecureStorage.getToken();
    final uri = Uri.parse(ApiUrls.getDealerFavCar);

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return favoriteCarsResponseFromJson(response.body);
    } else {
      throw Exception('Failed to load favorite cars (${response.statusCode})');
    }
  }
}

// For fetching all favorite cars Agents : ====>
class AgentFavoriteCarsService {
  Future<AgentFavoriteCarsResponse> fetchAgentFavoriteCars() async {
    final token = await SecureStorage.getToken();
    final uri = Uri.parse(ApiUrls.getAgentFavCar);

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return agentFavoriteCarsResponseFromJson(response.body);
    } else {
      throw Exception('Failed to load favorite cars (${response.statusCode})');
    }
  }
}

// For adding a car to favorite using token and car_id Dealers : ====>
class AddFavirateCarService {
  Future<FavoriteCarsResponse> addToFavorite(int carId) async {
    final token = await SecureStorage.getToken();

    final uri = Uri.parse(ApiUrls.addToFav);

    final response = await http.post(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      body: {'car_id': carId.toString()},
    );

    debugPrint('Add to Favorite Response Status: ${response.statusCode}');
    debugPrint('Add to Favorite Response Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return FavoriteCarsResponse.fromJson(data);
    } else {
      throw Exception(
        "Failed to add favorite - Status: ${response.statusCode}, Body: ${response.body}",
      );
    }
  }
}

// For removing a car from favorite using token and car_id Dealers : ====>
class RemoveCarFromFavService {
  Future<RemovedFavoriteCarsResponse> removeCarFromFavorite(int carId) async {
    final token = await SecureStorage.getToken();

    final uri = Uri.parse(ApiUrls.deleteFromFav);

    final response = await http.delete(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      body: {'car_id': carId.toString()},
    );

    debugPrint('Remove from Favorite Response Status: ${response.statusCode}');
    debugPrint('Remove from Favorite Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return RemovedFavoriteCarsResponse.fromJson(data);
    } else {
      throw Exception(
        "Failed to remove favorite - Status: ${response.statusCode}, Body: ${response.body}",
      );
    }
  }
}

// For adding a car to favorite using token and car_id Agents : ====>
class AddToFavCarsAgent {
  Future<AgentFavoriteCarsResponse> addToFavorite(int carId) async {
    final token = await SecureStorage.getToken();

    final uri = Uri.parse(ApiUrls.addToFavAgent);

    final response = await http.post(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      body: {'car_id': carId.toString()},
    );

    debugPrint('Add to Favorite Response Status: ${response.statusCode}');
    debugPrint('Add to Favorite Response Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return AgentFavoriteCarsResponse.fromJson(data);
    } else {
      throw Exception(
        "Failed to add favorite - Status: ${response.statusCode}, Body: ${response.body}",
      );
    }
  }
}

// For removing a car from favorite using token and car_id Agents fom form-data : ====>
class RemoveFavCarsFroAgent {
  Future<RemoveAgentFavoriteCarsResponse> removeCarFromFavorite(
    int carId,
  ) async {
    final token = await SecureStorage.getToken();

    final uri = Uri.parse(ApiUrls.deleteFromFavAgent);

    final response = await http.delete(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      body: {'car_id': carId.toString()},
    );

    debugPrint(
      'Remove from Agent Favorite Response Status: ${response.statusCode}',
    );
    debugPrint('Remove from Agent Favorite Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return RemoveAgentFavoriteCarsResponse.fromJson(data);
    } else {
      throw Exception(
        "Failed to remove Agent favorite - Status: ${response.statusCode}, Body: ${response.body}",
      );
    }
  }
}
