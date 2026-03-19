import 'package:dealershub_/src/utils/responsive/responsive_helper.dart';
import 'package:dealershub_/src/viewmodels/add_car_view_model.dart';
import 'package:dealershub_/src/utils/widgets/car_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MyFavoriteCars extends StatefulWidget {
  final String? role;
  const MyFavoriteCars({super.key, this.role});

  @override
  State<MyFavoriteCars> createState() => _MyFavoriteCarsState();
}

class _MyFavoriteCarsState extends State<MyFavoriteCars> {
  late ChangeNotifier _viewModel;

  @override
  void initState() {
    super.initState();
    print('MyFavoriteCars initState - Role: ${widget.role}');
    if (widget.role == 'dealer') {
      _viewModel = DealerFavoriteCarsViewModel();
      Future.delayed(Duration.zero, () {
        (_viewModel as DealerFavoriteCarsViewModel).fetchFavoriteCars();
      });
    } else {
      _viewModel = AgentFavoriteCarsViewModel();
      Future.delayed(Duration.zero, () {
        (_viewModel as AgentFavoriteCarsViewModel).fetchFavoriteCars();
      });
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.role == 'dealer') {
      return ChangeNotifierProvider<DealerFavoriteCarsViewModel>.value(
        value: _viewModel as DealerFavoriteCarsViewModel,
        child: _FavoriteCarsList(role: widget.role),
      );
    } else {
      return ChangeNotifierProvider<AgentFavoriteCarsViewModel>.value(
        value: _viewModel as AgentFavoriteCarsViewModel,
        child: _FavoriteCarsList(role: widget.role),
      );
    }
  }
}

class _FavoriteCarsList extends StatelessWidget {
  final String? role;
  const _FavoriteCarsList({Key? key, this.role}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    print('_FavoriteCarsList build - Role: $role');
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
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black,
                      size: 20,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Your Favorite Cars',
                      style: GoogleFonts.mulish(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Consumer<DealerFavoriteCarsViewModel>(
                builder: (context, favCarVm, _) => Text(
                  '${favCarVm.favoriteCars.length} cars',
                  style: GoogleFonts.mulish(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Consumer<DealerFavoriteCarsViewModel>(
          builder: (context, favCarVm, _) {
            if (favCarVm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (favCarVm.favoriteCars.isEmpty) {
              return Center(
                child: Text(
                  'No favorite cars yet.',
                  style: GoogleFonts.mulish(
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
                    ),
                    onPressed: () {
                      _openDialogBox(context, car.id, role);
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
                  ),

                  onPressed: () {
                    _openDialogBox(context, car.id, role);
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                );
              },
            );
          },
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black,
                      size: 20,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Your Favorite Cars',
                      style: GoogleFonts.mulish(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),

              Consumer<AgentFavoriteCarsViewModel>(
                builder: (context, favCarVm, _) => Text(
                  '${favCarVm.favoriteCars.length} cars',
                  style: GoogleFonts.mulish(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Consumer<AgentFavoriteCarsViewModel>(
          builder: (context, favCarVm, _) {
            if (favCarVm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (favCarVm.favoriteCars.isEmpty) {
              return Center(
                child: Text(
                  'No favorite cars yet.',
                  style: GoogleFonts.mulish(
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
                    ),
                    onPressed: () {
                      _openDialogBox(context, car.id, role);
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
                  ),
                  onPressed: () {
                    _openDialogBox(context, car.id, role);
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                );
              },
            );
          },
        ),
      );
    }
  }
}

void _openDialogBox(BuildContext parentContext, int carId, String? role) {
  final navigator = Navigator.of(parentContext);

  showDialog(
    context: parentContext,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        'Delete from Favorites',
        style: GoogleFonts.mulish(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      content: Text(
        'Are you sure you want to delete this car from your favorites?',
        style: GoogleFonts.mulish(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () => Navigator.pop(dialogContext),
          child: Text(
            'Cancel',
            style: GoogleFonts.mulish(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(width: 20),
        GestureDetector(
          onTap: () async {
            if (role == 'dealer') {
              final removeVm = parentContext
                  .read<RemoveFromFavoriteViewModel>();
              final favVm = parentContext.read<DealerFavoriteCarsViewModel>();

              final success = await removeVm.removeCar(carId);
              if (success) {
                navigator.pop();
                await favVm.fetchFavoriteCars();
              }
            } else {
              final removeVm = parentContext
                  .read<RemoveFavCarsAgentsViewModel>();
              final favVm = parentContext.read<AgentFavoriteCarsViewModel>();

              final success = await removeVm.removeCar(carId);
              if (success) {
                navigator.pop();
                await favVm.fetchFavoriteCars();
              }
            }
          },
          child: Text(
            'Delete',
            style: GoogleFonts.mulish(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.red,
            ),
          ),
        ),
      ],
    ),
  );
}
