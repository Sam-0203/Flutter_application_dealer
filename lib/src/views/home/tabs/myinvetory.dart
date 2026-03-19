import 'package:dealershub_/src/utils/responsive/responsive_helper.dart';
import 'package:dealershub_/src/viewmodels/add_car_view_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../utils/route/route.dart';
import '../../../utils/widgets/car_card.dart';

class Myinvetory extends StatefulWidget {
  final String? role;

  const Myinvetory({super.key, this.role});

  @override
  State<Myinvetory> createState() => _MyinvetoryState();
}

class _MyinvetoryState extends State<Myinvetory> {
  double _getGridAspectRatio(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 0.74;
      case DeviceType.tablet:
        return 0.86;
      case DeviceType.desktop:
        return 0.92;
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CarDetailsViewModel>().fetchDealerCars();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CarDetailsViewModel>(
      builder: (context, vm, _) {
        /// Loading
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Error State
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

        /// Empty State
        if (!vm.hasCars) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            width: double.infinity,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    newCarEntryRoute,
                    arguments: widget.role,
                  );
                },
                child: Image.asset(
                  'assets/placeholders/Add_cars.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        }

        /// Grid View
        final padding = ResponsiveHelper.getResponsivePadding(context);

        final deviceType = ResponsiveHelper.getDeviceType(context);
        final gridColumns = deviceType == DeviceType.tablet ? 3 : 2;
        final childAspectRatio = _getGridAspectRatio(deviceType);

        return Padding(
          padding: padding,
          child: GridView.builder(
            itemCount: vm.cars.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridColumns,
              crossAxisSpacing: padding.horizontal / 2,
              mainAxisSpacing: padding.vertical / 2,
              childAspectRatio: childAspectRatio,
            ),
            itemBuilder: (context, index) {
              final car = vm.cars[index];
              final imageUrl = car.images.isNotEmpty
                  ? car.images.first.imageUrl
                  : '';
              return SmallCarsCard(
                lessDetails: LessCarDetails(
                  title:
                      "${car.brand.name} ${car.model.name} ${car.variant.name}"
                          .trim(),
                  image: imageUrl,
                  fuel: car.fuelType.name,
                  year: car.manufacturingYear,
                  reg: car.rto.code,
                ),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    carDetailsReview,
                    arguments: {
                      'carId': car.id,
                      'role': widget.role,
                      'showAppBar': true,
                      'showBottomButtons': false,
                      'headerTitle': false,
                      'carData': {},
                      'previewData': {},
                      'actionIcons': '',
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
