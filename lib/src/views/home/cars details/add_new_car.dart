import 'dart:async';
import 'package:dealershub_/src/utils/app_costants.dart';
import 'package:dealershub_/src/utils/route/route.dart';
import 'package:dealershub_/src/utils/widgets/input_field.dart';
import 'package:dealershub_/src/viewmodels/add_car_viewmodel.dart';
import 'package:dealershub_/src/views/user/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:keyboard_actions/keyboard_actions_config.dart';
import 'package:provider/provider.dart';

class NewCarDetails extends StatefulWidget {
  final String role;

  const NewCarDetails({super.key, required this.role});

  @override
  State<NewCarDetails> createState() => _NewCarDetailsState();
}

class _NewCarDetailsState extends State<NewCarDetails> {
  late FocusNode _searchFocus;
  late FocusNode _phoneFocus;
  late FocusNode _registrationFocus;
  late FocusNode _rcStatusFocus;
  late FocusNode _makerFocus;
  late FocusNode _vehicleFocus;
  late FocusNode _fuelFocus;
  late FocusNode _manufacturingFocus;
  late FocusNode _registrationDateFocus;
  late FocusNode _ownerFocus;
  late FocusNode _engineNumberFocus;
  late FocusNode _engineCapacityFocus;
  late FocusNode _chassisFocus;
  late FocusNode _insuranceFocus;
  late FocusNode _policyFocus;
  late FocusNode _financedFocus;
  late FocusNode _rtoFocus;
  late FocusNode _colorFocus;
  late FocusNode _variantFocus;

  late FocusNode _roadTaxFocus;
  late FocusNode _priceFocus;
  late FocusNode _kmFocus;
  late FocusNode _featuresFocus;

  final TextEditingController searchController = TextEditingController();
  final TextEditingController registrationController = TextEditingController();
  final TextEditingController rcStatusController = TextEditingController();
  final TextEditingController makerController = TextEditingController();
  final TextEditingController vehicleController = TextEditingController();
  final TextEditingController fuelController = TextEditingController();
  final TextEditingController manufacturingController = TextEditingController();
  final TextEditingController registrationDateController =
      TextEditingController();
  final TextEditingController ownerController = TextEditingController();
  final TextEditingController engineNumberController = TextEditingController();
  final TextEditingController engineCapacityController =
      TextEditingController();
  final TextEditingController chassisController = TextEditingController();
  final TextEditingController insuranceController = TextEditingController();
  final TextEditingController policyController = TextEditingController();
  final TextEditingController financedController = TextEditingController();
  final TextEditingController rtoController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController roadTaxController = TextEditingController();

  final TextEditingController priceController = TextEditingController();
  final TextEditingController kmController = TextEditingController();
  final TextEditingController featuresController = TextEditingController();
  final TextEditingController variantController = TextEditingController();

  final List<String> enteredFeatures = [];

  String _formatInsuranceDate(DateTime? date) {
    if (date == null) return '-';

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

    return "Valid till ${date.day} ${months[date.month - 1]} ${date.year}";
  }

  String _formattaxPaidUpto(DateTime? date) {
    if (date == null) return '-';

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

    return "Paid until ${date.day} ${months[date.month - 1]} ${date.year}";
  }

  bool get _hasFeatureInputText => featuresController.text.trim().isNotEmpty;

  void _addFeature() {
    FocusScope.of(context).unfocus();
    final text = featuresController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      if (!enteredFeatures.contains(text)) {
        enteredFeatures.add(text);
      }
      featuresController.clear();
    });
  }

  void _removeFeature(String feature) {
    setState(() {
      enteredFeatures.remove(feature);
    });
  }

  @override
  void initState() {
    super.initState();
    _searchFocus = FocusNode();
    _phoneFocus = FocusNode();
    _registrationFocus = FocusNode();
    _rcStatusFocus = FocusNode();
    _makerFocus = FocusNode();
    _vehicleFocus = FocusNode();
    _fuelFocus = FocusNode();
    _manufacturingFocus = FocusNode();
    _registrationDateFocus = FocusNode();
    _ownerFocus = FocusNode();
    _engineNumberFocus = FocusNode();
    _engineCapacityFocus = FocusNode();
    _chassisFocus = FocusNode();
    _insuranceFocus = FocusNode();
    _policyFocus = FocusNode();
    _financedFocus = FocusNode();
    _rtoFocus = FocusNode();
    _colorFocus = FocusNode();

    _roadTaxFocus = FocusNode();
    _priceFocus = FocusNode();
    _kmFocus = FocusNode();
    _featuresFocus = FocusNode();
    _variantFocus = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RCDetailsViewModel>().reset();
    });
  }

  Future<void> _searchVehicle() async {
    final rcNumber = searchController.text.trim();

    if (rcNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter vehicle registration number"),
        ),
      );
      return;
    }
    // Clear previous search's user-entered data before fetching new results
    setState(() {
      enteredFeatures.clear();
      featuresController.clear();
      variantController.clear();
      priceController.clear();
      kmController.clear();
    });

    await context.read<RCDetailsViewModel>().searchVehicle(rcNumber);
  }

  @override
  void dispose() {
    searchController.dispose();
    registrationController.dispose();
    rcStatusController.dispose();
    makerController.dispose();
    vehicleController.dispose();
    fuelController.dispose();
    manufacturingController.dispose();
    registrationDateController.dispose();
    ownerController.dispose();
    engineNumberController.dispose();
    engineCapacityController.dispose();
    chassisController.dispose();
    insuranceController.dispose();
    policyController.dispose();
    financedController.dispose();
    rtoController.dispose();
    colorController.dispose();
    roadTaxController.dispose();

    priceController.dispose();
    kmController.dispose();
    featuresController.dispose();
    _registrationFocus.dispose();
    _rcStatusFocus.dispose();
    _makerFocus.dispose();
    _vehicleFocus.dispose();
    _fuelFocus.dispose();
    _manufacturingFocus.dispose();
    _registrationDateFocus.dispose();
    _ownerFocus.dispose();
    _engineNumberFocus.dispose();
    _engineCapacityFocus.dispose();
    _chassisFocus.dispose();
    _insuranceFocus.dispose();
    _policyFocus.dispose();
    _financedFocus.dispose();
    _rtoFocus.dispose();
    _colorFocus.dispose();
    _roadTaxFocus.dispose();

    _priceFocus.dispose();
    _kmFocus.dispose();
    _featuresFocus.dispose();
    super.dispose();
  }

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    try {
      return KeyboardActionsConfig(
        keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
        keyboardBarColor: Colors.grey[200],
        nextFocus: false,
        actions: [
          KeyboardActionsItem(
            focusNode: _searchFocus,
            toolbarButtons: [(node) => DoneButton(onTap: () => node.unfocus())],
          ),
          KeyboardActionsItem(
            focusNode: _phoneFocus,
            toolbarButtons: [(node) => DoneButton(onTap: () => node.unfocus())],
          ),
          KeyboardActionsItem(
            focusNode: _variantFocus,
            toolbarButtons: [(node) => DoneButton(onTap: () => node.unfocus())],
          ),
          KeyboardActionsItem(
            focusNode: _priceFocus,
            toolbarButtons: [(node) => DoneButton(onTap: () => node.unfocus())],
          ),
          KeyboardActionsItem(
            focusNode: _kmFocus,
            toolbarButtons: [(node) => DoneButton(onTap: () => node.unfocus())],
          ),
          KeyboardActionsItem(
            focusNode: _featuresFocus,
            toolbarButtons: [(node) => DoneButton(onTap: () => node.unfocus())],
          ),
        ],
      );
    } catch (e) {
      debugPrint('Error in _buildConfig: $e');
      return KeyboardActionsConfig(
        keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
        keyboardBarColor: Colors.grey[200],
        nextFocus: false,
        actions: [],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        title: Image.asset(
          'assets/placeholders/add_a_car.png',
          height: 26,
          fit: BoxFit.contain,
        ),
      ),
      body: SafeArea(
        child: KeyboardActions(
          disableScroll: true,
          config: _buildConfig(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Provide your car details and photos. Post your listing to reach potential buyers.',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                    height: 1.4,
                    color: Color.fromRGBO(41, 68, 135, 1),
                  ),
                ),

                const SizedBox(height: 28),

                Text(
                  "Find your car",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xffF47B39).withOpacity(0.10),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.directions_car_filled_rounded,
                          color: Color(0xffF47B39),
                          size: 22,
                        ),
                      ),
                      Expanded(
                        child: UserInputField(
                          controller: searchController,
                          focusNode: _searchFocus,
                          hintText: InputFieldPlaceholder.carSearch,
                          keyboardType: TextInputType.text,
                          suffixIcon: const Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                          showClearIcon: true,
                          onSubmitted: (_) async {
                            await _searchVehicle();
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 15,
                      color: Colors.black38,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "Enter your car's registration number to auto-fill details.",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                Expanded(
                  child: SingleChildScrollView(
                    child: Consumer<RCDetailsViewModel>(
                      builder: (context, vm, _) {
                        if (vm.error != null) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Center(
                              child: Text(
                                vm.error!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          );
                        }

                        if (vm.isLoading) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (vm.rcData == null) {
                          return const SizedBox.shrink();
                        }

                        final rc = vm
                            .rcData!
                            .data
                            .data; // RcUploadDetailedResponse -> RcUploadResponseData -> RCData

                        registrationController.text = rc.rcNumber;
                        rcStatusController.text = rc.rcStatus;
                        makerController.text = rc.makerDescription;
                        vehicleController.text = rc.makerModel;
                        fuelController.text = rc.fuelType;

                        manufacturingController.text =
                            rc.manufacturingDateFormatted ?? "";

                        registrationDateController.text =
                            rc.registrationDate != null
                            ? "${rc.registrationDate!.day.toString().padLeft(2, '0')}-${rc.registrationDate!.month.toString().padLeft(2, '0')}-${rc.registrationDate!.year}"
                            : "";

                        ownerController.text = rc.ownerName;
                        engineNumberController.text = rc.vehicleEngineNumber;

                        engineCapacityController.text =
                            rc.cubicCapacity.isNotEmpty
                            ? "${double.parse(rc.cubicCapacity).toInt()} CC"
                            : "";

                        chassisController.text = rc.vehicleChasiNumber;

                        insuranceController.text = _formatInsuranceDate(
                          rc.insuranceUpto,
                        );

                        policyController.text = rc.insurancePolicyNumber;

                        financedController.text = rc.financed
                            ? "Yes (${rc.financer})"
                            : "No";

                        rtoController.text = rc.registeredAt;

                        colorController.text = rc.color;

                        roadTaxController.text = _formattaxPaidUpto(
                          rc.taxPaidUpto,
                        );

                        return Column(
                          children: [
                            CarFetchedDetails(
                              label: 'Registration Number',
                              controller: registrationController,
                              focusNode: _registrationFocus,
                            ),
                            CarFetchedDetails(
                              label: 'RC Status',
                              controller: rcStatusController,
                              focusNode: _rcStatusFocus,
                            ),
                            CarFetchedDetails(
                              label: 'Maker',
                              controller: makerController,
                              focusNode: _makerFocus,
                            ),
                            CarFetchedDetails(
                              label: 'Vehicle',
                              controller: vehicleController,
                              focusNode: _vehicleFocus,
                            ),
                            CarFetchedDetails(
                              label: 'Fuel Type',
                              controller: fuelController,
                              focusNode: _fuelFocus,
                            ),
                            CarFetchedDetails(
                              label: "Manufacturing Date",
                              controller: manufacturingController,
                              readOnly: true,
                              suffixIcon: const Icon(Icons.calendar_today),
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1990),
                                  lastDate: DateTime.now(),
                                );

                                if (picked != null) {
                                  manufacturingController.text =
                                      "${picked.month.toString().padLeft(2, '0')}-${picked.year}";
                                }
                              },
                            ),
                            CarFetchedDetails(
                              label: "Registration Date",
                              controller: registrationDateController,
                              readOnly: true,
                              suffixIcon: const Icon(Icons.calendar_today),
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1990),
                                  lastDate: DateTime.now(),
                                );

                                if (picked != null) {
                                  registrationDateController.text =
                                      "${picked.day.toString().padLeft(2, '0')}-"
                                      "${picked.month.toString().padLeft(2, '0')}-"
                                      "${picked.year}";
                                }
                              },
                            ),
                            CarFetchedDetails(
                              label: 'Owner Name',
                              controller: ownerController,
                              focusNode: _ownerFocus,
                            ),
                            CarFetchedDetails(
                              label: 'Engine Number',
                              controller: engineNumberController,
                              focusNode: _engineNumberFocus,
                            ),
                            CarFetchedDetails(
                              label: 'Engine Capacity',
                              controller: engineCapacityController,
                              focusNode: _engineCapacityFocus,
                              keyboardType: TextInputType.number,
                            ),
                            CarFetchedDetails(
                              label: 'Chassis Number',
                              controller: chassisController,
                              focusNode: _chassisFocus,
                            ),
                            CarFetchedDetails(
                              label: "Insurance valid till",
                              controller: insuranceController,
                              readOnly: true,
                              suffixIcon: const Icon(Icons.calendar_today),
                            ),
                            CarFetchedDetails(
                              label: 'Policy Number',
                              controller: policyController,
                              focusNode: _policyFocus,
                            ),
                            CarFetchedDetails(
                              label: 'Financed',
                              controller: financedController,
                              focusNode: _financedFocus,
                            ),
                            CarFetchedDetails(
                              label: 'RTO',
                              controller: rtoController,
                              focusNode: _rtoFocus,
                            ),

                            CarFetchedDetails(
                              label: 'Color',
                              controller: colorController,
                              focusNode: _colorFocus,
                            ),
                            CarFetchedDetails(
                              label: 'Road tax valid/paid till',
                              controller: roadTaxController,
                              focusNode: _roadTaxFocus,
                            ),
                            CarFetchedDetails(
                              label: 'Price',
                              controller: priceController,
                              focusNode: _priceFocus,
                              hintText: 'Enter price',
                              keyboardType: TextInputType.number,
                              prefixText: '₹ ',
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                IndianNumberFormatter(),
                              ],
                            ),
                            CarFetchedDetails(
                              label: 'Kilometers driven',
                              controller: kmController,
                              focusNode: _kmFocus,
                              hintText: 'Enter kilometers driven',
                              keyboardType: TextInputType.number,
                              suffixText: ' km',
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                IndianNumberFormatter(),
                              ],
                            ),

                            const SizedBox(height: 5),

                            // ── Features ──────────────────────────────
                            // Container(
                            //   margin: const EdgeInsets.symmetric(vertical: 5),
                            //   padding: const EdgeInsets.all(12),
                            //   decoration: BoxDecoration(
                            //     color: Colors.white,
                            //     borderRadius: BorderRadius.circular(12),
                            //     border: Border.all(
                            //       color: const Color(0xffF47B39),
                            //     ),
                            //   ),
                            //   child: Column(
                            //     crossAxisAlignment: CrossAxisAlignment.start,
                            //     children: [
                            //       Text(
                            //         'Features',
                            //         style: TextStyle(
                            //           fontSize: 12,
                            //           fontWeight: FontWeight.w500,
                            //           color: Colors.black45,
                            //           letterSpacing: 0.2,
                            //         ),
                            //       ),
                            //       const SizedBox(height: 8),
                            //       Row(
                            //         children: [
                            //           Expanded(
                            //             child: TextField(
                            //               controller: featuresController,
                            //               focusNode: _featuresFocus,
                            //               onChanged: (_) => setState(() {}),
                            //               onSubmitted: (_) => _addFeature(),
                            //               style: const TextStyle(
                            //                 fontSize: 15,
                            //                 fontWeight: FontWeight.w700,
                            //                 color: Colors.black87,
                            //               ),
                            //               decoration: InputDecoration(
                            //                 isDense: true,
                            //                 contentPadding: EdgeInsets.zero,
                            //                 border: InputBorder.none,
                            //                 hintText: 'Enter car feature',
                            //                 hintStyle: const TextStyle(
                            //                   fontSize: 15,
                            //                   fontWeight: FontWeight.w500,
                            //                   color: Colors.black38,
                            //                 ),
                            //               ),
                            //             ),
                            //           ),
                            //           if (_hasFeatureInputText)
                            //             GestureDetector(
                            //               onTap: _addFeature,
                            //               child: const Padding(
                            //                 padding: EdgeInsets.only(left: 8),
                            //                 child: Icon(
                            //                   Icons.add_circle,
                            //                   color: Color(0xffF47B39),
                            //                   size: 22,
                            //                 ),
                            //               ),
                            //             ),
                            //         ],
                            //       ),
                            //       if (enteredFeatures.isNotEmpty) ...[
                            //         const SizedBox(height: 10),
                            //         Wrap(
                            //           spacing: 6,
                            //           runSpacing: 6,
                            //           children: enteredFeatures.map((feature) {
                            //             return Chip(
                            //               label: Text(
                            //                 feature,
                            //                 style: const TextStyle(
                            //                   fontSize: 13,
                            //                   color: Colors.white,
                            //                   fontWeight: FontWeight.w600,
                            //                 ),
                            //               ),
                            //               backgroundColor: const Color(
                            //                 0xffF47B39,
                            //               ),
                            //               deleteIcon: const Icon(
                            //                 Icons.close,
                            //                 size: 16,
                            //                 color: Colors.white,
                            //               ),
                            //               onDeleted: () =>
                            //                   _removeFeature(feature),
                            //               shape: RoundedRectangleBorder(
                            //                 borderRadius: BorderRadius.circular(
                            //                   8,
                            //                 ),
                            //               ),
                            //             );
                            //           }).toList(),
                            //         ),
                            //       ],
                            //     ],
                            //   ),
                            // ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Consumer<RCDetailsViewModel>(
            builder: (context, vm, _) {
              final hasResults = vm.rcData != null;

              return Row(
                children: [
                  if (hasResults) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          final rc = vm.rcData!.data.data;

                          Navigator.pushNamed(
                            context,
                            carImageUpload,
                            arguments: {
                              'carData': {
                                'registrationNumber': rc.rcNumber,
                                'rcStatus': rc.rcStatus,
                                'maker': rc.makerDescription,
                                'vehicle': rc.makerModel,
                                'fuelType': rc.fuelType,
                                'manufacturingDate':
                                    rc.manufacturingDateFormatted,
                                'registrationDate': rc.registrationDate != null
                                    ? "${rc.registrationDate!.day.toString().padLeft(2, '0')}-${rc.registrationDate!.month.toString().padLeft(2, '0')}-${rc.registrationDate!.year}"
                                    : '-',
                                'ownerName': rc.ownerName,
                                'ownerType': rc.ownerNumber,
                                'engineNumber': rc.vehicleEngineNumber,
                                'engineCapacity':
                                    "${double.parse(rc.cubicCapacity).toInt()} CC",
                                'chassisNumber': rc.vehicleChasiNumber,
                                'insurance': _formatInsuranceDate(
                                  rc.insuranceUpto,
                                ),
                                'rcNumber': rc.rcNumber,
                                'policyNumber': rc.insurancePolicyNumber,
                                'financed': rc.financed
                                    ? 'Yes (${rc.financer})'
                                    : 'No',
                                'rto': rc.registeredAt,
                                'vehicleClass': rc.vehicleCategoryDescription,
                                'color': rc.color,
                                'roadTax': _formattaxPaidUpto(rc.taxPaidUpto),
                                'variant': variantController.text.trim(),
                                'price': priceController.text.trim(),
                                'kilometersDriven': kmController.text.trim(),
                                'features': List<String>.from(enteredFeatures),
                              },
                              'role': widget.role,
                            },
                          );
                        },
                        child: Container(
                          height: 52,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xffF47B39),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Proceed",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(width: 10),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class CarFetchedDetails extends StatelessWidget {
  final List<TextInputFormatter>? inputFormatters;
  final String label;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? hintText;
  final TextInputType keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final int maxLines;
  final String? prefixText;
  final String? suffixText;

  const CarFetchedDetails({
    super.key,
    required this.label,
    required this.controller,
    this.prefixText,
    this.suffixText,
    this.focusNode,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.onTap,
    this.inputFormatters,
    this.suffixIcon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffF47B39)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black45,
            ),
          ),

          const SizedBox(height: 6),

          TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            readOnly: readOnly,
            maxLines: maxLines,
            onTap: onTap,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: hintText ?? "Enter $label",
              suffixIcon: suffixIcon,
            ),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class IndianNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll(',', '');

    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final number = int.tryParse(text);
    if (number == null) return oldValue;

    final formatted = NumberFormat('#,##,##0', 'en_IN').format(number);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
