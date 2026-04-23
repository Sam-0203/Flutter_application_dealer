import 'dart:async';
import 'package:dealershub_/src/utils/route/route.dart';
import 'package:dealershub_/src/utils/responsive/responsive_helper.dart';
import 'package:dealershub_/src/utils/widgets/car_card.dart';
import 'package:dealershub_/src/utils/widgets/car_shimmer.dart';
import 'package:dealershub_/src/viewmodels/add_car_viewmodel.dart';
import 'package:dealershub_/src/views/home/Sidemenu.dart';
import 'package:dealershub_/src/views/home/tabs/listofcars.dart';
import 'package:dealershub_/src/views/home/tabs/myinvetory.dart';
import 'package:flutter/material.dart';
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

    Future.delayed(const Duration(seconds: 5), () {
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

  String _normalizedRole() {
    final role = (widget.role ?? '').trim().toLowerCase();
    if (role.contains('dealer')) return 'dealer';
    if (role.contains('agent')) return 'agent';
    return role;
  }

  String? _roleForNavigation() {
    final normalizedRole = _normalizedRole();
    if (normalizedRole.isNotEmpty) return normalizedRole;

    final rawRole = widget.role?.trim();
    if (rawRole == null || rawRole.isEmpty) return null;
    return rawRole;
  }

  @override
  void initState() {
    super.initState();
    _searchFocus = FocusNode();
    _selectedIndex = widget.initialTab;

    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
      animationDuration: const Duration(milliseconds: 500),
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

  void _clearSearchBar() {
    if (_searchController.text.isNotEmpty) {
      _searchController.clear();
    }
    _debounce?.cancel();
    FocusScope.of(context).unfocus();
    context.read<SearchViewModel>().search('');
    context.read<MyInventrySearchViewModel>().search('');
  }

  Future<bool> _addToFavoritesByRole(int carId) async {
    final resolvedRole = _normalizedRole();

    if (resolvedRole == 'dealer') {
      final favVM = context.read<AddToFavoriteViewModel>();
      return favVM.addToFavorite(carId);
    }

    if (resolvedRole == 'agent') {
      final favVM = context.read<AddFavCarsAgentsViewModel>();
      return favVM.addToFavorite(carId);
    }

    // Fallback when role could not be inferred reliably.
    final dealerVM = context.read<AddToFavoriteViewModel>();
    final agentVM = context.read<AddFavCarsAgentsViewModel>();
    final dealerSuccess = await dealerVM.addToFavorite(carId);
    if (dealerSuccess) return true;

    return agentVM.addToFavorite(carId);
  }

  Future<void> _handleSearchFavoriteTap(dynamic car) async {
    if (car.isFavorite == true) {
      return;
    }

    final addedSuccessfully = await _addToFavoritesByRole(car.id);
    if (!mounted) return;

    if (addedSuccessfully) {
      setState(() {
        car.isFavorite = true;
      });
    }
  }

  Future<void> _openFavoritesAndHandleBack() async {
    final roleForNavigation = _roleForNavigation();
    _clearSearchBar();
    final result = await Navigator.pushNamed(
      context,
      myFavoriteCarsRoute,
      arguments: {'role': roleForNavigation},
    );

    if (!mounted) return;

    final shouldClearSearch = result is Map<String, dynamic>
        ? result['clearSearch'] == true
        : false;

    if (shouldClearSearch) {
      _clearSearchBar();
    }

    await context.read<ListOfCarsViewModel>().fetchingListOfCars();
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
    final normalizedRole = _normalizedRole();
    final roleForNavigation = _roleForNavigation();
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

    debugPrint(roleForNavigation);
    return Scaffold(
      drawer: SideBarMenu(
        role: normalizedRole,
        onFavoritesTap: _openFavoritesAndHandleBack,
      ),
      body: SafeArea(
        child: normalizedRole == 'dealer'
            ? Column(
                children: [
                  /// 🔹 Top Section (Tabs + Actions)
                  Row(
                    children: [
                      SizedBox(width: 15),

                      /// ☰ Drawer Icon
                      Builder(
                        builder: (context) {
                          return GestureDetector(
                            child: Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: Color(0xffF47B39),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.menu,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            onTap: () {
                              Scaffold.of(context).openDrawer();
                            },
                          );
                        },
                      ),
                      SizedBox(width: 5),
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
                            labelStyle: TextStyle(
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
                      SizedBox(width: 15),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: dealerTopHorizontalPadding,
                      vertical: 12,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: contentMaxWidth),
                        child: Column(
                          children: [
                            /// 🔍 Search Bar + Filter Button (Side by Side)
                            Row(
                              children: [
                                /// Search Bar (Takes most space)
                                AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: Expanded(
                                    child: Container(
                                      height: dealerSearchHeight,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: Colors.blue.shade200,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: _searchController,
                                              focusNode: _searchFocus,
                                              textInputAction:
                                                  TextInputAction.done,
                                              onChanged: (_) => setState(() {}),
                                              onSubmitted: (_) => FocusScope.of(
                                                context,
                                              ).unfocus(),
                                              decoration: InputDecoration(
                                                hintText: _selectedIndex == 0
                                                    ? 'Search cars...'
                                                    : 'Search inventory...',
                                                border: InputBorder.none,
                                                hintStyle: TextStyle(
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
                                              if (_searchController
                                                  .text
                                                  .isNotEmpty) {
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

                                const SizedBox(width: 10),

                                /// Filter Button
                                if (_selectedIndex == 0)
                                  AnimatedSwitcher(
                                    duration: Duration(milliseconds: 300),
                                    transitionBuilder: (child, animation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: SizeTransition(
                                          sizeFactor: animation,
                                          axis: Axis.horizontal,
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: _searchController.text.isEmpty
                                        ? Row(
                                            children: [
                                              _buildActionButton(
                                                icon: Icons.filter_list_alt,
                                                size: dealerSearchHeight,
                                                iconSize: dealerActionIconSize,
                                                onTap: () {
                                                  _clearSearchBar();
                                                  Navigator.pushNamed(
                                                    context,
                                                    filteringScreen,
                                                    arguments:
                                                        roleForNavigation,
                                                  );
                                                },
                                              ),

                                              // /// Favorite Button (only visible in My Inventory)
                                              // if (_selectedIndex == 1) ...[
                                              //   const SizedBox(width: 10),
                                              //   _buildActionButton(
                                              //     icon: Icons.bookmark,
                                              //     size: dealerSearchHeight,
                                              //     iconSize: dealerActionIconSize,
                                              //     onTap:
                                              //         _openFavoritesAndHandleBack,
                                              //   ),
                                              // ],
                                            ],
                                          )
                                        : SizedBox.shrink(
                                            key: ValueKey("empty"),
                                          ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 5),

                  /// 🔹 Content Area
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: contentMaxWidth),
                        child: _searchController.text.isNotEmpty
                            ? _buildSearchResults()
                            : TabBarView(
                                controller: _tabController,
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  Listofcars(role: roleForNavigation),
                                  Myinvetory(role: roleForNavigation),
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
                            /// ☰ Menu
                            Builder(
                              builder: (context) {
                                return GestureDetector(
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Color(0xffF47B39),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.menu,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                  onTap: () {
                                    Scaffold.of(context).openDrawer();
                                  },
                                );
                              },
                            ),

                            SizedBox(width: 10),

                            /// 🔍 Search Field (auto expand)
                            AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: Expanded(
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
                                          focusNode: _searchFocus,
                                          onChanged: (_) => setState(() {}),
                                          decoration: InputDecoration(
                                            hintText: 'Search cars...',
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          if (_searchController
                                              .text
                                              .isNotEmpty) {
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

                            /// 🔥 ONLY SHOW WHEN SEARCH EMPTY
                            AnimatedSwitcher(
                              duration: Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SizeTransition(
                                    sizeFactor: animation,
                                    axis: Axis.horizontal,
                                    child: child,
                                  ),
                                );
                              },
                              child: _searchController.text.isEmpty
                                  ? Row(
                                      key: ValueKey("buttons"),
                                      children: [
                                        SizedBox(width: agentControlsGap),

                                        _buildActionButton(
                                          icon: Icons.filter_list_alt,
                                          size: agentButtonSize,
                                          iconSize: agentActionIconSize,
                                          onTap: () {
                                            _clearSearchBar();
                                            Navigator.pushNamed(
                                              context,
                                              filteringScreen,
                                              arguments: roleForNavigation,
                                            );
                                          },
                                        ),
                                      ],
                                    )
                                  : SizedBox.shrink(key: ValueKey("empty")),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: agentControlsGap),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: contentMaxWidth),
                        child: _searchController.text.isNotEmpty
                            ? _buildSearchResults()
                            : Listofcars(role: roleForNavigation),
                      ),
                    ),
                  ),
                ],
              ),
      ),

      // floatingActionButton only for dealers on My Inventory tab
      floatingActionButton: _selectedIndex == 1 && normalizedRole == 'dealer'
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  newCarEntryRoute,
                  arguments: roleForNavigation,
                );
              },
              backgroundColor: const Color(0xffF47B39),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildSearchResults() {
    if (_tabController.index == 1) {
      return _buildMyInventorySearchResults();
    }
    return _buildListOfCarsSearchResults();
  }

  Widget _buildListOfCarsSearchResults() {
    final padding = ResponsiveHelper.getResponsivePadding(context);

    return Consumer<SearchViewModel>(
      builder: (context, searchVM, child) {
        if (searchVM.isLoading) {
          return ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) => const CarCardShimmer(),
          );
        }

        if (searchVM.error != null) {
          return _buildSearchError(searchVM.error);
        }

        if (searchVM.cars.isEmpty) {
          return _buildEmptySearchState();
        }

        return ListView.builder(
          key: const PageStorageKey('list_of_cars_search'),
          physics: const BouncingScrollPhysics(),
          padding: padding,
          itemCount: searchVM.cars.length,
          itemBuilder: (context, index) {
            final car = searchVM.cars[index];

            return CarCard(
              key: ValueKey(car.id),
              car: Car(
                id: car.id,
                title:
                    "${car.brand.name} ${car.models.name} ${car.variant.name}",
                image: car.images.isNotEmpty ? car.images.first.imageUrl : '',
                fuel: car.fuelType.name,
                year: car.manufacturingYear,
                kms: car.kmRange,
                owner: car.ownerType.name,
                reg: car.rto.code,
                dealer: car.dealer.dealershipName,
                city: car.dealer.city,
                state: car.dealer.state,
                carPostDate: car.dealer.postedDate,
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
              onPressed: () async {
                await _handleSearchFavoriteTap(car);
              },
              icon: car.isFavorite
                  ? const Icon(Icons.bookmark, color: Color(0xffF47B39))
                  : Icon(
                      Icons.bookmark_border_outlined,
                      color: Colors.grey[800],
                    ),
            );
          },
        );
      },
    );
  }

  Widget _buildMyInventorySearchResults() {
    final padding = ResponsiveHelper.getResponsivePadding(context);

    return Consumer<MyInventrySearchViewModel>(
      builder: (context, searchVM, child) {
        if (searchVM.isLoading) {
          return ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) => const CarCardShimmer(),
          );
        }

        if (searchVM.error != null) {
          return _buildSearchError(searchVM.error);
        }

        if (searchVM.cars.isEmpty) {
          return _buildEmptySearchState();
        }

        return ListView.builder(
          key: const PageStorageKey('my_inventory_search'),
          physics: const BouncingScrollPhysics(),
          padding: padding,
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
                carPostDate: car.dealer.carPostDate,
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
          style: TextStyle(
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
            style: TextStyle(
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

// Reusable Done Button for Keyboard
class DoneButton extends StatelessWidget {
  final VoidCallback onTap;
  const DoneButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.blue,
        ),
      ),
      child: const Text("Done"),
    );
  }
}

// Reusable custom Login button
Widget _buildActionButton({
  required IconData icon,
  required VoidCallback onTap,
  double size = 56,
  double iconSize = 28,
}) {
  return SizedBox(
    height: size,
    width: size,
    child: TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        backgroundColor: const Color(0xffF47B39),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onTap,
      child: Icon(icon, color: Colors.white, size: iconSize),
    ),
  );
}

// Reusable custom Login button
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
            style: TextStyle(
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
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    ),
  );
}
