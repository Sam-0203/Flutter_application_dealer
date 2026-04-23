import 'package:dealershub_/src/utils/responsive/responsive_helper.dart';
import 'package:dealershub_/src/utils/route/route.dart';
import 'package:dealershub_/src/utils/widgets/car_shimmer.dart';
import 'package:dealershub_/src/viewmodels/add_car_viewmodel.dart';
import 'package:dealershub_/src/utils/widgets/car_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyFavoriteCars extends StatefulWidget {
  final String? role;
  const MyFavoriteCars({super.key, this.role});

  @override
  State<MyFavoriteCars> createState() => _MyFavoriteCarsState();
}

class _MyFavoriteCarsState extends State<MyFavoriteCars> {
  String _resolvedRole = '';
  bool _isInitializing = true;

  Future<void> _loadFavorites() async {
    final role = (widget.role ?? '').toLowerCase();

    setState(() {
      _resolvedRole = role;
      _isInitializing = false;
    });

    if (role.contains('dealer')) {
      await context.read<DealerFavoriteCarsViewModel>().fetchFavoriteCars();
    } else {
      await context.read<AgentFavoriteCarsViewModel>().fetchFavoriteCars();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return _FavoriteCarsList(role: _resolvedRole);
  }
}

class _FavoriteCarsList extends StatelessWidget {
  final String role;
  const _FavoriteCarsList({required this.role});

  String _friendlyErrorMessage(String rawMessage) {
    final cleaned = rawMessage
        .replaceFirst(RegExp(r'^Exception:\s*'), '')
        .trim();

    if (cleaned.isEmpty) {
      return 'Unable to load watchlist. Please try again.';
    }

    if (cleaned.toLowerCase().contains('failed to load favorite cars')) {
      return 'Unable to load watchlist. Please try again.';
    }

    return cleaned;
  }

  Future<void> _refreshListAndPop(BuildContext context) async {
    await context.read<ListOfCarsViewModel>().fetchingListOfCars();
    if (!context.mounted) return;
    Navigator.pop(context, {'clearSearch': true});
  }

  Future<bool> _refreshListOnSystemBack(BuildContext context) async {
    await context.read<ListOfCarsViewModel>().fetchingListOfCars();
    if (!context.mounted) return false;
    Navigator.pop(context, {'clearSearch': true});
    return false;
  }

  double _getGridAspectRatio(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 0.95;
      case DeviceType.tablet:
        return 0.95;
      case DeviceType.desktop:
        return 0.95;
    }
  }

  Widget _buildErrorState(
    BuildContext context, {
    required String message,
    required Future<void> Function() onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveHelper.getDeviceType(context);
    final isMobile = deviceType == DeviceType.mobile;
    // final gridColumns = deviceType == DeviceType.tablet ? 3 : 2;
    final padding = ResponsiveHelper.getResponsivePadding(context);
    final childAspectRatio = _getGridAspectRatio(deviceType);

    int gridColumns;

    switch (deviceType) {
      case DeviceType.mobile:
        gridColumns = 1;
        break;
      case DeviceType.tablet:
        gridColumns = 2;
        break;
      case DeviceType.desktop:
        gridColumns = 3;
        break;
    }

    if (role == 'dealer') {
      return WillPopScope(
        onWillPop: () => _refreshListOnSystemBack(context),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: GestureDetector(
              onTap: () => _refreshListAndPop(context),
              child: Row(
                children: [
                  Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
                  Text(
                    'Your Watchlist',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Consumer<DealerFavoriteCarsViewModel>(
                    builder: (context, favCarVm, _) => Text(
                      '${favCarVm.favoriteCars.length} cars',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Consumer<DealerFavoriteCarsViewModel>(
            builder: (context, favCarVm, _) {
              if (favCarVm.isLoading) {
                return ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) => const CarCardShimmer(),
                );
              }

              if ((favCarVm.error ?? '').isNotEmpty) {
                return _buildErrorState(
                  context,
                  message: _friendlyErrorMessage(favCarVm.error!),
                  onRetry: favCarVm.fetchFavoriteCars,
                );
              }

              if (favCarVm.favoriteCars.isEmpty) {
                return Center(
                  child: Text(
                    'No favorite cars yet.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                );
              }

              if (isMobile) {
                return ListView.separated(
                  padding: padding,
                  itemCount: favCarVm.favoriteCars.length,
                  separatorBuilder: (_, __) =>
                      SizedBox(height: padding.vertical / 2),
                  itemBuilder: (context, index) {
                    final car = favCarVm.favoriteCars[index];

                    return CarCard(
                      key: ValueKey(car.id),
                      car: Car(
                        id: car.id,
                        title:
                            "${car.brand.name} ${car.model.name} ${car.variant.name}",
                        image: car.images.isNotEmpty
                            ? car.images.first.imageUrl
                            : '',
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
                            'role': role,
                            'headerTitle': false,
                            'actionIcons': 'listOfCars',
                            'carData': {},
                            'previewData': {},
                          },
                        );
                      },
                      onPressed: () {
                        _removeFavoriteCar(context, car.id, role);
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                    );
                  },
                );
              }

              return GridView.builder(
                padding: padding,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridColumns, // 1 for mobile, 2 for tablet
                  childAspectRatio: childAspectRatio,
                  crossAxisSpacing: padding.horizontal / 2,
                  mainAxisSpacing: padding.vertical / 2,
                ),
                itemCount: favCarVm.favoriteCars.length,
                itemBuilder: (context, index) {
                  final car = favCarVm.favoriteCars[index];

                  return CarCard(
                    key: ValueKey(car.id),
                    car: Car(
                      id: car.id,
                      title:
                          "${car.brand.name} ${car.model.name} ${car.variant.name}",
                      image: car.images.isNotEmpty
                          ? car.images.first.imageUrl
                          : '',
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
                          'role': role,
                          'headerTitle': false,
                          'actionIcons': 'listOfCars',
                          'carData': {},
                          'previewData': {},
                        },
                      );
                    },
                    onPressed: () {
                      _removeFavoriteCar(context, car.id, role);
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                  );
                },
              );
            },
          ),
        ),
      );
    } else {
      return WillPopScope(
        onWillPop: () => _refreshListOnSystemBack(context),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: GestureDetector(
              onTap: () => _refreshListAndPop(context),
              child: Row(
                children: [
                  Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),

                  Text(
                    'Your Watchlist',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Consumer<AgentFavoriteCarsViewModel>(
                    builder: (context, favCarVm, _) => Text(
                      '${favCarVm.favoriteCars.length} cars',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Consumer<AgentFavoriteCarsViewModel>(
            builder: (context, favCarVm, _) {
              if (favCarVm.isLoading) {
                return ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) => const CarCardShimmer(),
                );
              }

              if ((favCarVm.error ?? '').isNotEmpty) {
                return _buildErrorState(
                  context,
                  message: _friendlyErrorMessage(favCarVm.error!),
                  onRetry: favCarVm.fetchFavoriteCars,
                );
              }

              if (favCarVm.favoriteCars.isEmpty) {
                return Center(
                  child: Text(
                    'No favorite cars yet.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                );
              }

              if (isMobile) {
                return ListView.separated(
                  padding: padding,
                  itemCount: favCarVm.favoriteCars.length,
                  separatorBuilder: (_, __) =>
                      SizedBox(height: padding.vertical / 2),
                  itemBuilder: (context, index) {
                    final car = favCarVm.favoriteCars[index];

                    return CarCard(
                      key: ValueKey(car.id),
                      car: Car(
                        id: car.id,
                        title:
                            "${car.brand.name} ${car.model.name} ${car.variant.name}",
                        image: car.images.isNotEmpty
                            ? car.images.first.imageUrl
                            : '',
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
                            'role': role,
                            'headerTitle': false,
                            'actionIcons': 'listOfCars',
                            'carData': {},
                            'previewData': {},
                          },
                        );
                      },
                      onPressed: () {
                        _removeFavoriteCar(context, car.id, role);
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                    );
                  },
                );
              }

              return GridView.builder(
                padding: padding,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridColumns, // 1 for mobile, 2 for tablet
                  childAspectRatio: childAspectRatio,
                  crossAxisSpacing: padding.horizontal / 2,
                  mainAxisSpacing: padding.vertical / 2,
                ),
                itemCount: favCarVm.favoriteCars.length,
                itemBuilder: (context, index) {
                  final car = favCarVm.favoriteCars[index];

                  return CarCard(
                    key: ValueKey(car.id),
                    car: Car(
                      id: car.id,
                      title:
                          "${car.brand.name} ${car.model.name} ${car.variant.name}",
                      image: car.images.isNotEmpty
                          ? car.images.first.imageUrl
                          : '',
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
                          'role': role,
                          'headerTitle': false,
                          'actionIcons': 'listOfCars',
                          'carData': {},
                          'previewData': {},
                        },
                      );
                    },
                    onPressed: () {
                      _removeFavoriteCar(context, car.id, role);
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                  );
                },
              );
            },
          ),
        ),
      );
    }
  }
}

Future<void> _removeFavoriteCar(
  BuildContext parentContext,
  int carId,
  String role,
) async {
  final normalizedRole = role.trim().toLowerCase();
  final isDealer = normalizedRole.contains('dealer');

  if (isDealer) {
    final removeVm = parentContext.read<RemoveFromFavoriteViewModel>();
    final success = await removeVm.removeCar(carId);
    if (success) {
      if (!parentContext.mounted) return;
      await parentContext
          .read<DealerFavoriteCarsViewModel>()
          .fetchFavoriteCars();
    } else if (parentContext.mounted) {
      ScaffoldMessenger.of(parentContext).showSnackBar(
        const SnackBar(
          content: Text('Unable to remove favorite. Please try again.'),
          backgroundColor: Color(0xffF47B39),
        ),
      );
    }
  } else {
    final removeVm = parentContext.read<RemoveFavCarsAgentsViewModel>();
    final success = await removeVm.removeCar(carId);
    if (success) {
      if (!parentContext.mounted) return;
      await parentContext
          .read<AgentFavoriteCarsViewModel>()
          .fetchFavoriteCars();
    } else if (parentContext.mounted) {
      ScaffoldMessenger.of(parentContext).showSnackBar(
        const SnackBar(
          content: Text('Unable to remove favorite. Please try again.'),
          backgroundColor: Color(0xffF47B39),
        ),
      );
    }
  }
}
