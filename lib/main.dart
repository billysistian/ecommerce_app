import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/network/api_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // LOAD ENV
  await dotenv.load(fileName: ".env");

  // INIT API CLIENT
  await ApiClient.init();

  runApp(const ProviderScope(child: MyApp()));
}
