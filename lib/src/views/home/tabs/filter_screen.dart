import 'package:dealershub_/src/viewmodels/add_car_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class FilteringScreenDetails extends StatefulWidget {
  final String role;
  const FilteringScreenDetails({super.key, required this.role});

  @override
  State<FilteringScreenDetails> createState() => _FilteringScreenDetailsState();
}

class _FilteringScreenDetailsState extends State<FilteringScreenDetails> {
  int? selectedBrandId;
  Set<int> selectedModelIds = {};
  Set<int> selectedFuelIds = {};
  Set<int> selectedOwnerIds = {};

  int selectedIndex = 0;

  bool isSelected(int id) {
    switch (selectedIndex) {
      case 0:
        return selectedBrandId == id;
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

  Widget _buildFilterShimmerTile() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14, width: 140, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(height: 12, width: 90, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              height: 20,
              width: 20,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
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
    "Car Brands",
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
              Text(
                'Filters',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedBrandId = null;
                    selectedModelIds.clear();
                    selectedFuelIds.clear();
                    selectedOwnerIds.clear();
                  });
                },

                child: Text(
                  'Clear Filters',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
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
                      style: TextStyle(
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
                          bool isCurrentLoading = false;

                          // 👇 Switch based on selectedIndex
                          switch (selectedIndex) {
                            case 0:
                              isCurrentLoading = companyVM.isLoading;
                              currentList = companyVM.carCompany;
                              break;
                            case 1:
                              if (selectedBrandId != null) {
                                currentList = modelVM.allCarModels
                                    .where(
                                      (model) =>
                                          model.brandId == selectedBrandId,
                                    )
                                    .toList();
                              }
                              isCurrentLoading = modelVM.isLoading;
                              break;
                            case 2:
                              isCurrentLoading = fuelVM.isLoading;
                              currentList = fuelVM.carFuelTypes;
                              break;
                            case 3:
                              isCurrentLoading = ownerVM.isLoading;
                              currentList = ownerVM.carOwners;
                              break;
                          }

                          if (selectedIndex == 1 && selectedBrandId == null) {
                            return Center(
                              child: Text(
                                'Select one car brand \nto see car models.',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }

                          if (isCurrentLoading) {
                            return ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: 5,
                              itemBuilder: (context, index) {
                                return _buildFilterShimmerTile();
                              },
                            );
                          }

                          if (currentList.isEmpty) {
                            return Center(
                              child: Text(
                                selectedIndex == 1
                                    ? 'No models found for selected brand.'
                                    : 'No data found.',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: currentList.length,
                            itemBuilder: (context, index) {
                              // 👇 Adjust according to your API response model
                              final item = currentList[index];
                              final String name = item.name ?? item.title ?? "";
                              final int id = item.id;

                              if (selectedIndex == 0) {
                                return RadioListTile<int>(
                                  value: id,
                                  groupValue: selectedBrandId,
                                  onChanged: (int? value) {
                                    if (value == null) return;
                                    setState(() {
                                      if (selectedBrandId != value) {
                                        selectedBrandId = value;
                                        selectedModelIds.clear();
                                      }
                                    });
                                  },
                                  title: Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  activeColor: Colors.orange,
                                  controlAffinity:
                                      ListTileControlAffinity.trailing,
                                );
                              }

                              return CheckboxListTile(
                                value: isSelected(id),
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      switch (selectedIndex) {
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
                                  style: TextStyle(
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
              brandIds: selectedBrandId != null ? [selectedBrandId!] : [],
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
            style: TextStyle(
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
