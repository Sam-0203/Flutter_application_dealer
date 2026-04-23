import 'package:dealershub_/src/utils/responsive/responsive_helper.dart';
import 'package:dealershub_/src/utils/helper/secure_storage.dart';
import 'package:dealershub_/src/utils/widgets/car_card.dart';
import 'package:dealershub_/src/utils/widgets/car_shimmer.dart';
import 'package:dealershub_/src/viewmodels/add_car_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/route/route.dart';

class Listofcars extends StatefulWidget {
  final String? role;

  const Listofcars({super.key, this.role});

  @override
  State<Listofcars> createState() => _ListofcarsState();
}

class _ListofcarsState extends State<Listofcars> {
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

  int _getGridColumns(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 1;
      case DeviceType.tablet:
        return 2;
      case DeviceType.desktop:
        return 3;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListOfCarsViewModel>().fetchingListOfCars();
    });
  }

  Future<void> _refreshCars() async {
    await context.read<ListOfCarsViewModel>().fetchingListOfCars();
  }

  Widget _buildCenteredPullToRefreshMessage(
    String message, {
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    return RefreshIndicator(
      onRefresh: _refreshCars,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: fontWeight,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _normalizeRole(String? rawRole) {
    final role = (rawRole ?? '').trim().toLowerCase();
    if (role.contains('dealer')) return 'dealer';
    if (role.contains('agent')) return 'agent';
    return '';
  }

  Future<String> _resolveRole() async {
    final fromWidget = _normalizeRole(widget.role);
    if (fromWidget.isNotEmpty) return fromWidget;

    final storedRole = await SecureStorage.getRole();
    final fromStorage = _normalizeRole(storedRole);
    if (fromStorage.isNotEmpty) return fromStorage;

    return '';
  }

  Future<bool> _addToFavoritesByRole(int carId) async {
    final resolvedRole = await _resolveRole();
    if (!mounted) return false;

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
    final dealerSuccess = await dealerVM.addToFavorite(carId);
    if (dealerSuccess) return true;

    final agentVM = context.read<AddFavCarsAgentsViewModel>();
    return agentVM.addToFavorite(carId);
  }

  Future<void> _handleFavoriteTap(dynamic car) async {
    if (car.isFavorite == true) {
      return;
    }

    final addedSuccessfully = await _addToFavoritesByRole(car.id);
    if (!context.mounted) return;

    if (addedSuccessfully) {
      debugPrint('Fav Car id pressed : ${car.id}');
      setState(() {
        car.isFavorite = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ListOfCarsViewModel>();
    final deviceType = ResponsiveHelper.getDeviceType(context);
    final isMobile = deviceType == DeviceType.mobile;
    final gridColumns = _getGridColumns(deviceType);
    final padding = ResponsiveHelper.getResponsivePadding(context);
    final childAspectRatio = _getGridAspectRatio(deviceType);

    if (vm.isLoading) {
      return ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) => const CarCardShimmer(),
      );
    }

    final cars = vm.listOfCars;

    if (vm.error != null) {
      return _buildCenteredPullToRefreshMessage(
        'Failed to load cars. Please check your internet connection and try again...',
      );
    }

    if (isMobile) {
      return RefreshIndicator(
        onRefresh: _refreshCars,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: padding,
          itemCount: cars.length,
          separatorBuilder: (_, __) => SizedBox(height: padding.vertical / 2),
          itemBuilder: (context, index) {
            final car = cars[index];
            return CarCard(
              key: ValueKey(car.id),
              car: Car(
                id: car.id,
                title:
                    "${car.brand.name} ${car.model.name} ${car.variant.name}",
                image: car.images.isNotEmpty ? car.images.first.imageUrl : "",
                fuel: car.fuelType.name,
                year: car.manufacturingYear.toString(),
                kms: car.kmRange,
                owner: car.ownerType.name,
                reg: car.rto.code,
                dealer: car.dealer.dealershipName,
                city: car.dealer.city,
                state: car.dealer.state,
                carPostDate: car.dealer.carPostDate,
              ),
              onTap: () async {
                final result = await Navigator.pushNamed(
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

                if (result == true) {
                  context.read<ListOfCarsViewModel>().fetchingListOfCars();
                }
              },
              onPressed: () async {
                await _handleFavoriteTap(car);
              },
              icon: Icon(
                car.isFavorite
                    ? Icons.bookmark
                    : Icons.bookmark_border_outlined,
                color: car.isFavorite
                    ? const Color(0xffF47B39)
                    : Colors.grey[800],
              ),
            );
          },
        ),
      );
    }

    // Use GridView for responsive layout
    return RefreshIndicator(
      onRefresh: _refreshCars,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: padding,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridColumns,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: padding.horizontal / 2,
          mainAxisSpacing: padding.vertical / 2,
        ),
        itemCount: cars.length,
        itemBuilder: (context, index) {
          final car = cars[index];

          final isSingleLayout = car.id % 2 == 0;

          if (isSingleLayout || car.images.length < 2) {
            // 🔵 SINGLE IMAGE CARD
            return CarCard(
              key: ValueKey(car.id),
              car: Car(
                id: car.id,
                title:
                    "${car.brand.name} ${car.model.name} ${car.variant.name}",
                image: car.images.isNotEmpty ? car.images.first.imageUrl : "",
                fuel: car.fuelType.name,
                year: car.manufacturingYear.toString(),
                kms: car.kmRange,
                owner: car.ownerType.name,
                reg: car.rto.code,
                dealer: car.dealer.dealershipName,
                city: car.dealer.city,
                state: car.dealer.state,
                carPostDate: car.dealer.carPostDate,
              ),
              onTap: () async {
                final result = await Navigator.pushNamed(
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

                if (result == true) {
                  context.read<ListOfCarsViewModel>().fetchingListOfCars();
                }
              },
              onPressed: () async {
                await _handleFavoriteTap(car);
              },
              icon: Icon(
                car.isFavorite
                    ? Icons.bookmark
                    : Icons.bookmark_border_outlined,
                color: car.isFavorite
                    ? const Color(0xffF47B39)
                    : Colors.grey[800],
              ),
            );
          } else {
            // 🔵 TWO IMAGE CARD
            return CarsCard(
              cars: Cars(
                title:
                    "${car.brand.name} ${car.model.name} ${car.variant.name}",
                images: car.images.map((e) => e.imageUrl).take(2).toList(),
                fuel: car.fuelType.name,
                year: car.manufacturingYear.toString(),
                kms: car.kmRange,
                owner: car.ownerType.name,
                reg: car.rto.code,
                dealer: car.dealer.dealershipName,
                city: car.dealer.city,
                state: car.dealer.state,
                carPostDate: car.dealer.carPostDate,
              ),
              onTap: () async {
                final result = await Navigator.pushNamed(
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

                if (result == true) {
                  context.read<ListOfCarsViewModel>().fetchingListOfCars();
                }
              },
              onPressed: () async {
                await _handleFavoriteTap(car);
              },
              icon: Icon(
                car.isFavorite
                    ? Icons.bookmark
                    : Icons.bookmark_border_outlined,
                color: car.isFavorite
                    ? const Color(0xffF47B39)
                    : Colors.grey[800],
              ),
            );
          }
        },
      ),
    );
  }
}
