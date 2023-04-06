import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:frontend_staff/main.dart';
import 'package:frontend_staff/widgets/default_layout.dart';
import 'package:frontend_staff/widgets/product_card.dart';
import 'package:frontend_staff/widgets/product_form.dart';
import 'package:gap/gap.dart';
import 'package:path_provider/path_provider.dart';

class Products extends StatefulWidget {
  const Products({super.key});

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  List<dynamic> _products = [];
  String? _keyword;
  String? _sort = "nama";
  DateTime _reportFrom = DateTime.now();
  DateTime _reportTo = DateTime.now().add(const Duration(days: 1));
  SessionManager session = SessionManager();

  @override
  void initState() {
    super.initState();

    fetchProducts();
  }

  Future fetchProducts() async {
    try {
      var res = await dio.get(
        "$apiUrl/products",
        options: Options(
            headers: {'Authorization': await session.get("Auth-Header")}),
        queryParameters: {'search': _keyword, 'sort': _sort},
      );
      setState(() {
        _products = res.data['data'];
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

  Future deleteProduct(String id) async {
    try {
      Response res = await dio.delete("$apiUrl/product/$id",
          options: Options(
              headers: {'Authorization': await session.get("Auth-Header")}));
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Barang terhapus"),
        ));
        fetchProducts();
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

  Future printReport() async {
    try {
      Response<dynamic> res = await dio.get(
        "$apiUrl/report/products",
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
          "$directoryPath/lelang.id-barang-${DateTime.now().millisecondsSinceEpoch}.txt";
      File file = File(reportPath);
      file.writeAsStringSync(res.data);
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

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      body: RefreshIndicator(
        onRefresh: fetchProducts,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  "DAFTAR BARANG",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
                child: TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("Cari produk"),
                    suffixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) => setState(() {
                    _keyword = value.toString();
                  }),
                  onSubmitted: (value) {
                    fetchProducts();
                  },
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
                            builder: (context) => const ProductForm(),
                          ),
                          icon: const Icon(Icons.add_box),
                          label: const Text("Tambah"),
                        ),
                        const Gap(10),
                        ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              builder: (context) =>
                                  generateReportDialog(context),
                              context: context,
                            );
                          },
                          icon: const Icon(Icons.print),
                          label: const Text("Buat Laporan"),
                        ),
                      ],
                    ),
                    DropdownButton(
                      icon: const Icon(Icons.sort),
                      items: const [
                        DropdownMenuItem(
                          value: "nama",
                          child: Text("Urutkan nama"),
                        ),
                        DropdownMenuItem(
                          value: "upload_baru",
                          child: Text("Upload Terbaru"),
                        ),
                        DropdownMenuItem(
                          value: "upload_lama",
                          child: Text("Upload Terlama"),
                        ),
                      ],
                      value: _sort,
                      onChanged: (value) {
                        setState(() {
                          _sort = value.toString();
                        });
                        fetchProducts();
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
                      children: _products
                          .map(
                            (e) => ProductCard(
                              productId: e['id_barang'],
                              productName: e['nama'],
                              productDescription: e['deskripsi'],
                              uploadedAt: e['diunggah'],
                              productCategory: Set.from(
                                (e['Kategori'] as List)
                                    .map((category) => category['id_kategori']),
                              ),
                              productImage: (e['FotoBarang'] as List).isEmpty
                                  ? null
                                  : e['FotoBarang'][0]['filename'],
                              delete: deleteProduct,
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
      ),
    );
  }

  SimpleDialog generateReportDialog(BuildContext context) {
    return SimpleDialog(
      children: [
        Column(
          children: [
            const Text(
              "Buat Laporan Pelelangan",
              style: TextStyle(fontSize: 30),
            ),
            const Gap(10),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
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
                  const Expanded(
                    child: Divider(thickness: 2),
                  ),
                  ElevatedButton.icon(
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
            ElevatedButton(
              onPressed: printReport,
              child: const Text("Print"),
            )
          ],
        )
      ],
    );
  }
}
