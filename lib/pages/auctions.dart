import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:frontend_staff/main.dart';
import 'package:frontend_staff/widgets/auction_card.dart';
import 'package:frontend_staff/widgets/auction_form.dart';
import 'package:frontend_staff/widgets/default_layout.dart';
import 'package:gap/gap.dart';
import 'package:path_provider/path_provider.dart';

class Auctions extends StatefulWidget {
  const Auctions({super.key});

  @override
  State<Auctions> createState() => _AuctionsState();
}

class _AuctionsState extends State<Auctions> {
  List<dynamic> _auctions = [];
  String _sort = "mulai_asc";
  DateTime _reportFrom = DateTime.now();
  DateTime _reportTo = DateTime.now().add(const Duration(days: 1));
  SessionManager session = SessionManager();

  @override
  void initState() {
    super.initState();

    fetchAuctions();
  }

  Future fetchAuctions() async {
    try {
      Response res = await dio.get(
        "$apiUrl/auctions",
        options: Options(
            headers: {'Authorization': await session.get("Auth-Header")}),
        queryParameters: {'filter': _sort},
      );

      setState(() {
        _auctions = res.data['data'];
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

  Future printReport() async {
    try {
      Response res = await dio.get(
        "$apiUrl/report/auctions",
        options: Options(
            headers: {'Authorization': await session.get("Auth-Header")}),
        queryParameters: {
          'from': _reportFrom.toUtc().toIso8601String(),
          'to': _reportTo.toUtc().toIso8601String(),
        },
      );

      final directory = await getApplicationDocumentsDirectory();
      final directoryPath = directory.path;
      final reportPath =
          "$directoryPath/lelang.id-pelelangan-${DateTime.now().millisecondsSinceEpoch}.txt";
      File file = File(reportPath);
      if (res.data != null) {
        file.writeAsStringSync(res.data);
      } else {
        file.writeAsStringSync(
            "Tidak ada pelelangan terjadi di antara $_reportFrom sampai $_reportTo");
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Laporan disimpan pada $reportPath"),
      ));
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

  Future closeAuction(String auction) async {
    try {
      Response res = await dio.delete(
        "$apiUrl/auction/$auction",
        options: Options(
            headers: {'Authorization': await session.get("Auth-Header")}),
        queryParameters: {'filter': _sort},
      );

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: res.data['message']));
        await fetchAuctions();
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
    return DefaultLayout(
      body: RefreshIndicator(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  "DAFTAR PELELANGAN",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => showDialog(
                            context: context,
                            builder: (context) => const AuctionForm(),
                          ),
                          icon: const Icon(Icons.add_box),
                          label: const Text("Tambah"),
                        ),
                        const Gap(10),
                        // Generate Report
                        ElevatedButton.icon(
                          onPressed: () => showDialog(
                            context: context,
                            builder: (context) => reportDialog(context),
                          ),
                          icon: const Icon(Icons.print),
                          label: const Text("Buat Laporan"),
                        ),
                      ],
                    ),
                    // Sort Button
                    DropdownButton(
                      icon: const Icon(Icons.sort),
                      items: const [
                        DropdownMenuItem(
                          value: "mulai_asc",
                          child: Text("Mulai Terdekat"),
                        ),
                        DropdownMenuItem(
                          value: "mulai_desc",
                          child: Text("Mulai Terjauh"),
                        ),
                        DropdownMenuItem(
                          value: "berakhir_asc",
                          child: Text("Berakhir Terdekat"),
                        ),
                        DropdownMenuItem(
                          value: "berakhir_desc",
                          child: Text("Berakhir Terjauh"),
                        ),
                        DropdownMenuItem(
                          value: "harga_awal",
                          child: Text("Harga Awal"),
                        ),
                      ],
                      value: _sort,
                      onChanged: (value) {
                        setState(() {
                          _sort = value.toString();
                        });
                        fetchAuctions();
                      },
                    )
                  ],
                ),
              ),
              const Divider(thickness: 2),
              Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Center(
                    child: Wrap(
                      runSpacing: 10,
                      direction: Axis.horizontal,
                      children: _auctions
                          .map(
                            (auction) => AuctionCard(
                              auctionId: auction['id_lelang'],
                              productName: auction['Barang']['nama'],
                              productId: auction['Barang']['id_barang'],
                              startsAt: DateTime.parse(auction['mulai_lelang']),
                              endsAt: DateTime.parse(auction['selesai_lelang']),
                              startingPrice: auction['harga_awal'],
                              minBid: auction['min_penawaran'],
                              auctionTimeout: auction['timeout'],
                              status: auction['status_lelang'] == "dibuka",
                              closeAuction: closeAuction,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        onRefresh: () async {},
      ),
    );
  }

  SimpleDialog reportDialog(BuildContext context) {
    return SimpleDialog(
      children: [
        const Center(
          child: Text(
            "Cetak Laporan Pelelangan",
            style: TextStyle(fontSize: 30),
          ),
        ),
        const Gap(10),
        Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FilledButton.icon(
                onPressed: () {
                  showDatePicker(
                    context: context,
                    initialDate: _reportFrom,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2030),
                  ).then((value) {
                    if (value == null) return;
                    setState(() {
                      _reportFrom = value;
                    });
                  });
                },
                icon: const Icon(Icons.date_range),
                label: const Text("Dari"),
              ),
              const Gap(5),
              const Expanded(
                child: Divider(
                    color: Color.fromRGBO(103, 148, 142, 1), thickness: 1),
              ),
              const Gap(5),
              FilledButton.icon(
                onPressed: () {
                  showDatePicker(
                    context: context,
                    initialDate: _reportTo,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2030),
                  ).then((value) {
                    if (value == null) return;
                    setState(() {
                      _reportTo = value;
                    });
                  });
                },
                icon: const Icon(Icons.date_range),
                label: const Text("Hingga"),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: FilledButton(
            onPressed: printReport,
            child: const Text("Print"),
          ),
        )
      ],
    );
  }
}
