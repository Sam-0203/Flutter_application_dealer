import 'package:dealershub_/src/models/add%20car/PostCarRequestModel.dart';
import 'package:dealershub_/src/models/add%20car/agent_fav_model.dart'
    hide CarImage;
import 'package:dealershub_/src/models/add%20car/all_carModel_model.dart';
import 'package:dealershub_/src/models/add%20car/car_RTO_model.dart';
import 'package:dealershub_/src/models/add%20car/car_color_model.dart';
import 'package:dealershub_/src/models/add%20car/car_company_model.dart';
import 'package:dealershub_/src/models/add car/car_models_model.dart';
import 'package:dealershub_/src/models/add%20car/car_details_model.dart'
    as car_details;
import 'package:dealershub_/src/models/add%20car/car_exterior_model.dart';
import 'package:dealershub_/src/models/add%20car/car_fav_dealer_model.dart';
import 'package:dealershub_/src/models/add%20car/car_infotainment_model.dart';
import 'package:dealershub_/src/models/add%20car/car_interior_model.dart';
import 'package:dealershub_/src/models/add%20car/car_no_of_owners.dart';
import 'package:dealershub_/src/models/add%20car/car_update_request_model.dart';
import 'package:dealershub_/src/models/add%20car/car_update_response_model.dart';
import 'package:dealershub_/src/models/add%20car/car_varients_model.dart';
import 'package:dealershub_/src/models/add%20car/comfort_model.dart';
import 'package:dealershub_/src/models/add%20car/fuel_type_model.dart';
import 'package:dealershub_/src/models/add%20car/list_of_car_details_model.dart'
    hide CarImage;
import 'package:dealershub_/src/models/add%20car/my_inventry_model.dart';
import 'package:dealershub_/src/models/add%20car/my_inventry_search_model.dart';
import 'package:dealershub_/src/models/add%20car/safety_model.dart';
import 'package:dealershub_/src/models/add%20car/search_details_model.dart';
import 'package:dealershub_/src/models/add%20car/transmission_model.dart';
import 'package:dealershub_/src/services/add_car_services.dart';
import 'package:dealershub_/src/utils/helper/error_message_helper.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

// Get car companies : ====>
class CarCompaniesListView extends ChangeNotifier {
  final CarCompanies _carCompanies = CarCompanies();

  bool isLoading = false;
  String? error;
  List<DatumCarCompanies> carCompany = [];

  Future<void> fetchCarCompanies() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final carCompaniesResponse = await _carCompanies.fetchCarCompanies();

      debugPrint('car Companies Response: ${carCompaniesResponse.body}');

      if (carCompaniesResponse.statusCode == 200) {
        final CarCompaniesResponse parsed = carCompaniesResponseFromJson(
          carCompaniesResponse.body,
        );

        carCompany = parsed.data; // ✅ THIS IS THE LIST YOU NEED
      } else {
        error = 'Failed with status code: ${carCompaniesResponse.statusCode}';
      }
    } catch (e) {
      error = ErrorMessageHelper.userMessage(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

// Get car models based on Car - company: ====>
class CarModelsListView extends ChangeNotifier {
  final CarModels _carModels = CarModels();

  bool isLoading = false;
  String? error;
  List<DatumCarModels> carModels = [];

  Future<void> fetchCarModels({required int brandId}) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _carModels.fetchCarModels(brandId);
      debugPrint('Car models Response : ${response.body}');

      if (response.statusCode == 200) {
        final parsed = carModelsResponseFromJson(response.body);
        carModels = parsed.data;
      } else {
        error = 'Status code: ${response.statusCode}';
      }
    } catch (e) {
      error = ErrorMessageHelper.userMessage(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Clear old models when brand changes
  void clear() {
    carModels = [];
    notifyListeners();
  }
}

// Get car Fuel Types : ====>
class CarFueltypeListView extends ChangeNotifier {
  final CarFuelTypes _carFuelTypes = CarFuelTypes();
  static const String defaultFuelChipColorCode = '#E0E0E0';

  bool isLoading = false;
  String? error;
  List<FuelTypeDatum> carFuelTypes = [];
  Map<String, String> _fuelTypeColorCodeMap = {};

  String fuelTypeColorCode(String fuelTypeName) {
    final normalizedFuelType = fuelTypeName.trim().toLowerCase();
    if (normalizedFuelType.isEmpty) return defaultFuelChipColorCode;

    final apiColor = _fuelTypeColorCodeMap[normalizedFuelType];
    if (apiColor != null && apiColor.trim().isNotEmpty) {
      return apiColor;
    }

    return defaultFuelChipColorCode;
  }

  String _normalizeHexColorCode(String colorCode) {
    final raw = colorCode.trim();
    if (raw.isEmpty) return defaultFuelChipColorCode;

    var value = raw;
    if (value.startsWith('0x') || value.startsWith('0X')) {
      value = value.substring(2);
    }

    if (!value.startsWith('#')) {
      value = '#$value';
    }

    if (value.length == 7 || value.length == 9) {
      return value.toUpperCase();
    }

    return defaultFuelChipColorCode;
  }

  Future<void> fetchCarFuelTypes() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final carFuelTypeRespose = await _carFuelTypes.fetchCarFuelType();

      debugPrint('Car Fuel Types: ${carFuelTypeRespose.body}');

      if (carFuelTypeRespose.statusCode == 200) {
        final FuleTypeResponse parsed = fuleTypeResponseFromJson(
          carFuelTypeRespose.body,
        );

        carFuelTypes = parsed.data;
        _fuelTypeColorCodeMap = {
          for (final fuelType in carFuelTypes)
            fuelType.name.trim().toLowerCase(): _normalizeHexColorCode(
              fuelType.normalizedColorCode,
            ),
        };
      } else {
        error = '';
      }
    } catch (e) {
      error = ErrorMessageHelper.userMessage(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

// Get car Transmission Types : ====>
class CarTransmissiotypeListView extends ChangeNotifier {
  final CarTrasmissionTypes _carFuelTypes = CarTrasmissionTypes();

  bool isLoading = false;
  String? error;
  List<CarTransmissionDatum> carTransmissionTypes = [];

  Future<void> fetchCarTransmissionTypes() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final carTrasmissionTypeRespose = await _carFuelTypes
          .fetchCarTransmissionType();

      debugPrint('Car Transmission Types: ${carTrasmissionTypeRespose.body}');

      if (carTrasmissionTypeRespose.statusCode == 200) {
        final CarTrasmissionTypeResponse parsed =
            carTrasmissionTypeResponseFromJson(carTrasmissionTypeRespose.body);

        carTransmissionTypes = parsed.data;
      } else {
        error = '';
      }
    } catch (e) {
      error = ErrorMessageHelper.userMessage(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

// Get car Varients Types based on Car - Models: ====>
class CarModelsVarietsListView extends ChangeNotifier {
  final CarVarientsTypes _carModelVarients = CarVarientsTypes();

  bool isLoading = false;
  String? error;
  List<CarModelVarientsDatum> carModelVarients = [];

  Future<void> fetchCarModelVrients({required int modelId}) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _carModelVarients.fetchCarModelsVarients(modelId);
      debugPrint('Car Varients Response : ${response.body}');

      if (response.statusCode == 200) {
        final parsed = carVarietsTypeResponseFromJson(response.body);
        carModelVarients = parsed.data;
      } else {
        error = 'Status code: ${response.statusCode}';
      }
    } catch (e) {
      error = ErrorMessageHelper.userMessage(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Clear old models when brand changes
  void clear() {
    carModelVarients = [];
    notifyListeners();
  }
}

// Get car Color : ====>
class CarColorListView extends ChangeNotifier {
  final CarColors _carColors = CarColors();

  bool isLoading = false;
  String? error;
  List<CarColorDatum> carColors = [];

  Future<void> fetchCarColors({required int variantId}) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _carColors.fetchedCarColors(variantId);
      debugPrint('Car Colors Response: ${response.body}');

      if (response.statusCode == 200) {
        final CarColorsResponse parsed = carColorsResponseFromJson(
          response.body,
        );

        carColors = parsed.data;
      } else {
        error = 'Status code: ${response.statusCode}';
      }
    } catch (e) {
      error = ErrorMessageHelper.userMessage(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    carColors = [];
    notifyListeners();
  }
}

// Get car RTOs : ====>
class CarRRTOsListView extends ChangeNotifier {
  final CarRTOsRegistration _carRTOs = CarRTOsRegistration();

  bool isLoading = false;
  String? error;
  List<CarRTOsDatum> carRTOs = [];

  Future<void> fetchCarRTOsRegistion() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _carRTOs.fetchCarRTOs();

      debugPrint('Car RTOs Response: ${response.body}');

      if (response.statusCode == 200) {
        final parsed = carRtOsResponseFromJson(response.body);
        carRTOs = parsed.data; // ✅ CORRECT
      } else {
        error = 'Status code: ${response.statusCode}';
      }
    } catch (e) {
      error = ErrorMessageHelper.userMessage(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

// Get car Owners : ====>
class CarNumofOwner extends ChangeNotifier {
  final CarNoofOwners _carowners = CarNoofOwners();

  bool isLoading = false;
  String? error;
  List<CarNoOfOwnersDatum> carOwners = [];

  Future<void> fetchedRTOregister() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _carowners.fetchOwners();
      debugPrint('Car RTO register : ${response.body}');

      if (response.statusCode == 200) {
        final parsed = carNoOfOwnersResponseFromJson(response.body);
        carOwners = parsed.data;
      } else {
        error = 'Status code: ${response.statusCode}';
      }
    } catch (e) {
      error = ErrorMessageHelper.userMessage(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

// Get car Safety Features : ====>
class CarSafetyFeaturesViewModel extends ChangeNotifier {
  final SafetyFeatures _safetyfeatures = SafetyFeatures();

  bool isLoading = false;
  String? error;
  List<SaftyFeaturesDatum> features = [];

  Future<void> fetchCarSafetyFeatures() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _safetyfeatures.fetchSafetyFeatures();
      debugPrint('CarSafetyFeatures : ${response.body}');

      if (response.statusCode == 200) {
        final parsed = carSaftyFeaturesResponseFromJson(response.body);
        // Filter to unique names, keeping the first occurrence
        final uniqueFeatures = <String, SaftyFeaturesDatum>{};
        for (final feature in parsed.data) {
          if (!uniqueFeatures.containsKey(feature.name)) {
            uniqueFeatures[feature.name] = feature;
          }
        }
        features = uniqueFeatures.values.toList();
      } else {
        error = 'Status code: ${response.statusCode}';
      }
    } catch (e) {
      error = ErrorMessageHelper.userMessage(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

// Get car comfort Features : ====>
class CarcomfortFeaturesViewModel extends ChangeNotifier {
  final ComfortConveience _comfortConveience = ComfortConveience();

  bool isLoading = false;
  String? error;
  List<CarcomfortDatum> comfort = [];
  Future<void> fetchedComfortFeatures() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _comfortConveience.fetchComfortFeatures();
      debugPrint('CarComfortFeatures : ${response.body}');

      if (response.statusCode == 200) {
        final parsed = carComfortConvenienceResponseFromJson(response.body);
        // Filter to unique names, keeping the first occurrence
        final uniqueFeatures = <String, CarcomfortDatum>{};
        for (final feature in parsed.data) {
          if (!uniqueFeatures.containsKey(feature.name)) {
            uniqueFeatures[feature.name] = feature;
          }
        }
        comfort = uniqueFeatures.values.toList();
      } else {
        error = 'Status code: ${response.statusCode}';
      }
    } catch (e) {
      error = ErrorMessageHelper.userMessage(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

// Get car Info Features : ====>
class CarInfotainmentFeaturesViewModel extends ChangeNotifier {
  final CarInfotainment _carInfotainment = CarInfotainment();

  bool isLoading = false;
  String? error;
  List<CarInfotainmentDatum> infotainment = [];

  Future<void> fetchedInfotainmentFeatures() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _carInfotainment.fetchedCarInfotainment();
      debugPrint('fetchedInfotainmentFeatures : ${response.body}');

      if (response.statusCode == 200) {
        final parsed = carInfotainmentResponseFromJson(response.body);
        // Filter to unique names, keeping the first occurrence
        final uniqueFeatures = <String, CarInfotainmentDatum>{};
        for (final feature in parsed.data) {
          if (!uniqueFeatures.containsKey(feature.name)) {
            uniqueFeatures[feature.name] = feature;
          }
        }
        infotainment = uniqueFeatures.values.toList();
      } else {
        error = 'Status code: ${response.statusCode}';
      }
    } catch (e) {
      error = ErrorMessageHelper.userMessage(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

// Get car Interior Features : ====>
class CarInteriorFeaturesViewModel extends ChangeNotifier {
  final CarInterior _carInterior = CarInterior();

  bool isLoading = false;
  String? error;
  List<CarInteriorDatum> interior = [];

  Future<void> fetchInteriorFeayures() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _carInterior.fetchedInteriorFeatures();
      debugPrint('fetchInteriorFeayures : ${response.body}');

      if (response.statusCode == 200) {
        final parsed = carInteriorResponseFromJson(response.body);
        // Filter to unique names, keeping the first occurrence
        final uniqueFeatures = <String, CarInteriorDatum>{};
        for (final feature in parsed.data) {
          if (!uniqueFeatures.containsKey(feature.name)) {
            uniqueFeatures[feature.name] = feature;
          }
        }
        interior = uniqueFeatures.values.toList();
      } else {
        error = 'Status code: ${response.statusCode}';
      }
    } catch (e) {
      error = ErrorMessageHelper.userMessage(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

// Get car Exterior Features : ====>
class CarExteriorFeaturesViewModel extends ChangeNotifier {
  final CarExterior _carExterior = CarExterior();

  bool isLoading = false;
  String? error;
  List<CarExteriorDatum> exterior = [];

  Future<void> fetchExteriorFeatures() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _carExterior.fetchedExteriorFeatures();
      debugPrint('fetchExteriorFeatures : ${response.body}');

      if (response.statusCode == 200) {
        final parsed = carExteriorResponseFromJson(response.body);
        // Filter to unique names, keeping the first occurrence
        final uniqueFeatures = <String, CarExteriorDatum>{};
        for (final feature in parsed.data) {
          if (!uniqueFeatures.containsKey(feature.name)) {
            uniqueFeatures[feature.name] = feature;
          }
        }
        exterior = uniqueFeatures.values.toList();
      } else {
        error = 'Status code: ${response.statusCode}';
      }
    } catch (e) {
      error = ErrorMessageHelper.userMessage(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

// For New car Post : ====>
class PostCarViewModel extends ChangeNotifier {
  final PostCarService _service = PostCarService();

  bool isLoading = false;
  String? errorMessage;
  Map<String, dynamic>? responseData;

  Future<bool> postCar(PostCarRequestModel model) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      responseData = await _service.postCar(model);
      debugPrint('Add a new car ResponseData : $responseData');
      return true;
    } catch (e) {
      errorMessage = ErrorMessageHelper.userMessage(e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    errorMessage = null;
    responseData = null;
    notifyListeners();
  }
}

// For Getting car details based on the token : ====>
class CarDetailsViewModel extends ChangeNotifier {
  final CarDetailsService _service = CarDetailsService();

  bool isLoading = false;
  String? error;

  List<MultiCarsDatum> cars = [];

  /// Fetch dealer cars
  Future<void> fetchDealerCars() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _service.fetchedDealerCarDetails();

      if (response.status) {
        cars = response.data;
        debugPrint('Dealers Cars Data : ${response.data}');
      } else {
        error = response.message;
      }
    } catch (e) {
      error = ErrorMessageHelper.userMessage(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Optional helpers
  bool get hasCars => cars.isNotEmpty;

  MultiCarsDatum? getCarById(int id) {
    try {
      return cars.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}

// For Getting car details based on the car id : ====>
class SingleCarDetailsViewModel extends ChangeNotifier {
  final SingleCarDetailsService _service = SingleCarDetailsService();

  bool isLoading = false;
  String? error;

  car_details.DealerCarDetailsDatum? singleCar;

  Future<void> fetchedSingleCardetails(int carId) async {
    singleCar = null; // Clear old data
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _service.fetchCarDetails(carId);

      if (response.status) {
        singleCar = response.data; // ✅ single object
      } else {
        error = response.message;
      }
    } catch (e) {
      error = ErrorMessageHelper.userMessage(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

// For Deleting car based on the car id : ====>
class DeleteCarViewModel extends ChangeNotifier {
  final DeleteCarService _service = DeleteCarService();

  bool isLoading = false;
  String? error;
  bool isDeleted = false;

  Future<void> deleteCar(int carId) async {
    isLoading = true;
    error = null;
    isDeleted = false;
    notifyListeners();

    try {
      final result = await _service.deleteCar(carId);

      if (result) {
        isDeleted = true;
      }
    } catch (e) {
      error = ErrorMessageHelper.userMessage(e);
      isDeleted = false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

// For cars display ListOfCarsViewModel based on token: ====>
class ListOfCarsViewModel extends ChangeNotifier {
  final ListOfCarsService _service = ListOfCarsService();

  bool isLoading = false;
  String? error;
  List<ListOfCarsDatum> listOfCars = [];

  // Fetch list of cars
  Future<void> fetchingListOfCars() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _service.fetchListOfCars();

      if (response.status || response.data.isNotEmpty) {
        listOfCars = response.data;
        debugPrint('List of Cars : ${response.data}');
      } else {
        error = response.message;
        listOfCars = [];
      }
    } catch (e) {
      error = ErrorMessageHelper.userMessage(e);
      listOfCars = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Set filtered cars
  void setFilteredCars(List<ListOfCarsDatum> filtered) {
    listOfCars = filtered;
    notifyListeners();
  }
}

// For search based (Token) on query : ====>
class SearchViewModel extends ChangeNotifier {
  final SearchCarService _service = SearchCarService();

  bool isLoading = false;
  String? error;
  List<SearchDatum> cars = [];

  Future<void> search(String query) async {
    if (query.isEmpty) {
      cars = [];
      error = null;
      notifyListeners();
      return;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _service.searchCars(query);

      if (response.status || response.data.items.isNotEmpty) {
        cars = response.data.items;
      } else {
        error = response.message;
        cars = [];
      }
    } catch (e) {
      error = ErrorMessageHelper.userMessage(e);
      cars = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

// For my inventory search based (Token) on query : ====>
class MyInventrySearchViewModel extends ChangeNotifier {
  final MyInvetrySearchCarService _service = MyInvetrySearchCarService();

  bool isLoading = false;
  String? error;
  List<MyInventrySearchDatum> cars = [];

  Future<void> search(String query) async {
    if (query.isEmpty) {
      cars = [];
      error = null;
      notifyListeners();
      return;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _service.searchCars(query);

      if (response.status || response.data.isNotEmpty) {
        cars = response.data;
      } else {
        error = response.message;
        cars = [];
      }
    } catch (e) {
      error = ErrorMessageHelper.userMessage(e);
      cars = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

// For fetching all car models : ====>
class AllCarModelsViewModel extends ChangeNotifier {
  final AllCarModelsService _service = AllCarModelsService();

  bool isLoading = false;
  String? error;
  List<CarModelsListDatum> allCarModels = [];

  Future<void> fetchAllCarModels() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _service.fetchAllCarModels();

      if (response.statusCode == 200) {
        final parsed = allCarModelsListResponseFromJson(response.body);
        allCarModels = parsed.data;
        debugPrint('All Car Models : ${response.body}');
      } else {
        error = 'Status code: ${response.statusCode}';
      }
    } catch (e) {
      error = ErrorMessageHelper.userMessage(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

// For fetching all car models : ====>
class FilterCarViewModel extends ChangeNotifier {
  final FilterCarService _service = FilterCarService();

  bool isLoading = false;
  List<ListOfCarsDatum> filteredCars = [];

  Future<void> getFilteredCars({
    List<int>? ownerTypeIds,
    List<int>? brandIds,
    List<int>? fuelTypeIds,
    List<int>? modelIds,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _service.fetchFilteredCars(
        ownerTypeIds: ownerTypeIds,
        brandIds: brandIds,
        fuelTypeIds: fuelTypeIds,
        modelIds: modelIds,
      );

      if (response['status'] == true) {
        final parsed = listOfCarDetailsResponseFromJson(jsonEncode(response));
        filteredCars = parsed.data;
      } else {
        debugPrint('Filter API message: ${response['message']}');
        filteredCars = [];
      }
    } catch (e) {
      debugPrint("Filter error: $e");
      filteredCars = [];
    }

    isLoading = false;
    notifyListeners();
  }
}

// For updating car based on the carID using token : ====>
class CarUpdateViewModel extends ChangeNotifier {
  final UpdateCarFeaturesService _service = UpdateCarFeaturesService();

  bool isLoading = false;
  String? errorMessage;

  CarUpdateResponse? updateResponse;

  /// 🚀 Update Car
  Future<void> updateCar(CarUpdateRequestModel request) async {
    isLoading = true;
    errorMessage = null;
    updateResponse = null;
    notifyListeners();

    try {
      final response = await _service.updateCar(request);
      debugPrint('car update response: ${response.data.car.id}');

      if (response.status) {
        updateResponse = response;
      } else {
        errorMessage = response.message;
      }
    } catch (e) {
      errorMessage = ErrorMessageHelper.userMessage(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ Check success easily
  bool get isSuccess => updateResponse != null && errorMessage == null;

  /// 🔄 Clear state
  void clear() {
    errorMessage = null;
    updateResponse = null;
    notifyListeners();
  }
}

// For updating car images : ====>
class CarImageUploadViewModel extends ChangeNotifier {
  final UpdateCarImagesService _service = UpdateCarImagesService();

  bool isLoading = false;
  String? errorMessage;
  bool isSuccess = false;
  List<car_details.CarImage> uploadedImages = [];

  Future<void> uploadCarImages({
    required int carId,
    required List<String> imagePaths,
    bool isPrimary = false,
  }) async {
    isLoading = true;
    errorMessage = null;
    isSuccess = false;
    uploadedImages = [];
    notifyListeners();

    try {
      final result = await _service.addCarImages(
        carId,
        imagePaths,
        isPrimary: isPrimary,
      );
      uploadedImages = result;
      isSuccess = result.isNotEmpty;
    } catch (e) {
      errorMessage = ErrorMessageHelper.userMessage(e);
      isSuccess = false;
      uploadedImages = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

// For deleting car images : ====>
class DeleteCarImageViewModel extends ChangeNotifier {
  final DeleteCarImageService _service = DeleteCarImageService();

  bool isLoading = false;
  bool isSuccess = false;
  String? error;

  Future<void> deleteImages({
    required int carId,
    required List<int> imageIds,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final result = await _service.deleteCarImages(
        carId: carId,
        imageIds: imageIds,
      );

      isSuccess = result;
    } catch (e) {
      error = ErrorMessageHelper.userMessage(e);
    }

    isLoading = false;
    notifyListeners();
  }
}

// For fetching all favorite cars Dealer : ====>
class DealerFavoriteCarsViewModel extends ChangeNotifier {
  final DealerFavoriteCarsService _service = DealerFavoriteCarsService();

  bool isLoading = false;
  String? error;
  List<DealerFavCarDatum> favoriteCars = [];

  Future<void> fetchFavoriteCars() async {
    debugPrint('Fetching favorite cars...');
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _service.fetchDealerFavoriteCars();
      debugPrint('Favorite cars response status dealer: ${response.status}');
      debugPrint('Favorite cars response message dealer: ${response.message}');
      debugPrint('Favorite cars count: ${response.data.cars.length}');

      if (response.status) {
        favoriteCars = response.data.cars;
        debugPrint('Dealer Favorite Cars : ${response.data.cars.length}');
      } else {
        final message = response.message.toLowerCase();
        final noFavorites =
            response.data.cars.isEmpty &&
            (message.contains('no favorite') ||
                message.contains('no favourites') ||
                message.contains('not found'));

        if (noFavorites) {
          favoriteCars = [];
          error = null;
          debugPrint('Dealer favorites are empty.');
        } else {
          error = response.message;
          debugPrint('Error fetching favorite cars: $error');
        }
      }
    } catch (e) {
      error = ErrorMessageHelper.userMessage(e);
      debugPrint('Exception fetching favorite cars: $error');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

// For posting a car favorite  Dealers: ====>
class AddToFavoriteViewModel extends ChangeNotifier {
  final AddFavirateCarService _service = AddFavirateCarService();

  bool isLoading = false;
  bool isFavorite = false;

  Future<bool> addToFavorite(int carId) async {
    isLoading = true;
    isFavorite = false;
    notifyListeners();

    try {
      final response = await _service.addToFavorite(carId);

      if (response.status) {
        isFavorite = true;
        return true;
      }
    } catch (e) {
      debugPrint("Add favorite error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }

    return false;
  }
}

// For removing a car from favorite Dealers: ====>
class RemoveFromFavoriteViewModel extends ChangeNotifier {
  final RemoveCarFromFavService _service = RemoveCarFromFavService();

  bool isLoading = false;

  Future<bool> removeCar(int carId) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _service.removeCarFromFavorite(carId);

      if (response.status) {
        return true;
      }
    } catch (e) {
      debugPrint("Remove favorite error: $e");
    }

    isLoading = false;
    notifyListeners();

    return false;
  }
}

// For fetching all favorite cars Agent : ====>
class AgentFavoriteCarsViewModel extends ChangeNotifier {
  final AgentFavoriteCarsService _service = AgentFavoriteCarsService();

  bool isLoading = false;
  String? error;
  List<AgentFavCarDatum> favoriteCars = [];

  Future<void> fetchFavoriteCars() async {
    debugPrint('Fetching favorite cars...');
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _service.fetchAgentFavoriteCars();
      debugPrint('Favorite cars response status Agent: ${response.status}');
      debugPrint('Favorite cars response message Agent: ${response.message}');

      if (response.status) {
        favoriteCars = response.data.cars;
        debugPrint('Agent Favorite Cars : ${response.data.cars.length}');
      } else {
        final message = response.message.toLowerCase();
        final noFavorites =
            response.data.cars.isEmpty &&
            (message.contains('no favorite') ||
                message.contains('no favourites') ||
                message.contains('not found'));

        if (noFavorites) {
          favoriteCars = [];
          error = null;
          debugPrint('Agent favorites are empty.');
        } else {
          error = response.message;
          debugPrint('Error fetching favorite cars: $error');
        }
      }
    } catch (e) {
      error = ErrorMessageHelper.userMessage(e);
      debugPrint('Exception fetching favorite cars: $error');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

// For posting a car favorite  Agent: ====>
class AddFavCarsAgentsViewModel extends ChangeNotifier {
  final AddToFavCarsAgent _service = AddToFavCarsAgent();

  bool isLoading = false;
  bool isFavorite = false;
  String? errorMessage;

  Future<bool> addToFavorite(int carId) async {
    isLoading = true;
    isFavorite = false;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.addToFavorite(carId);

      if (response.status) {
        isFavorite = true;
        return true;
      }

      errorMessage = response.message;
    } catch (e) {
      errorMessage = ErrorMessageHelper.userMessage(e);
      debugPrint("Add favorite error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }

    return false;
  }
}

// For removing a car from favorite Agent: ====>
class RemoveFavCarsAgentsViewModel extends ChangeNotifier {
  final RemoveFavCarsFroAgent _service = RemoveFavCarsFroAgent();

  bool isLoading = false;

  Future<bool> removeCar(int carId) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _service.removeCarFromFavorite(carId);

      if (response.status) {
        return true;
      }
    } catch (e) {
      debugPrint("Remove favorite error: $e");
    }

    isLoading = false;
    notifyListeners();

    return false;
  }
}
