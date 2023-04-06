import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:frontend_staff/main.dart';
import 'package:frontend_staff/widgets/account_form.dart';
import 'package:frontend_staff/widgets/default_layout.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class Accounts extends StatefulWidget {
  const Accounts({super.key});

  @override
  State<Accounts> createState() => _AccountsState();
}

class _AccountsState extends State<Accounts> {
  List<dynamic> _accounts = [];
  String? _keyword;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();

    fetchAccounts();
  }

  Future fetchAccounts() async {
    SessionManager session = SessionManager();
    try {
      Response res = await dio.get(
        "$apiUrl/staffs",
        options: Options(
          headers: {'Authorization': await session.get("Auth-Header")},
        ),
        queryParameters: {'search': _keyword},
      );

      setState(() {
        _accounts = res.data['data'];
        _isAdmin = res.headers['set-cookie']!.last.contains("true");
      });
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
    return DefaultLayout(
      body: RefreshIndicator(
        onRefresh: fetchAccounts,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const Text(
                  "DAFTAR PETUGAS",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const Divider(thickness: 2),
                TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("Cari petugas"),
                    suffixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) => setState(() {
                    _keyword = value.toString();
                  }),
                  onSubmitted: (value) {
                    fetchAccounts();
                  },
                ),
                const Gap(10),
                if (_isAdmin)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => showDialog(
                          context: context,
                          builder: (context) => const AccountForm(),
                        ),
                        icon: const Icon(Icons.person_add_alt_1),
                        label: const Text("Tambah"),
                      ),
                    ],
                  ),
                const Gap(15),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    children: _accounts
                        .map(
                          (account) => Card(
                            child: ListTile(
                              title: Row(children: [
                                const Text("Nama "),
                                Text(
                                  "${account['nama_depan']} ${account['nama_belakang']}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                )
                              ]),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("User ID ${account['id_petugas']}"),
                                  Text("Username ${account['username']}"),
                                  Text("Level ${account['level']}"),
                                  const Gap(10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Pelelangan Dibuat",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      ...((account['LelangDibuat'] ??
                                              List.empty()) as List)
                                          .map((auction) => Text(
                                              "ID ${auction['id_lelang']} | Pada ${DateFormat('d/M/y h:m').format(DateTime.parse(auction['mulai_lelang']))}"))
                                          .toList()
                                    ],
                                  ),
                                  const Gap(10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Pelelangan Ditutup",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      ...((account['LelangDitutup'] ??
                                              List.empty()) as List)
                                          .map((auction) => Text(
                                              "ID ${auction['id_lelang']} | Pada ${DateFormat('d/M/y h:m').format(DateTime.parse(auction['selesai_lelang']))}"))
                                          .toList()
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
