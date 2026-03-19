import 'package:dealershub_/src/utils/responsive/responsive_helper.dart';
import 'package:dealershub_/src/utils/widgets/car_card.dart';
import 'package:dealershub_/src/viewmodels/add_car_view_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ListOfCarsViewModel>();
    final deviceType = ResponsiveHelper.getDeviceType(context);
    final isMobile = deviceType == DeviceType.mobile;
    final gridColumns = _getGridColumns(deviceType);
    final padding = ResponsiveHelper.getResponsivePadding(context);
    final childAspectRatio = _getGridAspectRatio(deviceType);

    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final cars = vm.listOfCars;

    if (vm.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Failed to load cars. Please check your internet connection and try again.',
            textAlign: TextAlign.center,
            style: GoogleFonts.mulish(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ),
      );
    }

    if (cars.isEmpty) {
      return Center(
        child: Text(
          'No cars found',
          style: GoogleFonts.mulish(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
      );
    }

    if (isMobile) {
      return ListView.separated(
        padding: padding,
        itemCount: cars.length,
        separatorBuilder: (_, __) => SizedBox(height: padding.vertical / 2),
        itemBuilder: (context, index) {
          final car = cars[index];
          return CarCard(
            key: ValueKey(car.id),
            car: Car(
              id: car.id,
              title: "${car.brand.name} ${car.variant.name}",
              image: car.images.isNotEmpty ? car.images.first.imageUrl : "",
              fuel: car.fuelType.name,
              year: car.manufacturingYear.toString(),
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
            onPressed: () async {
              if (car.isFavorite == false) {
                bool addedSuccessfully = false;
                if (widget.role == 'dealer') {
                  final favVM = context.read<AddToFavoriteViewModel>();
                  addedSuccessfully = await favVM.addToFavorite(car.id);
                } else {
                  final favVM = context.read<AddFavCarsAgentsViewModel>();
                  addedSuccessfully = await favVM.addToFavorite(car.id);
                }
                if (!context.mounted) return;
                if (addedSuccessfully) {
                  debugPrint('Fav Car id pressed : ${car.id}');
                  setState(() {
                    car.isFavorite = true;
                  });
                  _showAddedToFavoritesDialog(context);
                }
              } else {
                _showAlreadyFavoritedDialog(context);
              }
            },
            icon: Icon(
              car.isFavorite ? Icons.favorite : Icons.favorite_border_outlined,
              color: car.isFavorite
                  ? const Color(0xffF47B39)
                  : Colors.grey[800],
            ),
          );
        },
      );
    }

    // Use GridView for responsive layout
    return GridView.builder(
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
              title: "${car.brand.name} ${car.variant.name}",
              image: car.images.isNotEmpty ? car.images.first.imageUrl : "",
              fuel: car.fuelType.name,
              year: car.manufacturingYear.toString(),
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
            onPressed: () async {
              if (car.isFavorite == false) {
                bool addedSuccessfully = false;
                if (widget.role == 'dealer') {
                  final favVM = context.read<AddToFavoriteViewModel>();
                  addedSuccessfully = await favVM.addToFavorite(car.id);
                } else {
                  final favVM = context.read<AddFavCarsAgentsViewModel>();
                  addedSuccessfully = await favVM.addToFavorite(car.id);
                }
                if (!context.mounted) return;
                if (addedSuccessfully) {
                  debugPrint('Fav Car id pressed : ${car.id}');
                  setState(() {
                    car.isFavorite = true;
                  });
                  _showAddedToFavoritesDialog(context);
                }
              } else {
                // Show dialog if already added to favorites
                _showAlreadyFavoritedDialog(context);
              }
            },
            icon: Icon(
              car.isFavorite ? Icons.favorite : Icons.favorite_border_outlined,
              color: car.isFavorite
                  ? const Color(0xffF47B39)
                  : Colors.grey[800],
            ),
          );
        } else {
          // 🔵 TWO IMAGE CARD
          return CarsCard(
            cars: Cars(
              title: "${car.brand.name} ${car.variant.name}",
              images: car.images.map((e) => e.imageUrl).take(2).toList(),
              fuel: car.fuelType.name,
              year: car.manufacturingYear.toString(),
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
            onPressed: () async {
              if (car.isFavorite == false) {
                bool addedSuccessfully = false;
                if (widget.role == 'dealer') {
                  final favVM = context.read<AddToFavoriteViewModel>();
                  addedSuccessfully = await favVM.addToFavorite(car.id);
                } else {
                  final favVM = context.read<AddFavCarsAgentsViewModel>();
                  addedSuccessfully = await favVM.addToFavorite(car.id);
                }
                if (!context.mounted) return;
                if (addedSuccessfully) {
                  debugPrint('Fav Car id pressed : ${car.id}');
                  setState(() {
                    car.isFavorite = true;
                  });
                  _showAddedToFavoritesDialog(context);
                }
              } else {
                // Show dialog if already added to favorites
                _showAlreadyFavoritedDialog(context);
              }
            },
            icon: Icon(
              car.isFavorite ? Icons.favorite : Icons.favorite_border_outlined,
              color: car.isFavorite
                  ? const Color(0xffF47B39)
                  : Colors.grey[800],
            ),
          );
        }
      },
    );
  }

  void _showAddedToFavoritesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Added to Favorites',
          style: GoogleFonts.mulish(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        content: Text(
          'Car has been added to your favorites successfully.',
          style: GoogleFonts.mulish(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.mulish(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xffF47B39),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAlreadyFavoritedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Already Added',
          style: GoogleFonts.mulish(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        content: Text(
          'This car is already added to your favorites.',
          style: GoogleFonts.mulish(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.mulish(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xffF47B39),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
