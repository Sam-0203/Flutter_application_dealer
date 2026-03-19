import 'package:dealershub_/src/viewmodels/add_car_view_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FilteringScreenDetails extends StatefulWidget {
  final String role;
  const FilteringScreenDetails({super.key, required this.role});

  @override
  State<FilteringScreenDetails> createState() => _FilteringScreenDetailsState();
}

class _FilteringScreenDetailsState extends State<FilteringScreenDetails> {
  // multiple selection variables
  Set<int> selectedBrandIds = {};
  Set<int> selectedModelIds = {};
  Set<int> selectedFuelIds = {};
  Set<int> selectedOwnerIds = {};

  int selectedIndex = 0;

  bool isSelected(int id) {
    switch (selectedIndex) {
      case 0:
        return selectedBrandIds.contains(id);
      case 1:
        return selectedModelIds.contains(id);
      case 2:
        return selectedFuelIds.contains(id);
      case 3:
        return selectedOwnerIds.contains(id);
      default:
        return false;
    }
  }

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
          .read<CarNumofOwner>()
          .fetchedRTOregister(); // <== CarRRTOsListView ==>
      context.read<AllCarModelsViewModel>().fetchAllCarModels();
    });
  }

  List<String> leftFilters = [
    "Car Companies",
    "Car Models",
    "Fuel Types",
    "Owners",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Row(
            children: [
              const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Filters',
                style: GoogleFonts.mulish(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedBrandIds.clear();
                    selectedModelIds.clear();
                    selectedFuelIds.clear();
                    selectedOwnerIds.clear();
                  });
                },

                child: Text(
                  'Clear Filters',
                  style: GoogleFonts.mulish(fontSize: 14, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),

      body: Row(
        children: [
          /// ---------------- LEFT SIDE ----------------
          Container(
            width: MediaQuery.of(context).size.width * 0.35,
            color: Colors.grey.shade200,
            child: ListView.builder(
              itemCount: leftFilters.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                    debugPrint('Index $index');
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: selectedIndex == index
                          ? Colors.white
                          : Colors.grey.shade200,
                      border: Border(
                        left: BorderSide(
                          color: selectedIndex == index
                              ? Colors.orange
                              : Colors.transparent,
                          width: 4,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 10,
                    ),
                    child: Text(
                      leftFilters[index],
                      style: GoogleFonts.mulish(
                        fontWeight: selectedIndex == index
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          /// ---------------- RIGHT SIDE ----------------
          Expanded(
            child: Container(
              color: Colors.white,
              child:
                  Consumer4<
                    CarCompaniesListView,
                    AllCarModelsViewModel,
                    CarFueltypeListView,
                    CarNumofOwner
                  >(
                    builder:
                        (context, companyVM, modelVM, fuelVM, ownerVM, child) {
                          List<dynamic> currentList = [];

                          // 👇 Switch based on selectedIndex
                          switch (selectedIndex) {
                            case 0:
                              currentList = companyVM.carCompany;
                              break;
                            case 1:
                              currentList = modelVM.allCarModels;
                              break;
                            case 2:
                              currentList = fuelVM.carFuelTypes;
                              break;
                            case 3:
                              currentList = ownerVM.carOwners;
                              break;
                          }

                          if (currentList.isEmpty) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          return ListView.builder(
                            itemCount: currentList.length,
                            itemBuilder: (context, index) {
                              // 👇 Adjust according to your API response model
                              final item = currentList[index];
                              final String name = item.name ?? item.title ?? "";
                              final int id = item.id;

                              return CheckboxListTile(
                                value: isSelected(id),
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      switch (selectedIndex) {
                                        case 0:
                                          selectedBrandIds.add(id);
                                          break;
                                        case 1:
                                          selectedModelIds.add(id);
                                          break;
                                        case 2:
                                          selectedFuelIds.add(id);
                                          break;
                                        case 3:
                                          selectedOwnerIds.add(id);
                                          break;
                                      }
                                    } else {
                                      switch (selectedIndex) {
                                        case 0:
                                          selectedBrandIds.remove(id);
                                          break;
                                        case 1:
                                          selectedModelIds.remove(id);
                                          break;
                                        case 2:
                                          selectedFuelIds.remove(id);
                                          break;
                                        case 3:
                                          selectedOwnerIds.remove(id);
                                          break;
                                      }
                                    }
                                  });
                                },

                                title: Text(
                                  name,
                                  style: GoogleFonts.mulish(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                controlAffinity:
                                    ListTileControlAffinity.trailing,
                              );
                            },
                          );
                        },
                  ),
            ),
          ),
        ],
      ),

      /// ---------------- BOTTOM APPLY BUTTON ----------------
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(15),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            minimumSize: const Size(double.infinity, 50),
          ),
          onPressed: () async {
            final filterVM = context.read<FilterCarViewModel>();

            await filterVM.getFilteredCars(
              brandIds: selectedBrandIds.toList(),
              fuelTypeIds: selectedFuelIds.toList(),
              ownerTypeIds: selectedOwnerIds.toList(),
              modelIds: selectedModelIds.toList(),
            );

            if (!context.mounted) return;

            // Set the filtered cars to the main list
            context.read<ListOfCarsViewModel>().setFilteredCars(
              filterVM.filteredCars,
            );

            Navigator.pop(context);
          },

          child: Text(
            "Apply",
            style: GoogleFonts.mulish(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
