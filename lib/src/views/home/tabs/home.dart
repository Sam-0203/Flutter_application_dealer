import 'dart:async';
import 'package:dealershub_/src/utils/route/route.dart';
import 'package:dealershub_/src/utils/responsive/responsive_helper.dart';
import 'package:dealershub_/src/utils/widgets/car_card.dart';
import 'package:dealershub_/src/viewmodels/add_car_view_model.dart';
import 'package:dealershub_/src/views/home/tabs/listofcars.dart';
import 'package:dealershub_/src/views/home/tabs/myinvetory.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:provider/provider.dart';

class HomeListOfCarsAndMyList extends StatefulWidget {
  final String? role;

  const HomeListOfCarsAndMyList({super.key, this.role});

  @override
  State<HomeListOfCarsAndMyList> createState() =>
      _HomeListOfCarsAndMyListState();
}

class _HomeListOfCarsAndMyListState extends State<HomeListOfCarsAndMyList> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(role: widget.role)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(widget.role);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Image.asset(
            'assets/placeholders/Typeforms & CTAs.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

// Placeholder for HomeListOfCarsAndMyList view
class HomeScreen extends StatefulWidget {
  final String? role;
  final int initialTab;
  final bool showSuccessDialog;

  const HomeScreen({
    super.key,
    this.role,
    this.initialTab = 0,
    this.showSuccessDialog = false,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late FocusNode _searchFocus;

  int _selectedIndex = 0;
  late TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchFocus = FocusNode();
    _selectedIndex = widget.initialTab;

    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _searchController = TextEditingController();

    // 🔥 LISTEN TO SEARCH TEXT
    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        final query = _searchController.text.trim();
        _searchByTabIndex(query);
      });
    });

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedIndex = _tabController.index;
          _searchController.clear();
        });
        FocusScope.of(context).unfocus();
      }
    });

    if (widget.showSuccessDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (context) => _showSuccessfulDialogbox(
            context,
            "Successfully Posted!",
            "Your car has been added to the inventory and shared with other dealers.",
          ),
        );
        // Auto-dismiss after 1 second
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.of(context).pop();
        });
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final fuelVm = context.read<CarFueltypeListView>();
      if (fuelVm.carFuelTypes.isEmpty && !fuelVm.isLoading) {
        fuelVm.fetchCarFuelTypes();
      }
    });

    debugPrint('Home $_selectedIndex');
  }

  void _searchByTabIndex(String query) {
    final activeTabIndex = _tabController.index;

    if (activeTabIndex == 1) {
      context.read<MyInventrySearchViewModel>().search(query);
      return;
    }

    context.read<SearchViewModel>().search(query);
  }

  @override
  void dispose() {
    _searchFocus.dispose();
    _tabController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveHelper.getDeviceType(context);
    final bool isTabletOrDesktop = deviceType != DeviceType.mobile;
    final double contentMaxWidth = deviceType == DeviceType.desktop
        ? 1120
        : (isTabletOrDesktop ? 900 : double.infinity);

    final double dealerTopHorizontalPadding = isTabletOrDesktop ? 20 : 16;
    final double dealerButtonSize = isTabletOrDesktop ? 56 : 50;
    final double dealerActionIconSize = isTabletOrDesktop ? 28 : 24;
    final double dealerTabLabelSize = isTabletOrDesktop ? 16 : 14;
    final double dealerSearchHeight = isTabletOrDesktop ? 56 : 52;

    final double agentTopHorizontalPadding = isTabletOrDesktop ? 20 : 16;
    final double agentButtonSize = isTabletOrDesktop ? 50 : 56;
    final double agentSearchHeight = agentButtonSize;
    final double agentSearchIconSize = isTabletOrDesktop ? 26 : 30;
    final double agentActionIconSize = isTabletOrDesktop ? 24 : 28;
    final double agentControlsGap = isTabletOrDesktop ? 8 : 10;

    debugPrint(widget.role);
    return Scaffold(
      body: SafeArea(
        child: widget.role == 'dealer'
            ? Column(
                children: [
                  /// 🔹 Top Section (Tabs + Actions)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: dealerTopHorizontalPadding,
                      vertical: 12,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: contentMaxWidth),
                        child: Row(
                          children: [
                            /// Tabs
                            Expanded(
                              child: Container(
                                height: dealerButtonSize,
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TabBar(
                                  controller: _tabController,
                                  dividerColor: Colors.transparent,
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  indicator: BoxDecoration(
                                    color: const Color(0xffF47B39),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  labelStyle: GoogleFonts.cairo(
                                    fontSize: dealerTabLabelSize,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  labelColor: Colors.white,
                                  unselectedLabelColor: Colors.black,
                                  tabs: const [
                                    Tab(text: 'List of Cars'),
                                    Tab(text: 'My Inventory'),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            /// Favorite Button
                            if (_selectedIndex == 1)
                              _buildActionButton(
                                icon: Icons.favorite,
                                size: dealerButtonSize,
                                iconSize: dealerActionIconSize,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    myfavoriteCarsRoute,
                                    arguments: {'role': widget.role},
                                  );
                                },
                              ),

                            if (_selectedIndex == 1) const SizedBox(width: 10),

                            /// Filter / Add Button
                            _buildActionButton(
                              icon: _selectedIndex == 0
                                  ? Icons.filter_list_alt
                                  : Icons.add,
                              size: dealerButtonSize,
                              iconSize: dealerActionIconSize,
                              onTap: () {
                                if (_selectedIndex == 0) {
                                  Navigator.pushNamed(
                                    context,
                                    filteringScreen,
                                    arguments: widget.role,
                                  );
                                } else {
                                  Navigator.pushNamed(
                                    context,
                                    newCarEntryRoute,
                                    arguments: widget.role,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  /// 🔍 Search Bar
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: dealerTopHorizontalPadding,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: contentMaxWidth),
                        child: Container(
                          height: dealerSearchHeight,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  focusNode: _searchFocus,
                                  textInputAction: TextInputAction.search,
                                  onChanged: (_) => setState(() {}),
                                  decoration: InputDecoration(
                                    hintText: _selectedIndex == 0
                                        ? 'Search cars...'
                                        : 'Search inventory...',
                                    border: InputBorder.none,
                                    hintStyle: GoogleFonts.mulish(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: const Color.fromRGBO(
                                        59,
                                        59,
                                        59,
                                        1,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              GestureDetector(
                                onTap: () {
                                  if (_searchController.text.isNotEmpty) {
                                    _searchController.clear();
                                    setState(() {});
                                  }
                                  FocusScope.of(context).unfocus();
                                },
                                child: Icon(
                                  _searchController.text.isNotEmpty
                                      ? Icons.close
                                      : Icons.search,
                                  color: Colors.black,
                                  size: 26,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// 🔹 Content Area
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: contentMaxWidth),
                        child: _searchController.text.isNotEmpty
                            ? _buildSearchResults()
                            : TabBarView(
                                controller: _tabController,
                                children: [
                                  Listofcars(role: widget.role),
                                  Myinvetory(role: widget.role),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: agentTopHorizontalPadding,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: contentMaxWidth),
                        child: Row(
                          children: [
                            // 🔍 Search Field
                            Expanded(
                              child: Container(
                                height: agentSearchHeight,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    isTabletOrDesktop ? 12 : 14,
                                  ),
                                  border: Border.all(
                                    color: Colors.blue.shade200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _searchController,
                                        textInputAction: TextInputAction.search,
                                        focusNode: _searchFocus,
                                        onChanged: (_) => setState(() {}),
                                        decoration: InputDecoration(
                                          hintText: 'Search cars...',
                                          border: InputBorder.none,
                                          hintStyle: GoogleFonts.mulish(
                                            fontSize: isTabletOrDesktop
                                                ? 15
                                                : 16,
                                            fontWeight: FontWeight.w400,
                                            color: const Color.fromRGBO(
                                              59,
                                              59,
                                              59,
                                              1,
                                            ),
                                          ),
                                          focusedBorder: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                        ),
                                      ),
                                    ),

                                    // Clear / Search Icon
                                    GestureDetector(
                                      onTap: () {
                                        _searchController.clear();
                                        setState(() {});
                                        FocusScope.of(context).unfocus();
                                      },
                                      child: Icon(
                                        _searchController.text.isNotEmpty
                                            ? Icons.close
                                            : Icons.search_rounded,
                                        color: Colors.black,
                                        size: agentSearchIconSize,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(width: agentControlsGap),

                            // 🎯 Filter Button
                            _buildActionButton(
                              icon: Icons.filter_list_alt,
                              size: agentButtonSize,
                              iconSize: agentActionIconSize,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  filteringScreen,
                                  arguments: widget.role,
                                );
                              },
                            ),

                            SizedBox(width: agentControlsGap),
                            _buildActionButton(
                              icon: Icons.favorite,
                              size: agentButtonSize,
                              iconSize: agentActionIconSize,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  myfavoriteCarsRoute,
                                  arguments: {'role': widget.role},
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: contentMaxWidth),
                        child: _searchController.text.isNotEmpty
                            ? _buildSearchResults()
                            : Listofcars(role: widget.role),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // KeyboardActionsConfig _buildConfig(BuildContext context) {
  //   return KeyboardActionsConfig(
  //     keyboardActionsPlatform: KeyboardActionsPlatform.ALL, // Better
  //     keyboardBarColor: Colors.grey[200],
  //     nextFocus: false,
  //     actions: [
  //       KeyboardActionsItem(
  //         focusNode: _searchFocus,
  //         toolbarButtons: [
  //           (node) => DoneButton(
  //             onTap: () {
  //               node.unfocus();
  //             },
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  Widget _buildSearchResults() {
    if (_tabController.index == 1) {
      return _buildMyInventorySearchResults();
    }
    return _buildListOfCarsSearchResults();
  }

  Widget _buildListOfCarsSearchResults() {
    return Consumer<SearchViewModel>(
      builder: (context, searchVM, child) {
        if (searchVM.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (searchVM.error != null) {
          return _buildSearchError(searchVM.error);
        }

        if (searchVM.cars.isEmpty) {
          return _buildEmptySearchState();
        }

        return ListView.builder(
          itemCount: searchVM.cars.length,
          itemBuilder: (context, index) {
            final car = searchVM.cars[index];

            return CarCard(
              key: ValueKey(car.id),
              car: Car(
                id: car.id,
                title:
                    "${car.brand.name} ${car.model.name} ${car.variant.name}",
                image: car.images.isNotEmpty ? car.images.first.imageUrl : '',
                fuel: car.fuelType.name,
                year: car.manufacturingYear,
                kms: car.kmRange,
                owner: car.ownerType.name,
                reg: car.rto.code,
                dealer: car.dealer.dealershipName,
                city: car.dealer.city,
                state: car.dealer.state,
              ),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  carDetailsReview,
                  arguments: {
                    'carId': car.id,
                    'showAppBar': true,
                    'showBottomButtons': false,
                    'role': widget.role,
                    'headerTitle': false,
                    'actionIcons': 'listOfCars',
                    'carData': {},
                    'previewData': {},
                  },
                );
              },
              icon: car.isFavorite
                  ? const Icon(Icons.favorite, color: Color(0xffF47B39))
                  : Icon(Icons.favorite_border, color: Colors.grey[800]),
            );
          },
        );
      },
    );
  }

  Widget _buildMyInventorySearchResults() {
    return Consumer<MyInventrySearchViewModel>(
      builder: (context, searchVM, child) {
        if (searchVM.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (searchVM.error != null) {
          return _buildSearchError(searchVM.error);
        }

        if (searchVM.cars.isEmpty) {
          return _buildEmptySearchState();
        }

        return ListView.builder(
          itemCount: searchVM.cars.length,
          itemBuilder: (context, index) {
            final car = searchVM.cars[index];

            return CarCard(
              key: ValueKey(car.id),
              car: Car(
                id: car.id,
                title:
                    "${car.brand.name} ${car.model.name} ${car.variant.name}",
                image: car.images.isNotEmpty ? car.images.first.imageUrl : '',
                fuel: car.fuelType.name,
                year: car.manufacturingYear,
                kms: car.kmRange,
                owner: car.ownerType.name,
                reg: car.rto.code,
                dealer: car.dealer.dealershipName,
                city: car.dealer.city,
                state: car.dealer.state,
              ),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  carDetailsReview,
                  arguments: {
                    'carId': car.id,
                    'showAppBar': true,
                    'showBottomButtons': false,
                    'role': widget.role,
                    'headerTitle': false,
                    'actionIcons': 'myInventory',
                    'carData': {},
                    'previewData': {},
                  },
                );
              },
              icon: car.isFavorite
                  ? const Icon(Icons.favorite, color: Color(0xffF47B39))
                  : const Icon(Icons.favorite_border, color: Colors.black),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchError(String? message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          message?.isNotEmpty == true
              ? message!
              : 'Failed to load search results. Please check your internet connection and try again.',
          textAlign: TextAlign.center,
          style: GoogleFonts.mulish(
            fontSize: 14,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySearchState() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, color: Colors.grey.shade400, size: 28),
          const SizedBox(width: 5),
          Text(
            "No Cars Found.",
            style: GoogleFonts.mulish(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable custom Done button
class DoneButton extends StatelessWidget {
  final VoidCallback onTap;
  const DoneButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          "Done",
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

Widget _buildActionButton({
  required IconData icon,
  required VoidCallback onTap,
  double size = 56,
  double iconSize = 28,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: const Color(0xffF47B39),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white, size: iconSize),
    ),
  );
}

Widget _showSuccessfulDialogbox(
  BuildContext context,
  String title,
  String message,
) {
  return Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF2DBE60), // green color
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Check Icon
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 40),
          ),

          const SizedBox(height: 20),

          /// Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.mulish(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 10),

          /// Message
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.mulish(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    ),
  );
}
