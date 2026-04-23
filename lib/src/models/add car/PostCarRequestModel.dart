import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class PostCarRequestModel {
  // 🔹 IDs
  final int brandId;
  final int modelId;
  final int variantId;
  final int fuelTypeId;
  final int transmissionId;
  final int colorId;
  final int ownerTypeId;
  final int rtoId;

  // 🔹 Basic info
  final int manufacturingYear;
  final String kmRange;

  // 🔹 Other details
  final String? insuranceValidity;
  final String? serviceHistory;

  // 🔹 Feature IDs
  final List<int> safetyFeatureIds;
  final List<int> comfortFeatureIds;
  final List<int> infotainmentFeatureIds;
  final List<int> interiorFeatureIds;
  final List<int> exteriorFeatureIds;

  // 🔹 Extra features (TEXT)
  final List<String> extraSafetyFeatures;
  final List<String> extraComfortFeatures;
  final List<String> extraInteriorFeatures;
  final List<String> extraExteriorFeatures;
  final List<String> extraInfotainmentFeatures;

  // 🔹 Images
  final List<File> images;

  // 🔹 final status
  final String status;

  PostCarRequestModel({
    required this.brandId,
    required this.modelId,
    required this.variantId,
    required this.fuelTypeId,
    required this.transmissionId,
    required this.colorId,
    required this.ownerTypeId,
    required this.rtoId,
    required this.manufacturingYear,
    required this.kmRange,
    this.insuranceValidity,
    this.serviceHistory,
    this.safetyFeatureIds = const [],
    this.comfortFeatureIds = const [],
    this.infotainmentFeatureIds = const [],
    this.interiorFeatureIds = const [],
    this.exteriorFeatureIds = const [],
    this.extraSafetyFeatures = const [],
    this.extraComfortFeatures = const [],
    this.extraInteriorFeatures = const [],
    this.extraExteriorFeatures = const [],
    this.extraInfotainmentFeatures = const [],
    this.images = const [],
    String status = "inactive",
  }) : status = _normalizeStatus(status);

  static String _normalizeStatus(String value) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'active' ? 'active' : 'inactive';
  }

  /// ✅ Convert to MultipartRequest
  Future<http.MultipartRequest> toMultipartRequest(String url) async {
    final request = http.MultipartRequest('POST', Uri.parse(url));

    // 🔹 BASIC FIELDS
    request.fields.addAll({
      'brand_id': brandId.toString(),
      'model_id': modelId.toString(),
      'variant_id': variantId.toString(),
      'fuel_type_id': fuelTypeId.toString(),
      'transmission_id': transmissionId.toString(),
      'color_id': colorId.toString(),
      'owner_type_id': ownerTypeId.toString(),
      'rto_id': rtoId.toString(),
      'manufacturing_year': manufacturingYear.toString(),
      'km_range': kmRange,
      'status': status,
    });

    // 🔹 OTHER DETAILS (JSON STRING - ONLY INCLUDE NON-EMPTY VALUES)
    final otherDetails = <String, dynamic>{};
    if (insuranceValidity != null && insuranceValidity!.isNotEmpty) {
      otherDetails["insurance_validity"] = insuranceValidity;
    }
    if (serviceHistory != null && serviceHistory!.isNotEmpty) {
      otherDetails["service_history"] = serviceHistory;
    }
    if (otherDetails.isNotEmpty) {
      request.fields['other_details'] = jsonEncode(otherDetails);
    }

    // 🔹 FEATURE IDS (JSON ARRAY FORMAT)
    if (safetyFeatureIds.isNotEmpty) {
      request.fields['safety_feature_ids'] = jsonEncode(safetyFeatureIds);
    }
    if (comfortFeatureIds.isNotEmpty) {
      request.fields['comfort_feature_ids'] = jsonEncode(comfortFeatureIds);
    }
    if (infotainmentFeatureIds.isNotEmpty) {
      request.fields['infotainment_feature_ids'] = jsonEncode(
        infotainmentFeatureIds,
      );
    }
    if (interiorFeatureIds.isNotEmpty) {
      request.fields['interior_feature_ids'] = jsonEncode(interiorFeatureIds);
    }
    if (exteriorFeatureIds.isNotEmpty) {
      request.fields['exterior_feature_ids'] = jsonEncode(exteriorFeatureIds);
    }

    // 🔹 EXTRA FEATURES (JSON ARRAY FORMAT)
    if (extraSafetyFeatures.isNotEmpty) {
      request.fields['extra_safety_features'] = jsonEncode(extraSafetyFeatures);
    }
    if (extraComfortFeatures.isNotEmpty) {
      request.fields['extra_comfort_features'] = jsonEncode(
        extraComfortFeatures,
      );
    }
    if (extraInteriorFeatures.isNotEmpty) {
      request.fields['extra_interior_features'] = jsonEncode(
        extraInteriorFeatures,
      );
    }
    if (extraExteriorFeatures.isNotEmpty) {
      request.fields['extra_exterior_features'] = jsonEncode(
        extraExteriorFeatures,
      );
    }
    if (extraInfotainmentFeatures.isNotEmpty) {
      request.fields['extra_infotainment_features'] = jsonEncode(
        extraInfotainmentFeatures,
      );
    }

    // 🔹 IMAGES
    for (int i = 0; i < images.length; i++) {
      final file = images[i];
      final multipartFile = await http.MultipartFile.fromPath(
        'images[${i + 1}]',
        file.path,
        contentType: _imageMediaType(file.path),
      );
      request.files.add(multipartFile);
    }

    return request;
  }

  http.MediaType _imageMediaType(String path) {
    final lowerPath = path.toLowerCase();

    if (lowerPath.endsWith('.png')) {
      return http.MediaType('image', 'png');
    }
    if (lowerPath.endsWith('.jpg') || lowerPath.endsWith('.jpeg')) {
      return http.MediaType('image', 'jpeg');
    }

    // Fallback keeps current behavior for unknown image extensions.
    return http.MediaType('image', 'jpeg');
  }
}
