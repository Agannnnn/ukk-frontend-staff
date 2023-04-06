import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend_staff/pages/login.dart';

Dio dio = Dio();

late String apiUrl;
late String apiAssetUrl;

void main() async {
  final cookieJar = CookieJar();
  dio.interceptors.add(CookieManager(cookieJar));

  await dotenv.load(fileName: ".env");
  apiUrl = "${dotenv.env["API_URL"]}";
  apiAssetUrl = "${dotenv.env["API_ASSET_URL"]}";

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "LELANG.ID",
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          background: Colors.white,
          seedColor: Color(0xFFFFFFFF),
          primary: const Color(0xFF67948E),
        ),
      ),
      home: const Login(),
    );
  }
}
