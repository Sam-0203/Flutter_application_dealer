import 'package:flutter/foundation.dart';
import 'package:dealershub_/src/utils/helper/install_checker.dart';
import 'package:dealershub_/src/utils/route/route.dart';
import 'package:dealershub_/src/utils/helper/secure_storage.dart';
import 'package:dealershub_/src/viewmodels/add_car_view_model.dart';
import 'package:dealershub_/src/viewmodels/auth_view_model.dart';
import 'package:dealershub_/src/viewmodels/language_viewmodel.dart';
import 'package:dealershub_/src/viewmodels/state_cities_viemodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Full-screen app mode for Android.
  await _applyAndroidFullScreen();

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

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _applyAndroidFullScreen();

    SystemChrome.setSystemUIChangeCallback((systemOverlaysAreVisible) async {
      if (systemOverlaysAreVisible) {
        await Future.delayed(const Duration(milliseconds: 250));
        await _applyAndroidFullScreen();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _applyAndroidFullScreen();
    }
  }

  @override
  void didChangeMetrics() {
    if (_isKeyboardVisible) return;
    Future.delayed(const Duration(milliseconds: 250), _applyAndroidFullScreen);
  }

  bool get _isKeyboardVisible {
    final views = WidgetsBinding.instance.platformDispatcher.views;
    if (views.isEmpty) return false;
    return views.first.viewInsets.bottom > 0;
  }

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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setSystemUIChangeCallback(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dealers Hub',
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

Future<void> _applyAndroidFullScreen() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
}
