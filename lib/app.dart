import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/auth/presentation/providers/auth_provider.dart';
import 'routes/app_pages.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Load user from stored token on app start
    Future.microtask(() {
      ref.read(authProvider.notifier).loadUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);

    print('APP REBUILD');
    print(user);

    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
