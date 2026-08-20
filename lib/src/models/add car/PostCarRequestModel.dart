// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;

// class PostCarRequestModel {
//   final String registrationNumber;

//   // 🔹 IDs
//   final int? brandId;
//   final int? modelId;
//   final int? variantId;
//   final int? fuelTypeId;
//   final int? transmissionId;
//   final int? colorId;
//   final int? ownerTypeId;
//   final int? rtoId;

//   // 🔹 Basic info
//   final int? manufacturingYear;
//   final String? kmRange;

//   // 🔹 Other details
//   final String? insuranceValidity;
//   final String? serviceHistory;

//   // 🔹 Feature IDs
//   final List<int> safetyFeatureIds;
//   final List<int> comfortFeatureIds;
//   final List<int> infotainmentFeatureIds;
//   final List<int> interiorFeatureIds;
//   final List<int> exteriorFeatureIds;

//   // 🔹 Extra features (TEXT)
//   final List<String> extraSafetyFeatures;
//   final List<String> extraComfortFeatures;
//   final List<String> extraInteriorFeatures;
//   final List<String> extraExteriorFeatures;
//   final List<String> extraInfotainmentFeatures;

//   // 🔹 Images
//   final List<File> images;

//   // 🔹 final status
//   final String status;

//   PostCarRequestModel({
//     required this.registrationNumber,
//     this.brandId,
//     this.modelId,
//     this.variantId,
//     this.fuelTypeId,
//     this.transmissionId,
//     this.colorId,
//     this.ownerTypeId,
//     this.rtoId,
//     this.manufacturingYear,
//     this.kmRange,
//     this.insuranceValidity,
//     this.serviceHistory,
//     this.safetyFeatureIds = const [],
//     this.comfortFeatureIds = const [],
//     this.infotainmentFeatureIds = const [],
//     this.interiorFeatureIds = const [],
//     this.exteriorFeatureIds = const [],
//     this.extraSafetyFeatures = const [],
//     this.extraComfortFeatures = const [],
//     this.extraInteriorFeatures = const [],
//     this.extraExteriorFeatures = const [],
//     this.extraInfotainmentFeatures = const [],
//     this.images = const [],
//     String status = "inactive",
//   }) : status = _normalizeStatus(status);

//   static String _normalizeStatus(String value) {
//     final normalized = value.trim().toLowerCase();
//     return normalized == 'active' ? 'active' : 'inactive';
//   }

//   /// ✅ Convert to MultipartRequest
//   Future<http.MultipartRequest> toMultipartRequest(String url) async {
//     final request = http.MultipartRequest('POST', Uri.parse(url));

//     // 🔹 BASIC FIELDS
//     request.fields.addAll({
//       'brand_id': brandId.toString(),
//       'model_id': modelId.toString(),
//       'variant_id': variantId.toString(),
//       'fuel_type_id': fuelTypeId.toString(),
//       'transmission_id': transmissionId.toString(),
//       'color_id': colorId.toString(),
//       'owner_type_id': ownerTypeId.toString(),
//       'rto_id': rtoId.toString(),
//       'manufacturing_year': manufacturingYear.toString(),
//       'km_range': kmRange ?? '',
//       'status': status,
//       'registration_number': registrationNumber,
//     });

//     // 🔹 OTHER DETAILS (JSON STRING - ONLY INCLUDE NON-EMPTY VALUES)
//     final otherDetails = <String, dynamic>{};
//     if (insuranceValidity != null && insuranceValidity!.isNotEmpty) {
//       otherDetails["insurance_validity"] = insuranceValidity;
//     }
//     if (serviceHistory != null && serviceHistory!.isNotEmpty) {
//       otherDetails["service_history"] = serviceHistory;
//     }
//     if (otherDetails.isNotEmpty) {
//       request.fields['other_details'] = jsonEncode(otherDetails);
//     }

//     // 🔹 FEATURE IDS (JSON ARRAY FORMAT)
//     if (safetyFeatureIds.isNotEmpty) {
//       request.fields['safety_feature_ids'] = jsonEncode(safetyFeatureIds);
//     }
//     if (comfortFeatureIds.isNotEmpty) {
//       request.fields['comfort_feature_ids'] = jsonEncode(comfortFeatureIds);
//     }
//     if (infotainmentFeatureIds.isNotEmpty) {
//       request.fields['infotainment_feature_ids'] = jsonEncode(
//         infotainmentFeatureIds,
//       );
//     }
//     if (interiorFeatureIds.isNotEmpty) {
//       request.fields['interior_feature_ids'] = jsonEncode(interiorFeatureIds);
//     }
//     if (exteriorFeatureIds.isNotEmpty) {
//       request.fields['exterior_feature_ids'] = jsonEncode(exteriorFeatureIds);
//     }

//     // 🔹 EXTRA FEATURES (JSON ARRAY FORMAT)
//     if (extraSafetyFeatures.isNotEmpty) {
//       request.fields['extra_safety_features'] = jsonEncode(extraSafetyFeatures);
//     }
//     if (extraComfortFeatures.isNotEmpty) {
//       request.fields['extra_comfort_features'] = jsonEncode(
//         extraComfortFeatures,
//       );
//     }
//     if (extraInteriorFeatures.isNotEmpty) {
//       request.fields['extra_interior_features'] = jsonEncode(
//         extraInteriorFeatures,
//       );
//     }
//     if (extraExteriorFeatures.isNotEmpty) {
//       request.fields['extra_exterior_features'] = jsonEncode(
//         extraExteriorFeatures,
//       );
//     }
//     if (extraInfotainmentFeatures.isNotEmpty) {
//       request.fields['extra_infotainment_features'] = jsonEncode(
//         extraInfotainmentFeatures,
//       );
//     }

//     // 🔹 IMAGES
//     for (int i = 0; i < images.length; i++) {
//       final file = images[i];
//       final multipartFile = await http.MultipartFile.fromPath(
//         'images[${i + 1}]',
//         file.path,
//         contentType: _imageMediaType(file.path),
//       );
//       request.files.add(multipartFile);
//     }

//     return request;
//   }

//   http.MediaType _imageMediaType(String path) {
//     final lowerPath = path.toLowerCase();

//     if (lowerPath.endsWith('.png')) {
//       return http.MediaType('image', 'png');
//     }
//     if (lowerPath.endsWith('.jpg') || lowerPath.endsWith('.jpeg')) {
//       return http.MediaType('image', 'jpeg');
//     }

//     // Fallback keeps current behavior for unknown image extensions.
//     return http.MediaType('image', 'jpeg');
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// class PostCarRequestModel {
//   final String registrationNumber;

//   // Optional IDs
//   final int? brandId;
//   final int? modelId;
//   final int? variantId;
//   final int? fuelTypeId;
//   final int? transmissionId;
//   final int? colorId;
//   final int? ownerTypeId;
//   final int? rtoId;

//   // Optional Basic Info
//   final int? manufacturingYear;
//   final String? kmRange;

//   // Other Details
//   final String? insuranceValidity;
//   final String? serviceHistory;

//   // Feature IDs
//   final List<int> safetyFeatureIds;
//   final List<int> comfortFeatureIds;
//   final List<int> infotainmentFeatureIds;
//   final List<int> interiorFeatureIds;
//   final List<int> exteriorFeatureIds;

//   // Extra Features
//   final List<String> extraSafetyFeatures;
//   final List<String> extraComfortFeatures;
//   final List<String> extraInteriorFeatures;
//   final List<String> extraExteriorFeatures;
//   final List<String> extraInfotainmentFeatures;

//   // Images
//   final List<File> images;

//   final String status;

//   PostCarRequestModel({
//     required this.registrationNumber,

//     this.brandId,
//     this.modelId,
//     this.variantId,
//     this.fuelTypeId,
//     this.transmissionId,
//     this.colorId,
//     this.ownerTypeId,
//     this.rtoId,
//     this.manufacturingYear,
//     this.kmRange,

//     this.insuranceValidity,
//     this.serviceHistory,

//     this.safetyFeatureIds = const [],
//     this.comfortFeatureIds = const [],
//     this.infotainmentFeatureIds = const [],
//     this.interiorFeatureIds = const [],
//     this.exteriorFeatureIds = const [],

//     this.extraSafetyFeatures = const [],
//     this.extraComfortFeatures = const [],
//     this.extraInteriorFeatures = const [],
//     this.extraExteriorFeatures = const [],
//     this.extraInfotainmentFeatures = const [],

//     this.images = const [],

//     String status = "inactive",
//   }) : status = _normalizeStatus(status);

//   static String _normalizeStatus(String value) {
//     final normalized = value.trim().toLowerCase();
//     return normalized == "active" ? "active" : "inactive";
//   }

//   Future<http.MultipartRequest> toMultipartRequest(String url) async {
//     final request = http.MultipartRequest('POST', Uri.parse(url));

//     // Mandatory
//     request.fields["registration_number"] = registrationNumber;
//     request.fields["status"] = status;

//     // Optional Fields
//     if (brandId != null) {
//       request.fields["brand_id"] = brandId.toString();
//     }

//     if (modelId != null) {
//       request.fields["model_id"] = modelId.toString();
//     }

//     if (variantId != null) {
//       request.fields["variant_id"] = variantId.toString();
//     }

//     if (fuelTypeId != null) {
//       request.fields["fuel_type_id"] = fuelTypeId.toString();
//     }

//     if (transmissionId != null) {
//       request.fields["transmission_id"] = transmissionId.toString();
//     }

//     if (colorId != null) {
//       request.fields["color_id"] = colorId.toString();
//     }

//     if (ownerTypeId != null) {
//       request.fields["owner_type_id"] = ownerTypeId.toString();
//     }

//     if (rtoId != null) {
//       request.fields["rto_id"] = rtoId.toString();
//     }

//     if (manufacturingYear != null) {
//       request.fields["manufacturing_year"] = manufacturingYear.toString();
//     }

//     if (kmRange != null && kmRange!.isNotEmpty) {
//       request.fields["km_range"] = kmRange!;
//     }

//     // Other Details
//     final otherDetails = <String, dynamic>{};

//     if (insuranceValidity != null && insuranceValidity!.isNotEmpty) {
//       otherDetails["insurance_validity"] = insuranceValidity;
//     }

//     if (serviceHistory != null && serviceHistory!.isNotEmpty) {
//       otherDetails["service_history"] = serviceHistory;
//     }

//     if (otherDetails.isNotEmpty) {
//       request.fields["other_details"] = jsonEncode(otherDetails);
//     }

//     // Feature IDs

//     if (safetyFeatureIds.isNotEmpty) {
//       request.fields["safety_feature_ids"] = jsonEncode(safetyFeatureIds);
//     }

//     if (comfortFeatureIds.isNotEmpty) {
//       request.fields["comfort_feature_ids"] = jsonEncode(comfortFeatureIds);
//     }

//     if (infotainmentFeatureIds.isNotEmpty) {
//       request.fields["infotainment_feature_ids"] = jsonEncode(
//         infotainmentFeatureIds,
//       );
//     }

//     if (interiorFeatureIds.isNotEmpty) {
//       request.fields["interior_feature_ids"] = jsonEncode(interiorFeatureIds);
//     }

//     if (exteriorFeatureIds.isNotEmpty) {
//       request.fields["exterior_feature_ids"] = jsonEncode(exteriorFeatureIds);
//     }

//     // Extra Features

//     if (extraSafetyFeatures.isNotEmpty) {
//       request.fields["extra_safety_features"] = jsonEncode(extraSafetyFeatures);
//     }

//     if (extraComfortFeatures.isNotEmpty) {
//       request.fields["extra_comfort_features"] = jsonEncode(
//         extraComfortFeatures,
//       );
//     }

//     if (extraInteriorFeatures.isNotEmpty) {
//       request.fields["extra_interior_features"] = jsonEncode(
//         extraInteriorFeatures,
//       );
//     }

//     if (extraExteriorFeatures.isNotEmpty) {
//       request.fields["extra_exterior_features"] = jsonEncode(
//         extraExteriorFeatures,
//       );
//     }

//     if (extraInfotainmentFeatures.isNotEmpty) {
//       request.fields["extra_infotainment_features"] = jsonEncode(
//         extraInfotainmentFeatures,
//       );
//     }

//     // Images

//     for (int i = 0; i < images.length; i++) {
//       request.files.add(
//         await http.MultipartFile.fromPath(
//           "images[${i + 1}]",
//           images[i].path,
//           contentType: _imageMediaType(images[i].path),
//         ),
//       );
//     }

//     return request;
//   }

//   http.MediaType _imageMediaType(String path) {
//     final lower = path.toLowerCase();

//     if (lower.endsWith(".png")) {
//       return http.MediaType("image", "png");
//     }

//     return http.MediaType("image", "jpeg");
//   }
// }

class PostCarRequestModel {
  final String registrationNumber;
  final String kmRange;
  final List<File> images;

  const PostCarRequestModel({
    required this.registrationNumber,
    required this.kmRange,
    required this.images,
  });

  Future<http.MultipartRequest> toMultipartRequest(String url) async {
    final request = http.MultipartRequest('POST', Uri.parse(url));

    request.fields['registration_number'] = registrationNumber;
    request.fields['km_range'] = kmRange;

    for (int i = 0; i < images.length; i++) {
      request.files.add(
        await http.MultipartFile.fromPath('images[$i]', images[i].path),
      );
    }

    return request;
  }
}
