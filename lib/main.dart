import 'dart:async';
import 'dart:io';

import 'package:dealershub_/src/utils/helper/install_checker.dart';
import 'package:dealershub_/src/utils/route/route.dart';
import 'package:dealershub_/src/utils/helper/secure_storage.dart';
import 'package:dealershub_/src/viewmodels/add_car_viewmodel.dart';
import 'package:dealershub_/src/viewmodels/user_viewmodel.dart';
import 'package:dealershub_/src/viewmodels/language_viewmodel.dart';
import 'package:dealershub_/src/viewmodels/state_cities_viemodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  // ✅ Detect reinstall & clear secure storage
  await InstallChecker.handleFirstInstall();

  final token = await SecureStorage.getToken();
  final role = await SecureStorage.getRole();
  debugPrint("my token : $token");

  final String initialRoute = (token != null && token.isNotEmpty)
      ? homeScreenRoute
      : OnBoardingscreen;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => LanguageViewModel()),
        ChangeNotifierProvider(create: (_) => StateViemodel()),
        ChangeNotifierProvider(create: (_) => CitiesViemodel()),
        ChangeNotifierProvider(create: (_) => DealerViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => LoginOtpViewModel()),
        ChangeNotifierProvider(create: (_) => CarCompaniesListView()),
        ChangeNotifierProvider(create: (_) => CarModelsListView()),
        ChangeNotifierProvider(create: (_) => CarFueltypeListView()),
        ChangeNotifierProvider(create: (_) => CarTransmissiotypeListView()),
        ChangeNotifierProvider(create: (_) => CarModelsVarietsListView()),
        ChangeNotifierProvider(create: (_) => CarColorListView()),
        ChangeNotifierProvider(create: (_) => CarRRTOsListView()),
        ChangeNotifierProvider(create: (_) => CarNumofOwner()),
        ChangeNotifierProvider(create: (_) => CarSafetyFeaturesViewModel()),
        ChangeNotifierProvider(create: (_) => CarcomfortFeaturesViewModel()),
        ChangeNotifierProvider(
          create: (_) => CarInfotainmentFeaturesViewModel(),
        ),
        ChangeNotifierProvider(create: (_) => CarInteriorFeaturesViewModel()),
        ChangeNotifierProvider(create: (_) => CarExteriorFeaturesViewModel()),
        ChangeNotifierProvider(create: (_) => PostCarViewModel()),
        ChangeNotifierProvider(create: (_) => CarDetailsViewModel()),
        ChangeNotifierProvider(create: (_) => SingleCarDetailsViewModel()),
        ChangeNotifierProvider(create: (_) => DeleteCarViewModel()),
        ChangeNotifierProvider(create: (_) => ListOfCarsViewModel()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
        ChangeNotifierProvider(create: (_) => AllCarModelsViewModel()),
        ChangeNotifierProvider(create: (_) => FilterCarViewModel()),
        ChangeNotifierProvider(create: (_) => MyInventrySearchViewModel()),
        ChangeNotifierProvider(create: (_) => CarUpdateViewModel()),
        ChangeNotifierProvider(create: (_) => CarImageUploadViewModel()),
        ChangeNotifierProvider(create: (_) => DeleteCarImageViewModel()),
        ChangeNotifierProvider(create: (_) => DealerFavoriteCarsViewModel()),
        ChangeNotifierProvider(create: (_) => AgentFavoriteCarsViewModel()),
        ChangeNotifierProvider(create: (_) => RemoveFavCarsAgentsViewModel()),
        ChangeNotifierProvider(create: (_) => AddFavCarsAgentsViewModel()),
        ChangeNotifierProvider(
          create: (_) => AddToFavoriteViewModel(),
        ), // Dealer add to fav
        ChangeNotifierProvider(
          create: (_) => RemoveFromFavoriteViewModel(),
        ), // Dealer remove from fav
        ChangeNotifierProvider(create: (_) => DealerProfileViewModel()),
        ChangeNotifierProvider(create: (_) => AgentProfileViewModel()),
        ChangeNotifierProvider(create: (_) => LogoutViewModel()),
      ],
      child: MainApp(
        initialRoute: initialRoute,
        role: role, // ✅ pass role
      ),
    ),
  );
}

/// ------------------------------------------------------------
/// ROOT WIDGET
/// ------------------------------------------------------------
class MainApp extends StatefulWidget {
  final String initialRoute;
  final String? role;

  const MainApp({super.key, required this.initialRoute, this.role});

  @override
  State<MainApp> createState() => _MainAppState();
}

// Global key for ScaffoldMessenger
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

// Global key for Navigator
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class _MainAppState extends State<MainApp> {
  void _dismissKeyboardOnPointerDown(PointerDownEvent event) {
    final currentFocus = FocusManager.instance.primaryFocus;
    if (currentFocus == null) return;

    final focusedContext = currentFocus.context;
    if (focusedContext != null) {
      final renderObject = focusedContext.findRenderObject();
      if (renderObject is RenderBox && renderObject.attached) {
        final focusedRect =
            renderObject.localToGlobal(Offset.zero) & renderObject.size;
        if (focusedRect.contains(event.position)) return;
      }
    }

    currentFocus.unfocus();
  }

  //Internet connection check
  bool isConnectedToInternet = false;
  InternetStatus? _previousInternetStatus;
  bool _isFirstStatusCheck = true;
  late StreamSubscription<InternetStatus> _internetConnectionStreamSubscription;

  @override
  void initState() {
    super.initState();

    _internetConnectionStreamSubscription = InternetConnection().onStatusChange
        .listen((event) {
          // Skip the first status check to avoid showing snackbar on app start
          if (_isFirstStatusCheck) {
            _isFirstStatusCheck = false;
            _previousInternetStatus = event;
            setState(() {
              isConnectedToInternet = event == InternetStatus.connected;
            });
            return;
          }

          switch (event) {
            case InternetStatus.connected:
              debugPrint("✅ Internet Connected");

              setState(() {
                isConnectedToInternet = true;
              });

              // ✅ Refresh data only when reconnecting
              if (_previousInternetStatus == InternetStatus.disconnected) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final context = scaffoldMessengerKey.currentContext;
                  if (context != null) {
                    context.read<ListOfCarsViewModel>().fetchingListOfCars();
                    context.read<MyInventrySearchViewModel>().search('');
                  }
                });
              }

              break;

            case InternetStatus.disconnected:
              debugPrint("❌ Internet Disconnected");

              setState(() {
                isConnectedToInternet = false;
              });

              // ❌ Show error snackbar only when disconnecting
              if (_previousInternetStatus == InternetStatus.connected) {
                scaffoldMessengerKey.currentState?.showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.white, size: 30),
                        SizedBox(width: 5),
                        Text(
                          "No Internet Connection",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }

              break;
          }

          // Update previous status
          _previousInternetStatus = event;
        });
  }

  @override
  void dispose() {
    _internetConnectionStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dealers Hub',
      scaffoldMessengerKey: scaffoldMessengerKey,
      navigatorKey: navigatorKey,
      builder: (context, child) {
        return PopScope(
          canPop: false,
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: _dismissKeyboardOnPointerDown,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      theme: ThemeData(
        fontFamily: GoogleFonts.mulish().fontFamily,
        textTheme: GoogleFonts.mulishTextTheme(),
        primaryTextTheme: GoogleFonts.mulishTextTheme(),
        scaffoldBackgroundColor: const Color.fromRGBO(239, 239, 239, 1),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            // Disable iOS back-swipe gesture by using a non-Cupertino transition.
            TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
      ),
      onGenerateRoute: controller,
      initialRoute: widget.initialRoute,

      onGenerateInitialRoutes: (initialRoute) {
        return [
          controller(
            RouteSettings(
              name: initialRoute,
              arguments: {'role': widget.role}, // ✅ auto role
            ),
          ),
        ];
      },
    );
  }
}
