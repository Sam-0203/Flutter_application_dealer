import 'package:dealershub_/src/utils/colors.dart';
import 'package:dealershub_/src/utils/route/route.dart';
import 'package:dealershub_/src/viewmodels/add_car_view_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_costants.dart';
import '../../../utils/widgets/input_field.dart';

class NewCarDetails extends StatefulWidget {
  final String role;
  const NewCarDetails({super.key, required this.role});

  @override
  State<NewCarDetails> createState() => _NewCarDetailsState();
}

class _NewCarDetailsState extends State<NewCarDetails> {
  @override
  void initState() {
    super.initState();

    // API data Calling
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<CarCompaniesListView>()
          .fetchCarCompanies(); // <== CarCompaniesListView ==>
      context
          .read<CarFueltypeListView>()
          .fetchCarFuelTypes(); // <== CarFueltypeListView ==>
      context
          .read<CarTransmissiotypeListView>()
          .fetchCarTransmissionTypes(); // <== CarTransmissiontypeListView ==>

      context
          .read<CarRRTOsListView>()
          .fetchCarRTOsRegistion(); // <== CarRRTOsListView ==>
      context
          .read<CarNumofOwner>()
          .fetchedRTOregister(); // <== CarRRTOsListView ==>
    });
  }

  // Dropdown values
  DateTime? selectedDate; // For manufactor year
  int? selectedMake; // For car make
  int? selectedModel; // For car model
  int? selectedFuelType; // For fuel type
  int? selectedTransmission; // For transmission type
  int? selectedVariant; // For car variant
  int? selectedColor; // For car color
  int? selectedReg; // For registration city
  int? selectedOwner; // For car owner(s)

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _kmController = TextEditingController();
  @override
  void dispose() {
    _dateController.dispose();
    _kmController.dispose();
    super.dispose();
  }

  // <=== : Select Year : ===>
  Future<void> _selectYear(BuildContext context) async {
    final now = DateTime.now();
    final pickedYear = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        DateTime displayedDate = selectedDate ?? DateTime(now.year - 20);
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () {
                            setState(
                              () => displayedDate = DateTime(
                                displayedDate.year - 12,
                              ),
                            );
                          },
                        ),
                        Text(
                          'Select year',
                          style: GoogleFonts.mulish(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F3C88),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () {
                            setState(
                              () => displayedDate = DateTime(
                                displayedDate.year + 12,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 300,
                      child: YearPicker(
                        firstDate: DateTime(1950),
                        lastDate: DateTime(now.year),
                        initialDate: displayedDate,
                        selectedDate: selectedDate ?? displayedDate,
                        onChanged: (value) =>
                            Navigator.of(context).pop(value.year),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.mulish(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1F3C88),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(now.year);
                          },
                          child: Text(
                            'Ok',
                            style: GoogleFonts.mulish(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1F3C88),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (pickedYear != null) {
      setState(() {
        selectedDate = DateTime(pickedYear);
        _dateController.text = pickedYear.toString();
      });
    }
  }

  Future<void> _showNumericKeypad(BuildContext context) async {
    // keep raw digits only when opening keypad (strip commas and non-digits)
    String raw = _kmController.text.replaceAll(RegExp(r'[^0-9]'), '');
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            String formatIndianNumber(String digits) {
              if (digits.isEmpty) return '0';
              String s = digits;
              int len = s.length;
              if (len <= 3) return s;
              String last3 = s.substring(len - 3);
              String rem = s.substring(0, len - 3);
              final parts = <String>[];
              while (rem.length > 2) {
                parts.insert(0, rem.substring(rem.length - 2));
                rem = rem.substring(0, rem.length - 2);
              }
              if (rem.isNotEmpty) parts.insert(0, rem);
              return '${parts.join(',')},$last3';
            }

            Widget numButton(String label, [String sub = '', int flex = 1]) {
              return Expanded(
                flex: flex,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      setState(() {
                        raw = '$raw$label';
                      });
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (sub.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            sub,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }

            return Container(
              color: Colors.grey[900],
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFFF7A1A),
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          raw.isEmpty
                                              ? '0 Kms'
                                              : "${formatIndianNumber(raw)} Kms",
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF7A1A),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        color: Colors.white,
                                        onPressed: () {
                                          _kmController.text = raw.isEmpty
                                              ? ''
                                              : '${formatIndianNumber(raw)} Kms';
                                          Navigator.of(context).pop();
                                        },
                                        icon: const Icon(Icons.arrow_forward),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                numButton('1'),
                                numButton('2'),
                                numButton('3'),
                              ],
                            ),
                            Row(
                              children: [
                                numButton('4'),
                                numButton('5'),
                                numButton('6'),
                              ],
                            ),
                            Row(
                              children: [
                                numButton('7'),
                                numButton('8'),
                                numButton('9'),
                              ],
                            ),
                            Row(
                              children: [
                                const Expanded(child: SizedBox()),
                                numButton('0'),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 18,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          if (raw.isNotEmpty) {
                                            raw = raw.substring(
                                              0,
                                              raw.length - 1,
                                            );
                                          }
                                        });
                                      },
                                      child: const Icon(
                                        Icons.backspace_outlined,
                                        size: 25,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('new ca details: ${widget.role}');
    // submitingData
    void submitingData() {
      // <=== : VALIDATION : ===>
      if (_dateController.text.trim().isEmpty ||
          selectedMake == null ||
          selectedModel == null ||
          selectedFuelType == null ||
          selectedTransmission == null ||
          selectedVariant == null ||
          selectedColor == null ||
          _kmController.text.trim().isEmpty ||
          selectedReg == null ||
          selectedOwner == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white, size: 30),
                SizedBox(width: 5),
                Text(
                  'Please fill all mandatory fields',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Color(0xffF47B39),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: Colors.white, width: 2),
            ),
          ),
        );
        return; // ⛔ STOP NAVIGATION
      }

      // <=== : Filled Data : ===>
      final Map<String, dynamic> carData = {
        "manufactorYear": _dateController.text.trim(),
        "make": selectedMake,
        "model": selectedModel,
        "fuelType": selectedFuelType,
        "transmission": selectedTransmission,
        "variant": selectedVariant,
        "color": selectedColor,
        "kilometers": _kmController.text.trim(),
        "registration": selectedReg,
        "owner": selectedOwner,
      };

      // <=== : Filled Data For Preview : ===>
      Map<String, dynamic> buildPreviewCarData(BuildContext context) {
        final companyVm = context.read<CarCompaniesListView>();
        final modelVm = context.read<CarModelsListView>();
        final fuelVm = context.read<CarFueltypeListView>();
        final transmissionVm = context.read<CarTransmissiotypeListView>();
        final variantVm = context.read<CarModelsVarietsListView>();
        final colorVm = context.read<CarColorListView>();
        final rtoVm = context.read<CarRRTOsListView>();
        final ownerVm = context.read<CarNumofOwner>();

        T? findById<T>(List<T> list, int? id, int Function(T) getId) {
          if (id == null) return null;
          try {
            return list.firstWhere((e) => getId(e) == id);
          } catch (_) {
            return null;
          }
        }

        return {
          "manufactorYear": _dateController.text.trim(),

          "make": findById(
            companyVm.carCompany,
            selectedMake,
            (e) => e.id,
          )?.name,

          "model": findById(
            modelVm.carModels,
            selectedModel,
            (e) => e.id,
          )?.name,

          "fuelType": findById(
            fuelVm.carFuelTypes,
            selectedFuelType,
            (e) => e.id,
          )?.name,

          "transmission": findById(
            transmissionVm.carTransmissionTypes,
            selectedTransmission,
            (e) => e.id,
          )?.name,

          "variant": findById(
            variantVm.carModelVarients,
            selectedVariant,
            (e) => e.id,
          )?.name,

          "color": findById(
            colorVm.carColors,
            selectedColor,
            (e) => e.id,
          )?.name,

          "kilometers": _kmController.text.trim(),

          "registration": findById(
            rtoVm.carRTOs,
            selectedReg,
            (e) => e.id,
          )?.code,

          "owner": findById(
            ownerVm.carOwners,
            selectedOwner,
            (e) => e.id,
          )?.name,
        };
      }

      final previewCarData = buildPreviewCarData(context);

      // debug details
      debugPrint("📦 Submitting car data 👉 $carData");
      debugPrint("📦 Preview car data 👉 $previewCarData");

      // <====: Successfully Navigation :====>
      Navigator.pushNamed(
        context,
        carOptionalDetails,
        arguments: {
          'carData': carData, // ← car-specific fields
          'carPreview': previewCarData,
          'role': widget.role, // ← user/app role (completely separate)
        },
      );
    }

    // API data Calling
    final carCompanyVm = context.watch<CarCompaniesListView>(); // Car Company
    final carModelVm = context.watch<CarModelsListView>(); // Car Model
    final carFuelTypeVm = context.watch<CarFueltypeListView>(); // Car Fuel Type
    final carTrasmission = context
        .watch<CarTransmissiotypeListView>(); // Car Transmission
    final carVarientvm = context
        .watch<CarModelsVarietsListView>(); // Car varients
    final carColorsVm = context.watch<CarColorListView>();
    final carRTOsVm = context.watch<CarRRTOsListView>();
    final carOwners = context.watch<CarNumofOwner>();

    // print values
    debugPrint('Car companies : ${carCompanyVm.carCompany.length}');
    debugPrint('Car models : ${carModelVm.carModels.length}');
    debugPrint('Car Fuel Type : ${carFuelTypeVm.carFuelTypes.length}');
    debugPrint(
      'Car Trasmission : ${carTrasmission.carTransmissionTypes.length}',
    );
    debugPrint('Car variants : ${carVarientvm.carModelVarients.length}');
    debugPrint('Car Colors : ${carColorsVm.carColors.length}');
    debugPrint('Car RTOs List : ${carRTOsVm.carRTOs.length}');
    debugPrint('Car Owner List : ${carOwners.carOwners.length}');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 10),
                Text(TextViews.cancel.data!, style: TextViews.cancel.style),
              ],
            ),
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
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: Color.fromRGBO(41, 68, 135, 1),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10),
              // Form fields in a scrollable area only
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(children: [TextViews.mandatory]),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _dateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: InputFieldPlaceholder.manufactorYear,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color.fromRGBO(190, 205, 255, 1),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color.fromRGBO(190, 205, 255, 1),
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon: const Icon(Icons.arrow_drop_down),
                          ),
                          onTap: () async {
                            await _selectYear(context);
                          },
                        ),
                        SizedBox(height: 10),

                        // For Car companies ====>
                        UserDropdownField<int>(
                          hintText: InputFieldPlaceholder.make,
                          value: selectedMake,
                          items: carCompanyVm.isLoading
                              ? [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Row(
                                      children: [
                                        SizedBox(width: 10),
                                        Icon(Icons.info_outline, size: 30),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'Feaching Car Compaines....!',
                                            style: GoogleFonts.mulish(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        CircularProgressIndicator(
                                          color: Colors.blue,
                                          strokeWidth: 2,
                                        ),
                                        SizedBox(width: 10),
                                      ],
                                    ),
                                  ),
                                ]
                              : carCompanyVm.carCompany.isEmpty
                              ? [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Row(
                                      children: [
                                        SizedBox(width: 10),
                                        Icon(Icons.info_outline, size: 30),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'No Data....!',
                                            style: GoogleFonts.mulish(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ]
                              : carCompanyVm.carCompany.map((company) {
                                  return DropdownMenuItem<int>(
                                    value: company.id,
                                    child: Text(company.name),
                                  );
                                }).toList(),
                          onChanged: (value) {
                            if (value == null) return;

                            setState(() {
                              selectedMake = value;
                              selectedModel = null;
                              selectedVariant = null; // reset model
                            });

                            context.read<CarModelsListView>().clear();
                            context.read<CarModelsListView>().fetchCarModels(
                              brandId: value,
                            );

                            context
                                .read<CarModelsVarietsListView>()
                                .clear(); // ✅ reset variants
                          },
                        ),

                        const SizedBox(height: 10),

                        // For Car model ====>
                        UserDropdownField<int>(
                          hintText: selectedMake == null
                              ? 'Select car company first'
                              : InputFieldPlaceholder.model,
                          value: selectedModel,
                          items: selectedMake == null
                              ? [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Row(
                                      children: [
                                        SizedBox(width: 10),
                                        Icon(Icons.info_outline, size: 30),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'Select car company first',
                                            style: GoogleFonts.mulish(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ]
                              : carModelVm.carModels.isEmpty
                              ? [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Row(
                                      children: [
                                        SizedBox(width: 10),
                                        Icon(Icons.info_outline, size: 30),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'There is No car Models for this company....!',
                                            style: GoogleFonts.mulish(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ]
                              : carModelVm.carModels.map((model) {
                                  return DropdownMenuItem<int>(
                                    value: model.id,
                                    child: Text(model.name),
                                  );
                                }).toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              selectedModel = value;
                              selectedVariant = null; // reset varient
                            });
                            final variantVm = context
                                .read<CarModelsVarietsListView>();
                            variantVm.clear(); // clear old variants
                            variantVm.fetchCarModelVrients(
                              modelId: value,
                            ); // ✅ API CALL
                          },
                        ),
                        const SizedBox(height: 10),

                        // Carr Fuel Types ====>
                        UserDropdownField<int>(
                          hintText: InputFieldPlaceholder.fuelType,
                          value: selectedFuelType,

                          items: carFuelTypeVm.isLoading
                              ? [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Row(
                                      children: [
                                        SizedBox(width: 10),
                                        Icon(Icons.info_outline, size: 30),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'Feaching Fuel Types....!',
                                            style: GoogleFonts.mulish(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        CircularProgressIndicator(
                                          color: Colors.blue,
                                          strokeWidth: 2,
                                        ),
                                        SizedBox(width: 10),
                                      ],
                                    ),
                                  ),
                                ]
                              : carFuelTypeVm.carFuelTypes.isEmpty
                              ? [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Row(
                                      children: [
                                        SizedBox(width: 10),
                                        Icon(Icons.info_outline, size: 30),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'No Data....!',
                                            style: GoogleFonts.mulish(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ]
                              : carFuelTypeVm.carFuelTypes.map((fuel) {
                                  return DropdownMenuItem<int>(
                                    value: fuel.id, // ✅ MUST BE STRING
                                    child: Text(fuel.name),
                                  );
                                }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedFuelType = value;
                            });
                          },
                        ),
                        const SizedBox(height: 10),

                        // Car transmission Types ====>
                        UserDropdownField<int>(
                          hintText: InputFieldPlaceholder.transmission,
                          value: selectedTransmission,
                          items: carTrasmission.isLoading
                              ? [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Row(
                                      children: [
                                        SizedBox(width: 10),
                                        Icon(Icons.info_outline, size: 30),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'Feaching Transmission Types....!',
                                            style: GoogleFonts.mulish(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        CircularProgressIndicator(
                                          color: Colors.blue,
                                          strokeWidth: 2,
                                        ),
                                        SizedBox(width: 10),
                                      ],
                                    ),
                                  ),
                                ]
                              : carTrasmission.carTransmissionTypes.isEmpty
                              ? [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Row(
                                      children: [
                                        SizedBox(width: 10),
                                        Icon(Icons.info_outline, size: 30),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'No Data....!',
                                            style: GoogleFonts.mulish(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ]
                              : carTrasmission.carTransmissionTypes.map((
                                  trans,
                                ) {
                                  return DropdownMenuItem<int>(
                                    value: trans.id,
                                    child: Text(trans.name),
                                  );
                                }).toList(),
                          onChanged: (value) =>
                              setState(() => selectedTransmission = value),
                        ),
                        const SizedBox(height: 10),

                        // Car Varients Types ====>
                        UserDropdownField<int>(
                          hintText: selectedModel == null
                              ? 'Select model first'
                              : InputFieldPlaceholder.variant,
                          value: selectedVariant,
                          items: selectedModel == null
                              ? [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 10),
                                        const Icon(
                                          Icons.info_outline,
                                          size: 30,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'Select model first',
                                            style: GoogleFonts.mulish(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ]
                              : carVarientvm.isLoading
                              ? const [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.5,
                                      ),
                                    ),
                                  ),
                                ]
                              : carVarientvm.carModelVarients.isEmpty
                              ? [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 10),
                                        const Icon(
                                          Icons.info_outline,
                                          size: 30,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'There is No Varients....!',
                                            style: GoogleFonts.mulish(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const CircularProgressIndicator(
                                          color: Color(0xffF47B39),
                                          strokeWidth: 1.5,
                                        ),
                                        const SizedBox(width: 10),
                                      ],
                                    ),
                                  ),
                                ]
                              : carVarientvm.carModelVarients.map((variant) {
                                  return DropdownMenuItem<int>(
                                    value: variant.id,
                                    child: Text(variant.name),
                                  );
                                }).toList(),

                          onChanged: (value) {
                            if (value == null) return;

                            setState(() {
                              selectedVariant = value;
                              selectedColor = null;
                            });

                            final colorVm = context.read<CarColorListView>();
                            colorVm.clear();
                            colorVm.fetchCarColors(
                              variantId: value,
                            ); // ✅ CORRECT
                          },
                        ),

                        const SizedBox(height: 10),

                        // Car Colors Types ====>
                        UserDropdownField<int>(
                          hintText: InputFieldPlaceholder.color,
                          value: selectedColor,
                          items: carColorsVm.isLoading
                              ? [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Row(
                                      children: [
                                        SizedBox(width: 10),
                                        Icon(Icons.info_outline, size: 30),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'Feaching Colors....!',
                                            style: GoogleFonts.mulish(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        CircularProgressIndicator(
                                          color: Colors.blue,
                                          strokeWidth: 2,
                                        ),
                                        SizedBox(width: 10),
                                      ],
                                    ),
                                  ),
                                ]
                              : carColorsVm.carColors.isEmpty
                              ? [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Row(
                                      children: [
                                        SizedBox(width: 10),
                                        Icon(Icons.info_outline, size: 30),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'No Data....!',
                                            style: GoogleFonts.mulish(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ]
                              : carColorsVm.carColors.map((colors) {
                                  return DropdownMenuItem<int>(
                                    value: colors.id,
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 44,
                                          height: 44,
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              color: colors.uiColor,
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(4),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Text(colors.name),
                                      ],
                                    ),
                                  );
                                }).toList(),
                          onChanged: (value) =>
                              setState(() => selectedColor = value),
                        ),
                        const SizedBox(height: 10),

                        // Car kilometers ====>
                        GestureDetector(
                          onTap: () => _showNumericKeypad(context),
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: _kmController,
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText:
                                    InputFieldPlaceholder.kilometersDriven,
                                hintStyle: GoogleFonts.mulish(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Color.fromRGBO(59, 59, 59, 1),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                counterText: '',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(190, 205, 255, 1),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(190, 205, 255, 1),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Car register ====>
                        UserDropdownField<int>(
                          hintText: InputFieldPlaceholder.registrationCity,
                          value: selectedReg,
                          items: carRTOsVm.isLoading
                              ? [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Row(
                                      children: [
                                        SizedBox(width: 10),
                                        Icon(Icons.info_outline, size: 30),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'Feaching Registers....!',
                                            style: GoogleFonts.mulish(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        CircularProgressIndicator(
                                          color: Colors.blue,
                                          strokeWidth: 2,
                                        ),
                                        SizedBox(width: 10),
                                      ],
                                    ),
                                  ),
                                ]
                              : carRTOsVm.carRTOs.isEmpty
                              ? [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Row(
                                      children: [
                                        SizedBox(width: 10),
                                        Icon(Icons.info_outline, size: 30),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'No Data....!',
                                            style: GoogleFonts.mulish(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ]
                              : carRTOsVm.carRTOs.map((rtos) {
                                  return DropdownMenuItem(
                                    value: rtos.id,
                                    child: Text(rtos.code),
                                  );
                                }).toList(),
                          onChanged: (value) =>
                              setState(() => selectedReg = value),
                        ),
                        const SizedBox(height: 10),
                        UserDropdownField<int>(
                          hintText: InputFieldPlaceholder.carOwner,
                          value: selectedOwner,
                          items: carOwners.isLoading
                              ? [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Row(
                                      children: [
                                        SizedBox(width: 10),
                                        Icon(Icons.info_outline, size: 30),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'Feaching Registers....!',
                                            style: GoogleFonts.mulish(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        CircularProgressIndicator(
                                          color: Colors.blue,
                                          strokeWidth: 2,
                                        ),
                                        SizedBox(width: 10),
                                      ],
                                    ),
                                  ),
                                ]
                              : carOwners.carOwners.isEmpty
                              ? [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Row(
                                      children: [
                                        SizedBox(width: 10),
                                        Icon(Icons.info_outline, size: 30),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'No Data....!',
                                            style: GoogleFonts.mulish(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ]
                              : carOwners.carOwners.map((owner) {
                                  return DropdownMenuItem(
                                    value: owner.id,
                                    child: Text(owner.name),
                                  );
                                }).toList(),

                          onChanged: (value) =>
                              setState(() => selectedOwner = value),
                        ),
                        const SizedBox(height: 25),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ButtonsColors.GetStartedButton,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),

                            onPressed: submitingData,
                            child: TextViews.next,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
