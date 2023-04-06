import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:frontend_staff/main.dart';
import 'package:frontend_staff/pages/auctions.dart';
import 'package:gap/gap.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String? _username;
  String? _password;

  @override
  void initState() {
    super.initState();

    initLogin();
  }

  // Checks if this app is logged in or not
  Future initLogin() async {
    SessionManager session = SessionManager();
    String? authHeader = await session.get("Auth-Header");

    if (authHeader == null) return;

    try {
      Response<dynamic> res = await dio.get(
        "$apiUrl/",
        options: Options(headers: {'Authorization': authHeader}),
      );
      if (res.statusCode == 200) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const Auctions(),
        ));
      }
    } catch (e) {}
  }

  // Logging in
  Future login() async {
    String auth = base64Encode(utf8.encode("$_username:$_password"));
    String authHeader = "Basic $auth";

    try {
      Response res = await dio.get(
        "$apiUrl/",
        options: Options(headers: {'Authorization': authHeader}),
      );
      if (res.statusCode == 200) {
        SessionManager session = SessionManager();
        await session.set('Auth-Header', authHeader);
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const Auctions(),
        ));
      }
    } catch (e) {
      if (e.runtimeType == DioError) {
        if ((e as DioError).response?.data['error'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.response!.data['error']),
          ));
          return;
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Terjadi kesalahan"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "LOGIN",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(20),
                    // Username Input
                    TextFormField(
                      keyboardType: TextInputType.text,
                      decoration:
                          const InputDecoration(label: Text("Username")),
                      onChanged: (value) {
                        setState(() {
                          if (value.isEmpty) _username = "";
                          _username = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) return "Field ini harus diisi";
                        return null;
                      },
                    ),
                    TextFormField(
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      decoration:
                          const InputDecoration(label: Text("Password")),
                      onChanged: (value) {
                        setState(() {
                          if (value.isEmpty) _password = "";
                          _password = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) return "Field ini harus diisi";
                        return null;
                      },
                    ),
                    const Gap(20),
                    ElevatedButton(onPressed: login, child: const Text("LOGIN"))
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
