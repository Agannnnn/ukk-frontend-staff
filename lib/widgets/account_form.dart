import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:frontend_staff/main.dart';
import 'package:gap/gap.dart';

class AccountForm extends StatefulWidget {
  const AccountForm({super.key, this.userId});

  final String? userId;

  @override
  State<AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends State<AccountForm> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  SessionManager session = SessionManager();
  String _firstName = "";
  String _lastName = "";
  String _username = "";
  String _password = "";
  String _level = "petugas";

  @override
  void initState() {
    super.initState();
  }

  Future saveAccount() async {
    try {
      Response res = await dio.post("$apiUrl/staff",
          options: Options(
            headers: {'Authorization': await session.get("Auth-Header")},
          ),
          data: {
            'nama_depan': _firstName,
            'nama_belakang': _lastName,
            'username': _username,
            'password': _password,
            'level': _level
          });

      if (res.statusCode == 201) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(res.data['message']),
        ));
      }
    } catch (e) {
      Navigator.of(context).pop();
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
    return Dialog.fullscreen(
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Title
              Text(
                "${super.widget.userId != null ? 'EDIT' : 'BUAT'} AKUN",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
              const Divider(thickness: 2),
              const Gap(20),
              // Name Input

              // First Name Input
              TextFormField(
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(label: Text("Nama Depan")),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Field harus diisi";
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _firstName = value;
                  });
                },
              ),
              const Gap(10),

              // Last Name Input
              TextFormField(
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(label: Text("Nama Belakang")),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Field harus diisi";
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _lastName = value;
                  });
                },
              ),
              const Gap(10),

              // Username Input
              TextFormField(
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(label: Text("Username")),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Field harus diisi";
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _username = value;
                  });
                },
              ),
              const Gap(10),

              // Password Input
              TextFormField(
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(label: Text("Password")),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Field harus diisi";
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _password = value;
                  });
                },
                obscureText: true,
              ),
              const Gap(10),

              // Level Select
              DropdownButton(
                items: const [
                  DropdownMenuItem(
                    value: "administrator",
                    child: Text("Administrator"),
                  ),
                  DropdownMenuItem(
                    value: "petugas",
                    child: Text("Petugas"),
                  ),
                ],
                value: _level,
                onChanged: (value) {
                  setState(() {
                    _level = value!;
                  });
                },
              ),

              const Gap(20),
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FilledButton(
                    style: const ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll(Colors.redAccent),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("BATAL"),
                  ),
                  const Gap(10),
                  ElevatedButton(
                    onPressed: saveAccount,
                    child: const Text("SIMPAN"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  String? checkNumberInput(value) {
    if (value == null) return "Field ini harus diisi";
    try {
      int.parse(value);
    } catch (e) {
      return "Field ini harus berisikan angka";
    }
    return null;
  }
}
