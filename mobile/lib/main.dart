import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:app_links/app_links.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await initializeDateFormatting('fr', null);
  runApp(const ProviderScope(child: TranstuApp()));
}

class TranstuApp extends StatefulWidget {
  const TranstuApp({super.key});

  @override
  State<TranstuApp> createState() => _TranstuAppState();
}

class _TranstuAppState extends State<TranstuApp> {
  final _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    // App ouverte via un lien (cold start)
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      _handleLink(initialLink);
    }

    // App déjà ouverte, lien reçu (warm start)
    _appLinks.uriLinkStream.listen(_handleLink);
  }

  void _handleLink(Uri uri) {
    final path  = uri.path;
    final token = uri.queryParameters['token'];

    if (token == null || token.isEmpty) return;

    if (path.contains('verify-email')) {
      AppRouter.router.push('/verify-email?token=$token');
    } else if (path.contains('reset-password')) {
      AppRouter.router.push('/reset-password?token=$token');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Transtu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
    );
  }
}