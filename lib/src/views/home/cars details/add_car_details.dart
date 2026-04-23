import 'dart:io';
import 'package:dealershub_/src/viewmodels/add_car_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

import 'package:dealershub_/src/utils/colors.dart';
import 'package:dealershub_/src/utils/route/route.dart';
import 'package:dealershub_/src/utils/widgets/input_field.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_costants.dart';

class CarOPtionalDetails extends StatefulWidget {
  final Map<String, dynamic> carBasicData;
  final Map<String, dynamic> carPreviewData;
  final String role;

  const CarOPtionalDetails({
    super.key,
    required this.role,
    required this.carBasicData,
    required this.carPreviewData,
  });

  @override
  State<CarOPtionalDetails> createState() => _CarOPtionalDetailsState();
}

enum CarDetailsStep {
  otherDetails,
  safetyFeatures,
  comfortAndConvenience,
  informationAndConnectivity,
  interiorFeatures,
  exteriorFeatures,
  imageUploadFields,
}

class CarDetails {
  final String? manufactorYear;
  final String? make;
  final String? model;
  final String? fuelType;
  final String? transmission;
  final String? variant;
  final String? color;
  final String? kilometers;
  final String? registration;
  final String? owner;
  final String? insurance;
  final String? serviceHistory;
  final List<String> safetyFeatures;
  final List<String> comfortFeatures;
  final List<String> connectivityFeatures;
  final List<String> interiorFeatures;
  final List<String> exteriorFeatures;
  final List<File> images;

  CarDetails({
    this.manufactorYear,
    this.make,
    this.model,
    this.fuelType,
    this.transmission,
    this.variant,
    this.color,
    this.kilometers,
    this.registration,
    this.owner,
    this.insurance,
    this.serviceHistory,
    this.safetyFeatures = const [],
    this.comfortFeatures = const [],
    this.connectivityFeatures = const [],
    this.interiorFeatures = const [],
    this.exteriorFeatures = const [],
    this.images = const [],
  });

  CarDetails copyWith({
    String? manufactorYear,
    String? make,
    String? model,
    String? fuelType,
    String? transmission,
    String? variant,
    String? color,
    String? kilometers,
    String? registration,
    String? owner,
    String? insurance,
    String? serviceHistory,
    List<String>? safetyFeatures,
    List<String>? comfortFeatures,
    List<String>? connectivityFeatures,
    List<String>? interiorFeatures,
    List<String>? exteriorFeatures,
    List<File>? images,
  }) {
    return CarDetails(
      manufactorYear: manufactorYear ?? this.manufactorYear,
      make: make ?? this.make,
      model: model ?? this.model,
      fuelType: fuelType ?? this.fuelType,
      transmission: transmission ?? this.transmission,
      variant: variant ?? this.variant,
      color: color ?? this.color,
      kilometers: kilometers ?? this.kilometers,
      registration: registration ?? this.registration,
      owner: owner ?? this.owner,
      insurance: insurance ?? this.insurance,
      serviceHistory: serviceHistory ?? this.serviceHistory,
      safetyFeatures: safetyFeatures ?? this.safetyFeatures,
      comfortFeatures: comfortFeatures ?? this.comfortFeatures,
      connectivityFeatures: connectivityFeatures ?? this.connectivityFeatures,
      interiorFeatures: interiorFeatures ?? this.interiorFeatures,
      exteriorFeatures: exteriorFeatures ?? this.exteriorFeatures,
      images: images ?? this.images,
    );
  }

  factory CarDetails.fromJson(Map<String, dynamic> json) {
    return CarDetails(
      manufactorYear: json['manufactorYear']?.toString(),
      make: json['make']?.toString(),
      model: json['model']?.toString(),
      fuelType: json['fuelType']?.toString(),
      transmission: json['transmission']?.toString(),
      variant: json['variant']?.toString(),
      color: json['color']?.toString(),
      kilometers: json['kilometers']?.toString(),
      registration: json['registration']?.toString(),
      owner: json['owner']?.toString(),
      insurance: json['insurance']?.toString(),
      serviceHistory: json['serviceHistory']?.toString(),
      safetyFeatures: List<String>.from(json['safetyFeatures'] ?? []),
      comfortFeatures: List<String>.from(json['comfortFeatures'] ?? []),
      connectivityFeatures: List<String>.from(
        json['connectivityFeatures'] ?? [],
      ),
      interiorFeatures: List<String>.from(json['interiorFeatures'] ?? []),
      exteriorFeatures: List<String>.from(json['exteriorFeatures'] ?? []),
      images: (json['images'] as List? ?? [])
          .map((e) => File(e.toString()))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    "manufactorYear": manufactorYear,
    "make": make,
    "model": model,
    "fuelType": fuelType,
    "transmission": transmission,
    "variant": variant,
    "color": color,
    "kilometers": kilometers,
    "registration": registration,
    "owner": owner,
    "insurance": insurance,
    "serviceHistory": serviceHistory,
    "safetyFeatures": safetyFeatures,
    "comfortFeatures": comfortFeatures,
    "connectivityFeatures": connectivityFeatures,
    "interiorFeatures": interiorFeatures,
    "exteriorFeatures": exteriorFeatures,
    "images": images.map((e) => e.path).toList(),
  };
}

class _CarOPtionalDetailsState extends State<CarOPtionalDetails> {
  static const int _maxCarImages = 10;

  int get _remainingImageSlots {
    final remaining = _maxCarImages - carImages.length;
    return remaining > 0 ? remaining : 0;
  }

  List<String> combinedListFor(List baseList) {
    return [...baseList.cast<String>(), ...currentOptionalData];
  }

  int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  int? _extractOwnerId(Map<String, dynamic> source) {
    return _toNullableInt(
      source['user_id'] ??
          source['userId'] ??
          source['dealer_id'] ??
          source['dealerId'] ??
          source['created_by'] ??
          source['createdBy'],
    );
  }

  int? _extractCarId(Map<String, dynamic> source) {
    return _toNullableInt(source['car_id'] ?? source['carId'] ?? source['id']);
  }

  bool _isUserCarExtraFeature({
    required int? featureCreatedByUserId,
    required int? featureCarId,
    required bool featureIsAdmin,
    required int? ownerId,
    required int? carId,
  }) {
    if (featureIsAdmin) return false;
    if (featureCreatedByUserId == null || featureCarId == null) return false;
    if (ownerId == null || carId == null || carId <= 0) return false;
    return featureCreatedByUserId == ownerId && featureCarId == carId;
  }

  List<String> _uniqueFeatureNames(Iterable<String> values) {
    final seen = <String>{};
    final result = <String>[];
    for (final raw in values) {
      final value = raw.trim();
      if (value.isEmpty) continue;
      final key = value.toLowerCase();
      if (seen.add(key)) {
        result.add(value);
      }
    }
    return result;
  }

  List<int> _partitionSelectedFeatureIds<T>({
    required Set<int> selectedIds,
    required List<T> apiFeatures,
    required int Function(T) idOf,
    required String Function(T) nameOf,
    required int? Function(T) createdByUserIdOf,
    required int? Function(T) carIdOf,
    required bool Function(T) isAdminOf,
    required List<String> extraTarget,
    required int? ownerId,
    required int? carId,
  }) {
    final featureById = <int, T>{
      for (final feature in apiFeatures) idOf(feature): feature,
    };
    final normalFeatureIds = <int>[];

    for (final selectedId in selectedIds) {
      final feature = featureById[selectedId];
      if (feature == null) continue;

      final isUserCarExtra = _isUserCarExtraFeature(
        featureCreatedByUserId: createdByUserIdOf(feature),
        featureCarId: carIdOf(feature),
        featureIsAdmin: isAdminOf(feature),
        ownerId: ownerId,
        carId: carId,
      );

      if (isUserCarExtra) {
        extraTarget.add(nameOf(feature));
      } else {
        normalFeatureIds.add(selectedId);
      }
    }

    return normalFeatureIds;
  }

  Map<String, dynamic> buildPostData(BuildContext context) {
    final comfortVM = context.read<CarcomfortFeaturesViewModel>();
    final safetyVM = context.read<CarSafetyFeaturesViewModel>();
    final infoVM = context.read<CarInfotainmentFeaturesViewModel>();
    final interiorVM = context.read<CarInteriorFeaturesViewModel>();
    final exteriorVM = context.read<CarExteriorFeaturesViewModel>();

    final ownerId = _extractOwnerId(widget.carBasicData);
    final carId = _extractCarId(widget.carBasicData);

    final extraSafetyFeatures = _uniqueFeatureNames(customSafetyFeatures);
    final extraComfortFeatures = _uniqueFeatureNames(customComfortFeatures);
    final extraInfotainmentFeatures = _uniqueFeatureNames(customInfoFeatures);
    final extraInteriorFeatures = _uniqueFeatureNames(customInteriorFeatures);
    final extraExteriorFeatures = _uniqueFeatureNames(customExteriorFeatures);

    final safetyFeatureIds = _partitionSelectedFeatureIds(
      selectedIds: selectedSafetyIds,
      apiFeatures: safetyVM.features,
      idOf: (f) => f.id,
      nameOf: (f) => f.name,
      createdByUserIdOf: (f) => f.createdByUserId,
      carIdOf: (f) => f.carId,
      isAdminOf: (f) => f.isAdmin,
      extraTarget: extraSafetyFeatures,
      ownerId: ownerId,
      carId: carId,
    );

    final comfortFeatureIds = _partitionSelectedFeatureIds(
      selectedIds: selectedComfortedIds,
      apiFeatures: comfortVM.comfort,
      idOf: (f) => f.id,
      nameOf: (f) => f.name,
      createdByUserIdOf: (f) => f.createdByUserId,
      carIdOf: (f) => f.carId,
      isAdminOf: (f) => f.isAdmin,
      extraTarget: extraComfortFeatures,
      ownerId: ownerId,
      carId: carId,
    );

    final infotainmentFeatureIds = _partitionSelectedFeatureIds(
      selectedIds: selectedInfoIds,
      apiFeatures: infoVM.infotainment,
      idOf: (f) => f.id,
      nameOf: (f) => f.name,
      createdByUserIdOf: (f) => f.createdByUserId,
      carIdOf: (f) => f.carId,
      isAdminOf: (f) => f.isAdmin,
      extraTarget: extraInfotainmentFeatures,
      ownerId: ownerId,
      carId: carId,
    );

    final interiorFeatureIds = _partitionSelectedFeatureIds(
      selectedIds: selectedInteriorIds,
      apiFeatures: interiorVM.interior,
      idOf: (f) => f.id,
      nameOf: (f) => f.name,
      createdByUserIdOf: (f) => f.createdByUserId,
      carIdOf: (f) => f.carId,
      isAdminOf: (f) => f.isAdmin,
      extraTarget: extraInteriorFeatures,
      ownerId: ownerId,
      carId: carId,
    );

    final exteriorFeatureIds = _partitionSelectedFeatureIds(
      selectedIds: selectedExteriorIds,
      apiFeatures: exteriorVM.exterior,
      idOf: (f) => f.id,
      nameOf: (f) => f.name,
      createdByUserIdOf: (f) => f.createdByUserId,
      carIdOf: (f) => f.carId,
      isAdminOf: (f) => f.isAdmin,
      extraTarget: extraExteriorFeatures,
      ownerId: ownerId,
      carId: carId,
    );

    return {
      // BASIC IDS
      ...widget.carBasicData,

      // OTHER DETAILS
      "insurance": carDetails.insurance,
      "service_history": carDetails.serviceHistory,

      // FEATURE IDS
      "safety_feature_ids": safetyFeatureIds,
      "comfort_feature_ids": comfortFeatureIds,
      "infotainment_feature_ids": infotainmentFeatureIds,
      "interior_feature_ids": interiorFeatureIds,
      "exterior_feature_ids": exteriorFeatureIds,

      // EXTRA FEATURES (TEXT)
      "extra_safety_features": _uniqueFeatureNames(extraSafetyFeatures),
      "extra_comfort_features": _uniqueFeatureNames(extraComfortFeatures),
      "extra_infotainment_features": _uniqueFeatureNames(
        extraInfotainmentFeatures,
      ),
      "extra_interior_features": _uniqueFeatureNames(extraInteriorFeatures),
      "extra_exterior_features": _uniqueFeatureNames(extraExteriorFeatures),

      // IMAGES
      "images": carImages.take(_maxCarImages).map((e) => e.path).toList(),

      // STATUS (default until user changes it on review screen)
      "status": "inactive",
    };
  }

  // To display the data
  Map<String, dynamic> buildPreviewData(BuildContext context) {
    final safetyVM = context.read<CarSafetyFeaturesViewModel>();
    final comfortVM = context.read<CarcomfortFeaturesViewModel>();
    final infoVM = context.read<CarInfotainmentFeaturesViewModel>();
    final interiorVM = context.read<CarInteriorFeaturesViewModel>();
    final exteriorVM = context.read<CarExteriorFeaturesViewModel>();

    return {
      // 👇 BASIC PREVIEW STRINGS
      ...widget.carPreviewData,

      // ✅ ADD THESE
      "insurance": carDetails.insurance,
      "serviceHistory": carDetails.serviceHistory,

      // 👇 FEATURES (NAMES ONLY)
      "safetyFeatures": [
        ...safetyVM.features
            .where((f) => selectedSafetyIds.contains(f.id))
            .map((f) => f.name),
        ...customSafetyFeatures.where(
          (f) => selectedSafetyIds.contains(f.hashCode),
        ),
      ],

      "comfortFeatures": [
        ...comfortVM.comfort
            .where((f) => selectedComfortedIds.contains(f.id))
            .map((f) => f.name),
        ...customComfortFeatures.where(
          (f) => selectedComfortedIds.contains(f.hashCode),
        ),
      ],

      "connectivityFeatures": [
        ...infoVM.infotainment
            .where((f) => selectedInfoIds.contains(f.id))
            .map((f) => f.name),
        ...customInfoFeatures.where(
          (f) => selectedInfoIds.contains(f.hashCode),
        ),
      ],

      "interiorFeatures": [
        ...interiorVM.interior
            .where((f) => selectedInteriorIds.contains(f.id))
            .map((f) => f.name),
        ...customInteriorFeatures.where(
          (f) => selectedInteriorIds.contains(f.hashCode),
        ),
      ],

      "exteriorFeatures": [
        ...exteriorVM.exterior
            .where((f) => selectedExteriorIds.contains(f.id))
            .map((f) => f.name),
        ...customExteriorFeatures.where(
          (f) => selectedExteriorIds.contains(f.hashCode),
        ),
      ],
    };
  }

  /// Selected API safety feature IDs
  final Set<int> selectedSafetyIds = {}; // selectedSafetyIds :====> id's
  final Set<int> selectedComfortedIds = {}; // selectedComfortedIds :====> id's
  final Set<int> selectedInfoIds = {}; //selectedInfoIds :====> id's
  final Set<int> selectedInteriorIds = {}; // selectedInterior :====> id's
  final Set<int> selectedExteriorIds = {}; //selectedExterior :====> id's

  /// User-added safety features (text)
  final List<String> customSafetyFeatures =
      []; // customSafetyFeatures :====> String
  final List<String> customComfortFeatures =
      []; // customComfortFeatures :====> String
  final List<String> customInfoFeatures =
      []; // customInfoFeatures :====> String
  final List<String> customInteriorFeatures =
      []; // customInteriorFeatures :====> String
  final List<String> customExteriorFeatures =
      []; // customExteriorFeatures :====> Strings

  // // // //
  // combinedSafetyFeatures :====>
  List<String> get combinedSafetyFeatures {
    final apiNames = context
        .read<CarSafetyFeaturesViewModel>()
        .features
        .map((e) => e.name)
        .toList();

    return [...apiNames, ...customSafetyFeatures];
  }

  // customComfortFeatures :====>
  List<String> get combinedComfortFeatures {
    final apiames = context
        .read<CarcomfortFeaturesViewModel>()
        .comfort
        .map((e) => e.name)
        .toList();
    return [...apiames, ...customComfortFeatures];
  }

  // combinedInfoFeatures :====>
  List<String> get combinedInfoFeatures {
    final apiames = context
        .read<CarInfotainmentFeaturesViewModel>()
        .infotainment
        .map((e) => e.name)
        .toList();
    return [...apiames, ...customInfoFeatures];
  }

  // combinedInteriorFeatures :====>
  List<String> get combinedInteriorFeatures {
    final apinames = context
        .read<CarInteriorFeaturesViewModel>()
        .interior
        .map((e) => e.name)
        .toList();
    return [...apinames, ...customInteriorFeatures];
  }

  // combinedExteriorFeatures :====>
  List<String> get combinedExteriorfeatures {
    final apinames = context
        .read<CarExteriorFeaturesViewModel>()
        .exterior
        .map((e) => e.name)
        .toList();
    return [...apinames, ...customExteriorFeatures];
  }
  // // // //

  // Navigations
  bool get isLastStep =>
      currentStep ==
      CarDetailsStep.imageUploadFields; // for next step - Next Button
  bool get isFirstStep => currentStep == CarDetailsStep.otherDetails;
  // for backward screen - Back Button

  /// STEP-WISE CUSTOM DATA
  final Map<CarDetailsStep, List<String>> stepOptionalData = {
    for (var step in CarDetailsStep.values) step: <String>[],
  };

  /// STEP-WISE SELECTED INDEXES
  final Map<CarDetailsStep, Set<int>> stepSelectedIndexes = {
    for (var step in CarDetailsStep.values) step: <int>{},
  };

  DateTime? selectedInsurance;
  String? selectedService;

  TextEditingController dataEnteringController = TextEditingController();

  List<String> get currentOptionalData => stepOptionalData[currentStep]!;
  Set<int> get currentSelectedIndexes => stepSelectedIndexes[currentStep]!;

  CarDetailsStep currentStep = CarDetailsStep.otherDetails; // currentStep

  final ImagePicker _picker = ImagePicker();
  final List<File> carImages = [];

  CarDetails carDetails = CarDetails();

  Widget _buildStepWidget(BuildContext context) {
    switch (currentStep) {
      case CarDetailsStep.otherDetails:
        return otherDetails(context);

      case CarDetailsStep.safetyFeatures:
        return saftyFeautersFields(context);

      case CarDetailsStep.comfortAndConvenience:
        return comfortAndConvenienceFields(context);

      case CarDetailsStep.informationAndConnectivity:
        return informationAndConnectivityFields(context);

      case CarDetailsStep.interiorFeatures:
        return interorFeaturesFields(context);

      case CarDetailsStep.exteriorFeatures:
        return exteriorFeaturesFields(context);

      case CarDetailsStep.imageUploadFields:
        return imageUploadFields(context);
    }
  }

  /// Check if file is a valid image format
  bool _isValidImageFile(String filePath) {
    final validExtensions = [
      'jpg',
      'jpeg',
      'png',
      'webp',
      'bmp',
      'tiff',
      'tif',
      'heic',
      'heif',
    ];
    final name = filePath.split('/').last;
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == name.length - 1) {
      // Picker sources are image-only; don't reject extension-less temp files.
      return true;
    }
    final extension = name.substring(dotIndex + 1).toLowerCase();
    return validExtensions.contains(extension);
  }

  Future<File> _compressImage(File file) async {
    final filePath = file.absolute.path;
    final name = filePath.split('/').last;
    final dotIndex = name.lastIndexOf('.');
    final extension = (dotIndex == -1 || dotIndex == name.length - 1)
        ? ''
        : name.substring(dotIndex + 1).toLowerCase();

    CompressFormat format;
    String outputExtension;

    switch (extension) {
      case 'png':
        format = CompressFormat.png;
        outputExtension = 'png';
        break;
      case 'webp':
        format = CompressFormat.webp;
        outputExtension = 'webp';
        break;
      case 'jpg':
      case 'jpeg':
      case 'bmp':
      case 'tiff':
      case 'tif':
      case 'heic':
      case 'heif':
      default:
        format = CompressFormat.jpeg;
        outputExtension = 'jpg';
    }

    final targetPath =
        "${file.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.$outputExtension";

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      filePath,
      targetPath,
      quality: 30,
      minWidth: 1024,
      minHeight: 1024,
      format: format,
    );

    return compressedFile != null ? File(compressedFile.path) : file;
  }

  Future<void> pickInsuranceValidity(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null) {
      setState(() {
        selectedInsurance = picked;

        final monthNames = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];

        final formatted = "${monthNames[picked.month - 1]} ${picked.year}";

        carDetails = carDetails.copyWith(
          insurance: formatted, // ✅ pass formatted string directly
        );
      });
    }
  }

  // _months
  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  @override
  void initState() {
    super.initState();
    // ✅ FETCH OPTIONAL FEATURES APIs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<CarSafetyFeaturesViewModel>()
          .fetchCarSafetyFeatures(); // CarSafetyFeaturesViewModel :====>
      context
          .read<CarcomfortFeaturesViewModel>()
          .fetchedComfortFeatures(); // CarcomfortFeaturesViewModel :====>
      context
          .read<CarInfotainmentFeaturesViewModel>()
          .fetchedInfotainmentFeatures(); // CarInfotainmentFeaturesViewModel :====>
      context
          .read<CarInteriorFeaturesViewModel>()
          .fetchInteriorFeayures(); // CarInteriorFeaturesViewModel :====>
      context
          .read<CarExteriorFeaturesViewModel>()
          .fetchExteriorFeatures(); // CarExteriorFeaturesViewModel :====>
    });
  }

  bool get _hasInputText => dataEnteringController.text.trim().isNotEmpty;

  void _handleAddOptionalInput() {
    FocusScope.of(context).unfocus();
    final text = dataEnteringController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      stepOptionalData[currentStep]!.add(text);
      stepSelectedIndexes[currentStep]!.add(
        stepOptionalData[currentStep]!.length - 1,
      );

      switch (currentStep) {
        case CarDetailsStep.safetyFeatures:
          if (!customSafetyFeatures.contains(text)) {
            customSafetyFeatures.add(text);
          }
          break;

        case CarDetailsStep.comfortAndConvenience:
          if (!customComfortFeatures.contains(text)) {
            customComfortFeatures.add(text);
          }
          break;

        case CarDetailsStep.informationAndConnectivity:
          if (!customInfoFeatures.contains(text)) {
            customInfoFeatures.add(text);
          }
          break;

        case CarDetailsStep.interiorFeatures:
          if (!customInteriorFeatures.contains(text)) {
            customInteriorFeatures.add(text);
          }
          break;

        case CarDetailsStep.exteriorFeatures:
          if (!customExteriorFeatures.contains(text)) {
            customExteriorFeatures.add(text);
          }
          break;

        default:
          break;
      }

      dataEnteringController.clear();
    });
  }

  void _goToNextOptionalStep() {
    if (currentStep == CarDetailsStep.otherDetails) {
      final hasInsurance =
          (carDetails.insurance ?? '').trim().isNotEmpty &&
          selectedInsurance != null;
      final hasServiceHistory =
          (carDetails.serviceHistory ?? '').trim().isNotEmpty &&
          selectedService != null;

      if (!hasInsurance || !hasServiceHistory) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please select Insurance Validity and Service History',
            ),
            backgroundColor: Color(0xffF47B39),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
    }

    final selected = currentSelectedIndexes
        .map((i) => currentOptionalData[i])
        .toList();
    switch (currentStep) {
      case CarDetailsStep.otherDetails:
        break;
      case CarDetailsStep.safetyFeatures:
        carDetails = carDetails.copyWith(safetyFeatures: selected);
        break;
      case CarDetailsStep.comfortAndConvenience:
        carDetails = carDetails.copyWith(comfortFeatures: selected);
        break;
      case CarDetailsStep.informationAndConnectivity:
        carDetails = carDetails.copyWith(connectivityFeatures: selected);
        break;
      case CarDetailsStep.interiorFeatures:
        carDetails = carDetails.copyWith(interiorFeatures: selected);
        break;
      case CarDetailsStep.exteriorFeatures:
        carDetails = carDetails.copyWith(exteriorFeatures: selected);
        break;
      case CarDetailsStep.imageUploadFields:
        break;
    }
    _advanceToNextStep();
  }

  void _advanceToNextStep() {
    setState(() {
      switch (currentStep) {
        case CarDetailsStep.otherDetails:
          currentStep = CarDetailsStep.safetyFeatures;
          break;

        case CarDetailsStep.safetyFeatures:
          currentStep = CarDetailsStep.comfortAndConvenience;
          break;

        case CarDetailsStep.comfortAndConvenience:
          currentStep = CarDetailsStep.informationAndConnectivity;
          break;

        case CarDetailsStep.informationAndConnectivity:
          currentStep = CarDetailsStep.interiorFeatures;
          break;

        case CarDetailsStep.interiorFeatures:
          currentStep = CarDetailsStep.exteriorFeatures;
          break;

        case CarDetailsStep.exteriorFeatures:
          currentStep = CarDetailsStep.imageUploadFields;
          break;

        case CarDetailsStep.imageUploadFields:
          break;
      }
    });
  }

  void _skipCurrentStep() {
    FocusScope.of(context).unfocus();
    _advanceToNextStep();
  }

  @override
  void dispose() {
    dataEnteringController.dispose();
    super.dispose();
  }

  bool isUploading = false;

  void _showPickerError(ImageSource source, Object error) {
    if (!mounted || !context.mounted) return;

    final action = source == ImageSource.camera ? 'camera' : 'gallery';
    String message = 'Could not open $action. Please try again.';

    if (error is PlatformException) {
      final raw = '${error.code} ${error.message ?? ''}'.toLowerCase();
      if (raw.contains('denied') || raw.contains('permission')) {
        message =
            'Please allow ${source == ImageSource.camera ? 'Camera' : 'Photos'} permission in Android settings.';
      } else if (raw.contains('activity') || raw.contains('cancel')) {
        message = 'No image selected from $action.';
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xffF47B39),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  if (isFirstStep) {
                    Navigator.pop(context);
                  }
                  setState(() {
                    switch (currentStep) {
                      case CarDetailsStep.safetyFeatures:
                        currentStep = CarDetailsStep.otherDetails;
                        break;

                      case CarDetailsStep.comfortAndConvenience:
                        currentStep = CarDetailsStep.safetyFeatures;
                        break;

                      case CarDetailsStep.informationAndConnectivity:
                        currentStep = CarDetailsStep.comfortAndConvenience;
                        break;

                      case CarDetailsStep.interiorFeatures:
                        currentStep = CarDetailsStep.informationAndConnectivity;
                        break;

                      case CarDetailsStep.exteriorFeatures:
                        currentStep = CarDetailsStep.interiorFeatures;
                        break;

                      case CarDetailsStep.imageUploadFields:
                        currentStep = CarDetailsStep.exteriorFeatures;
                        break;

                      case CarDetailsStep.otherDetails:
                        break;
                    }
                  });
                },
                child: isLastStep
                    ? Row()
                    : Row(
                        children: [
                          SizedBox(width: 10),
                          Icon(Icons.arrow_back_ios),
                          Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
              ),
              isLastStep ? Row() : const SizedBox.shrink(),
            ],
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Image.asset(
                        'assets/placeholders/add_a_car.png', // Title image
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Provide your car details and photos.\nPost your listing to reach potential buyers.', // Description text
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: Color.fromRGBO(41, 68, 135, 1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10),

              //  Expanded Starts Here ---->
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  reverseDuration: const Duration(milliseconds: 400),
                  switchInCurve: Curves.easeInOutCubic,
                  switchOutCurve: Curves.easeInOutCubic,
                  layoutBuilder: (currentChild, previousChildren) {
                    return Stack(
                      children: [
                        ...previousChildren,
                        if (currentChild != null) currentChild,
                      ],
                    );
                  },
                  transitionBuilder: (child, animation) {
                    final curved = CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOutCubic,
                    );

                    final slide = Tween<Offset>(
                      begin: const Offset(
                        0.15,
                        0,
                      ), // 👈 smaller distance = smoother
                      end: Offset.zero,
                    ).animate(curved);

                    final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(parent: animation, curve: Curves.easeIn),
                    );

                    return SlideTransition(
                      position: slide,
                      child: FadeTransition(opacity: fade, child: child),
                    );
                  },
                  child: Padding(
                    key: ValueKey(currentStep),
                    padding: const EdgeInsets.all(8.0),
                    child: _buildStepWidget(context),
                  ),
                ),
              ),

              //  Expanded Ends Here ---->
              SizedBox(height: 10),

              (isLastStep || currentStep == CarDetailsStep.otherDetails)
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.only(
                        left: 8,
                        right: 8,
                        bottom: 5,
                        top: 0,
                      ),
                      child: optionalDataInputField(context),
                    ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: isLastStep
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (isFirstStep) {
                                  Navigator.pop(context);
                                }
                                setState(() {
                                  switch (currentStep) {
                                    case CarDetailsStep.safetyFeatures:
                                      currentStep = CarDetailsStep.otherDetails;
                                      break;

                                    case CarDetailsStep.comfortAndConvenience:
                                      currentStep =
                                          CarDetailsStep.safetyFeatures;
                                      break;

                                    case CarDetailsStep
                                        .informationAndConnectivity:
                                      currentStep =
                                          CarDetailsStep.comfortAndConvenience;
                                      break;

                                    case CarDetailsStep.interiorFeatures:
                                      currentStep = CarDetailsStep
                                          .informationAndConnectivity;
                                      break;

                                    case CarDetailsStep.exteriorFeatures:
                                      currentStep =
                                          CarDetailsStep.interiorFeatures;
                                      break;

                                    case CarDetailsStep.imageUploadFields:
                                      currentStep =
                                          CarDetailsStep.exteriorFeatures;
                                      break;

                                    case CarDetailsStep.otherDetails:
                                      break;
                                  }
                                });
                              },
                              child: Container(
                                width: 170,
                                height: 50,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 2,
                                    color: ButtonsColors.GetStartedButton,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    'Previous',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: ButtonsColors.GetStartedButton,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 5),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (carImages.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Please upload at least 1 or 2 car images',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      backgroundColor: Color(0xffF47B39),
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                  return; // ❌ STOP navigation
                                }

                                if (carImages.length > _maxCarImages) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Maximum 10 images allowed',
                                      ),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  return;
                                }

                                // ✅ PROCEED ONLY IF IMAGE EXISTS
                                final previewData = buildPreviewData(context);
                                carDetails = carDetails.copyWith(
                                  images: carImages,
                                );

                                Navigator.pushNamed(
                                  context,
                                  carDetailsReview,
                                  arguments: {
                                    'carId':
                                        0, // 0 for new car (not yet posted)
                                    'showAppBar': false,
                                    'showBottomButtons': true,
                                    'carData': buildPostData(context),
                                    'previewData': previewData,
                                    'role': widget.role,
                                    'headerTitle': true,
                                  },
                                );
                              },
                              child: Container(
                                width: 170,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: ButtonsColors.GetStartedButton,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    'Next',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _skipCurrentStep,
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 2,
                                    color: ButtonsColors.GetStartedButton,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Skip',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: ButtonsColors.GetStartedButton,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: _hasInputText
                                  ? _handleAddOptionalInput
                                  : _goToNextOptionalStep,
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: ButtonsColors.GetStartedButton,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  _hasInputText ? 'Add Your Feature' : 'Next',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Other Deatils Container Starts ---->
  SingleChildScrollView otherDetails(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        color: const Color.fromRGBO(232, 237, 255, 1),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              // Header in the container ---
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CarOptinalDetails.otherDetaisl,
                  const SizedBox(width: 12),
                ],
              ),
              SizedBox(height: 15),
              InkWell(
                onTap: () => pickInsuranceValidity(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color.fromRGBO(190, 205, 255, 1),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      selectedInsurance == null
                          ? Text(
                              "Insurance Validity",
                              style: TextStyle(
                                fontSize: 16,
                                color: Color.fromRGBO(59, 59, 59, 1),
                              ),
                            )
                          : RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                                children: [
                                  const TextSpan(
                                    text: "Insurance Valid till : ",
                                  ),
                                  TextSpan(
                                    text:
                                        "${_monthName(selectedInsurance!.month)} ${selectedInsurance!.year}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      const Icon(
                        Icons.arrow_drop_down,
                        color: Color(0xFF2C3E8F),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              UserDropdownField<String>(
                hintText: CarOptinalDetails.service,
                fillColor: Colors.white,
                value: selectedService,
                items: [
                  DropdownMenuItem(
                    value: 'No, Service History is Available',
                    child: CarOptinalDetails.serivceNo,
                  ),
                  DropdownMenuItem(
                    value: 'Yes, Service History is Available',
                    child: CarOptinalDetails.serivceYes,
                  ),
                ],
                onChanged: (value) => setState(() {
                  selectedService = value;
                  carDetails = carDetails.copyWith(
                    serviceHistory: value == 'Yes, Service History is Available'
                        ? 'Yes, Available'
                        : 'No',
                  );
                }),
              ),
              const SizedBox(height: 10),
              // <---- Entered in the inputfield data are display here... ---->
              Wrap(
                spacing: 5,
                runSpacing: 5,
                children: List.generate(currentOptionalData.length, (index) {
                  final isSelected = currentSelectedIndexes.contains(index);

                  return ChoiceChip(
                    label: Text(
                      currentOptionalData[index],
                      style: TextStyle(
                        fontSize: 13,
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    selected: isSelected,
                    showCheckmark: false,
                    selectedColor: const Color(0xFF2C3E8F),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF2C3E8F)
                            : const Color.fromRGBO(190, 205, 255, 1),
                      ),
                    ),
                    onSelected: (_) {
                      setState(() {
                        // 🔁 toggle selection
                        if (isSelected) {
                          currentSelectedIndexes.remove(index);
                        } else {
                          currentSelectedIndexes.add(index);
                        }
                      });
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // Other Deatils Container Eds ---->

  // Optional input Fields Starts ---->
  SingleChildScrollView optionalDataInputField(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFF7A2E), width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: TextField(
                  controller: dataEnteringController,
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) {
                    if (_hasInputText) {
                      _handleAddOptionalInput();
                    }
                  },
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: CarOptinalDetails.generalHintText,
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // Optional input Fields Ends ---->

  // Other saftyFeautersFields Container Starts ---->
  SingleChildScrollView saftyFeautersFields(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            // height: MediaQuery.of(context).size.height,
            width: double.infinity,
            color: const Color.fromRGBO(232, 237, 255, 1),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  // Header in the container ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CarOptinalDetails.safety,
                      const SizedBox(width: 12),
                    ],
                  ),
                  SizedBox(height: 15),
                  // <---- Entered in the inputfield data are display here... ---->
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: List.generate(combinedSafetyFeatures.length, (
                      index,
                    ) {
                      final safetyVM = context
                          .watch<CarSafetyFeaturesViewModel>();
                      // debugPrint(
                      //   'statCarSafetyFeaturesViewModelement: ${safetyVM.features.length}',
                      // );
                      final isApiItem = index < safetyVM.features.length;

                      final label = combinedSafetyFeatures[index];

                      final isSelected = isApiItem
                          ? selectedSafetyIds.contains(
                              safetyVM.features[index].id,
                            )
                          : selectedSafetyIds.contains(label.hashCode);

                      return ChoiceChip(
                        label: Text(
                          label,
                          style: TextStyle(
                            fontSize: 13,
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                        selected: isSelected,
                        showCheckmark: false,
                        selectedColor: const Color(0xFF2C3E8F),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF2C3E8F)
                                : const Color.fromRGBO(190, 205, 255, 1),
                          ),
                        ),
                        onSelected: (_) {
                          setState(() {
                            if (isApiItem) {
                              final id = safetyVM.features[index].id;
                              isSelected
                                  ? selectedSafetyIds.remove(id)
                                  : selectedSafetyIds.add(id);
                            } else {
                              final id = label.hashCode;
                              isSelected
                                  ? selectedSafetyIds.remove(id)
                                  : selectedSafetyIds.add(id);
                            }
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  // Other saftyFeautersFields Container ends ---->

  // Other comfortAndConvenienceFields Container Starts ---->
  SingleChildScrollView comfortAndConvenienceFields(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            // height: MediaQuery.of(context).size.height,
            width: double.infinity,
            color: const Color.fromRGBO(232, 237, 255, 1),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  // Header in the container ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CarOptinalDetails.comfort,
                      const SizedBox(width: 12),
                    ],
                  ),
                  SizedBox(height: 15),
                  // <---- Entered in the inputfield data are display here... ---->
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: List.generate(combinedComfortFeatures.length, (
                      index,
                    ) {
                      final comfortVm = context
                          .watch<CarcomfortFeaturesViewModel>();
                      // debugPrint(
                      //   'CarcomfortFeaturesViewModel:${comfortVm.comfort.length}',
                      // );

                      final isApiItem = index < comfortVm.comfort.length;

                      final label = combinedComfortFeatures[index];

                      final isSelected = isApiItem
                          ? selectedComfortedIds.contains(
                              comfortVm.comfort[index].id,
                            )
                          : selectedComfortedIds.contains(label.hashCode);

                      return ChoiceChip(
                        label: Text(
                          label,
                          style: TextStyle(
                            fontSize: 13,
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                        selected: isSelected,
                        showCheckmark: false,
                        selectedColor: const Color(0xFF2C3E8F),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF2C3E8F)
                                : const Color.fromRGBO(190, 205, 255, 1),
                          ),
                        ),
                        onSelected: (_) {
                          setState(() {
                            if (isApiItem) {
                              final id = comfortVm.comfort[index].id;
                              isSelected
                                  ? selectedComfortedIds.remove(id)
                                  : selectedComfortedIds.add(id);
                            } else {
                              final id = label.hashCode;
                              isSelected
                                  ? selectedComfortedIds.remove(id)
                                  : selectedComfortedIds.add(id);
                            }
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  // Other comfortAndConvenienceFields Container ends ---->

  // Other informationAndConnectivityFields Container Starts ---->
  SingleChildScrollView informationAndConnectivityFields(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            // height: MediaQuery.of(context).size.height,
            width: double.infinity,
            color: const Color.fromRGBO(232, 237, 255, 1),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  // Header in the container ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CarOptinalDetails.info,
                      const SizedBox(width: 12),
                    ],
                  ),
                  SizedBox(height: 15),
                  // <---- Entered in the inputfield data are display here... ---->
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: List.generate(combinedInfoFeatures.length, (
                      index,
                    ) {
                      final infoVm = context
                          .watch<CarInfotainmentFeaturesViewModel>();
                      // debugPrint(
                      //   'CarcomfortFeaturesViewModel:${infoVm.infotainment.length}',
                      // );

                      final isApiItem = index < infoVm.infotainment.length;

                      final label = combinedInfoFeatures[index];

                      // final isSelected = currentSelectedIndexes.contains(index);

                      final isSelected = isApiItem
                          ? selectedInfoIds.contains(
                              infoVm.infotainment[index].id,
                            )
                          : selectedInfoIds.contains(label.hashCode);

                      return ChoiceChip(
                        label: Text(
                          label,
                          style: TextStyle(
                            fontSize: 13,
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                        selected: isSelected,
                        showCheckmark: false,
                        selectedColor: const Color(0xFF2C3E8F),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF2C3E8F)
                                : const Color.fromRGBO(190, 205, 255, 1),
                          ),
                        ),
                        onSelected: (_) {
                          setState(() {
                            if (isApiItem) {
                              final id = infoVm.infotainment[index].id;
                              isSelected
                                  ? selectedInfoIds.remove(id)
                                  : selectedInfoIds.add(id);
                            } else {
                              final id = label.hashCode;
                              isSelected
                                  ? selectedInfoIds.remove(id)
                                  : selectedInfoIds.add(id);
                            }
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Other informationAndConnectivityFields Container ends ---->

  // Other interorFeaturesFields Container Starts ---->
  SingleChildScrollView interorFeaturesFields(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            color: const Color.fromRGBO(232, 237, 255, 1),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  // Header in the container ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CarOptinalDetails.inter,
                      const SizedBox(width: 12),
                    ],
                  ),
                  SizedBox(height: 15),
                  // <---- Entered in the inputfield data are display here... ---->
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: List.generate(combinedInteriorFeatures.length, (
                      index,
                    ) {
                      final interVm = context
                          .watch<CarInteriorFeaturesViewModel>();
                      // debugPrint(
                      //   'CarInteriorFeaturesViewModel:${interVm.interior.length}',
                      // );

                      final isApiItem = index < interVm.interior.length;

                      final label = combinedInteriorFeatures[index];

                      final isSelected = isApiItem
                          ? selectedInteriorIds.contains(
                              interVm.interior[index].id,
                            )
                          : selectedInteriorIds.contains(label.hashCode);

                      return ChoiceChip(
                        label: Text(
                          label,
                          style: TextStyle(
                            fontSize: 13,
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                        selected: isSelected,
                        showCheckmark: false,
                        selectedColor: const Color(0xFF2C3E8F),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF2C3E8F)
                                : const Color.fromRGBO(190, 205, 255, 1),
                          ),
                        ),
                        onSelected: (_) {
                          setState(() {
                            if (isApiItem) {
                              final id = interVm.interior[index].id;
                              isSelected
                                  ? selectedInteriorIds.remove(id)
                                  : selectedInteriorIds.add(id);
                            } else {
                              final id = label.hashCode;
                              isSelected
                                  ? selectedInteriorIds.remove(id)
                                  : selectedInteriorIds.add(id);
                            }
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  // Other interorFeaturesFields Container ends ---->

  // Other exteriorFeaturesFields Container Starts ---->
  SingleChildScrollView exteriorFeaturesFields(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            color: const Color.fromRGBO(232, 237, 255, 1),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  // Header in the container ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CarOptinalDetails.exter,
                      const SizedBox(width: 12),
                    ],
                  ),
                  SizedBox(height: 15),
                  // <---- Entered in the inputfield data are display here... ---->
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: List.generate(combinedExteriorfeatures.length, (
                      index,
                    ) {
                      final exterVm = context
                          .watch<CarExteriorFeaturesViewModel>();

                      // debugPrint(
                      //   'CarExteriorFeaturesViewModel:${exterVm.exterior.length}',
                      // );

                      final isApiItem = index < exterVm.exterior.length;

                      final label = combinedExteriorfeatures[index];

                      final isSelected = isApiItem
                          ? selectedExteriorIds.contains(
                              exterVm.exterior[index].id,
                            )
                          : selectedExteriorIds.contains(label.hashCode);

                      return ChoiceChip(
                        label: Text(
                          label,
                          style: TextStyle(
                            fontSize: 13,
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                        selected: isSelected,
                        showCheckmark: false,
                        selectedColor: const Color(0xFF2C3E8F),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF2C3E8F)
                                : const Color.fromRGBO(190, 205, 255, 1),
                          ),
                        ),
                        onSelected: (_) {
                          setState(() {
                            if (isApiItem) {
                              final id = exterVm.exterior[index].id;
                              isSelected
                                  ? selectedExteriorIds.remove(id)
                                  : selectedExteriorIds.add(id);
                            } else {
                              final id = label.hashCode;
                              isSelected
                                  ? selectedExteriorIds.remove(id)
                                  : selectedExteriorIds.add(id);
                            }
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Other exteriorFeaturesFields Container ends ---->

  // Other imageUploadFields Container start ---->
  SizedBox imageUploadFields(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Car Photos (${carImages.length}/$_maxCarImages)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: const Color.fromRGBO(41, 68, 135, 1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Expanded(
            child: Stack(
              children: [
                AbsorbPointer(
                  absorbing: isUploading,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 5,
                        ),
                    itemCount: _maxCarImages,
                    itemBuilder: (context, index) {
                      final hasImage = index < carImages.length;

                      return GestureDetector(
                        onTap: () {
                          if (isUploading) return;

                          if (hasImage) {
                            _showImagePreview(context, carImages, index);
                          } else {
                            _showBottomSheet(context);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: hasImage
                                ? Image.file(
                                    carImages[index],
                                    fit: BoxFit.cover,
                                  )
                                : isUploading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Image.asset(
                                    'assets/placeholders/empty_img.png',
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    if (_remainingImageSlots <= 0) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maximum 10 images allowed'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color.fromRGBO(218, 218, 218, 1),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.20,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickImage(ImageSource.camera);
                  },
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    color: Colors.white,
                    child: Center(
                      child: Text(
                        'Take Photo',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickImage(ImageSource.gallery);
                  },
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    color: Colors.white,
                    child: Center(
                      child: Text(
                        'Choose from Gallery',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showImagePreview(
    BuildContext context,
    List<File> images,
    int initialIndex,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) {
        int currentIndex = initialIndex;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            // ✅ SAFETY CHECK
            if (images.isEmpty) {
              Navigator.pop(context);
              return const SizedBox.shrink();
            }

            // ✅ CLAMP INDEX
            if (currentIndex >= images.length) {
              currentIndex = images.length - 1;
            }

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// HEADER
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: currentIndex > 0
                                ? () {
                                    setDialogState(() {
                                      currentIndex--;
                                    });
                                  }
                                : null,
                          ),
                          Expanded(
                            child: Text(
                              'Photo ${currentIndex + 1}/${images.length}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: currentIndex < images.length - 1
                                ? () {
                                    setDialogState(() {
                                      currentIndex++;
                                    });
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ),

                    /// IMAGE
                    AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: isUploading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Image.file(
                                images[currentIndex],
                                fit: BoxFit.contain,
                              ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// DELETE
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.black54),
                      onPressed: () {
                        // ✅ UPDATE PARENT STATE
                        setState(() {
                          images.removeAt(currentIndex);
                        });

                        // ✅ UPDATE DIALOG STATE
                        setDialogState(() {
                          if (currentIndex >= images.length &&
                              images.isNotEmpty) {
                            currentIndex = images.length - 1;
                          }
                        });

                        // ✅ CLOSE IF EMPTY
                        if (images.isEmpty) {
                          Navigator.pop(context);
                        }
                      },
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final slotsBeforePick = _remainingImageSlots;
    if (slotsBeforePick <= 0) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maximum 10 images allowed'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      /// 📁 GALLERY (MULTIPLE IMAGES)
      if (source == ImageSource.gallery) {
        final List<XFile> pickedFiles = await _picker.pickMultiImage();

        if (pickedFiles.isEmpty) return;

        List<String> invalidFiles = [];
        int skippedByLimit = 0;
        int validCount = 0;

        for (final file in pickedFiles) {
          if (validCount >= slotsBeforePick) {
            skippedByLimit++;
            continue;
          }

          if (file.path.isEmpty) {
            invalidFiles.add('unknown');
            continue;
          }

          final fileName = file.path.split('/').last;

          // ✅ Validate file type is an image
          if (!_isValidImageFile(file.path)) {
            invalidFiles.add(fileName);
            continue;
          }

          final originalFile = File(file.path);
          if (!await originalFile.exists()) {
            invalidFiles.add(fileName);
            continue;
          }

          try {
            final compressed = await _compressImage(originalFile);
            carImages.add(compressed);
            validCount++;
          } catch (e) {
            invalidFiles.add(fileName);
          }
        }

        if (skippedByLimit > 0 && mounted && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Only $validCount image(s) added. Maximum $_maxCarImages images allowed.',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }

        // Show error if any invalid files were attempted
        if (invalidFiles.isNotEmpty && mounted && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '❌ Skipped ${invalidFiles.length} file(s). Only JPG, PNG, WebP, BMP, TIFF allowed.\n'
                'HEIC/HEIF are also supported. No GIF, videos, or other formats.',
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }

        setState(() {});
      }

      /// 📸 CAMERA (SINGLE IMAGE)
      if (source == ImageSource.camera) {
        final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.camera,
        );

        if (pickedFile != null) {
          // ✅ Validate camera photo is valid image
          if (!_isValidImageFile(pickedFile.path)) {
            if (mounted && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('❌ Invalid file format. Only images allowed.'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
            return;
          }

          final originalFile = File(pickedFile.path);
          final compressed = await _compressImage(originalFile);
          carImages.add(compressed);

          setState(() {});
        }
      }
    } on PlatformException catch (e) {
      _showPickerError(source, e);
    } on MissingPluginException catch (e) {
      // better platform support diagnostics
      _showPickerError(source, e);
    } catch (e, stackTrace) {
      debugPrint('Image pick failed: $e\n$stackTrace');
      _showPickerError(source, e);
    } finally {
      if (mounted) {
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  // Other imageUploadFields Container ends ---->
}
