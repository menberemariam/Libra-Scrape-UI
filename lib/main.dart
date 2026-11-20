import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'blocs/items/items_bloc.dart';
import 'blocs/search/search_bloc.dart';
import 'config/app_router.dart';
import 'config/app_theme.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Transparent status bar; icons follow the light theme.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const LibraScrapeApp());
}

class LibraScrapeApp extends StatelessWidget {
  const LibraScrapeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ItemsBloc(apiService: ApiService())
            ..add(const LoadItems()),
        ),
        BlocProvider(
          create: (_) => SearchBloc(apiService: ApiService()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Libra — Free Digital Library',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
        builder: (context, widget) {
          // Keep type readable without letting OS scaling break layouts.
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(
                MediaQuery.of(context).textScaler.scale(1.0).clamp(0.85, 1.2),
              ),
            ),
            child: widget!,
          );
        },
      ),
    );
  }
}
