import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:frontend_staff/main.dart';
import 'package:gap/gap.dart';
import 'package:path/path.dart';

class ProductForm extends StatefulWidget {
  final String? productId;
  final String? productName;
  final String? productDescription;
  final Set<String>? productCategory;

  const ProductForm({
    super.key,
    this.productId,
    this.productName,
    this.productDescription,
    this.productCategory,
  });

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  List<File> _files = [];
  String _name = "";
  String _description = "";
  Set<String> _categoriesInput = {};
  List<dynamic> _categories = [];
  SessionManager session = SessionManager();

  @override
  void initState() {
    super.initState();

    setState(() {
      _name = super.widget.productName ?? _name;
      _description = super.widget.productDescription ?? _description;
      _categoriesInput = super.widget.productCategory ?? _categoriesInput;
    });

    fetchCategories();
  }

  Future fetchCategories() async {
    try {
      Response res = await dio.get(
        "$apiUrl/categories",
        options: Options(
            headers: {'Authorization': await session.get("Auth-Header")}),
      );
      setState(() {
        _categories = res.data['data'];
      });
    } catch (e) {}
  }

  Future saveProduct() async {
    var files = _files.map((file) => MultipartFile.fromFileSync(
          file.path,
        ));
    FormData newProduct = FormData.fromMap({
      'nama': _name,
      'deskripsi': _description,
      'images': [...files],
      'categories': _categoriesInput.join(";")
    });

    try {
      if (super.widget.productId != null) {
        Response res = await dio.patch(
          "$apiUrl/product/${super.widget.productId}",
          options: Options(
              headers: {'Authorization': await session.get("Auth-Header")}),
          data: newProduct,
        );
        if (res.statusCode == 200) {
          Navigator.pop(this.context);
        }
      } else {
        Response res = await dio.post(
          "$apiUrl/product",
          options: Options(
              headers: {'Authorization': await session.get("Auth-Header")}),
          data: newProduct,
        );
        if (res.statusCode == 201) {
          Navigator.pop(this.context);
        }
      }
    } catch (e) {
      if (e.runtimeType == DioError) {
        if ((e as DioError).response?.data['error'] != null) {
          ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(
            content: Text(e.response!.data['error']),
          ));
          return;
        }
      }
      ScaffoldMessenger.of(this.context).showSnackBar(const SnackBar(
        content: Text("Terjadi kesalahan"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(children: [
          // Title
          Text(
            "${widget.productId != null ? 'EDIT' : 'TAMBAH'} PRODUK",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          const Divider(thickness: 2),
          const Gap(20),
          // File picker
          ElevatedButton.icon(
            onPressed: () async {
              FilePickerResult? files;
              try {
                files =
                    await FilePicker.platform.pickFiles(allowMultiple: true);
                if (files != null) {
                  setState(() {
                    _files = files!.paths.map((path) => File(path!)).toList();
                  });
                } else {
                  _files = [];
                }
              } catch (e) {}
            },
            icon: const Icon(Icons.image),
            label: const Text("TAMBAH GAMBAR"),
          ),
          // Files picked
          ListView(
            shrinkWrap: true,
            children: [
              ..._files.map(
                (imageFile) => ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  leading: Image.file(imageFile, width: 100),
                  title: Text(basename(imageFile.path)),
                  onTap: () {
                    setState(() => _files.remove(imageFile));
                  },
                ),
              )
            ],
          ),
          const Gap(10),
          // Product name
          TextFormField(
            decoration: const InputDecoration(
              label: Text("NAMA BARANG"),
              border: OutlineInputBorder(),
            ),
            initialValue: _name,
            onChanged: (value) => setState(() => _name = value),
          ),
          const Gap(10),
          // Product description
          TextFormField(
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: const InputDecoration(
              label: Text("DESKRIPSI BARANG"),
              border: OutlineInputBorder(),
            ),
            initialValue: _description,
            onChanged: (value) => setState(() => _description = value),
          ),
          const Gap(20),
          // Product category
          const Text(
            "KATEGORI",
            style: TextStyle(fontSize: 18),
          ),
          const Gap(10),
          Wrap(
            direction: Axis.horizontal,
            spacing: 5,
            children: [
              ..._categories.map((category) => InputChip(
                    label: Text("Category ${category['nama']}"),
                    selected:
                        _categoriesInput.contains(category['id_kategori']),
                    selectedColor: const Color.fromRGBO(103, 148, 142, 1),
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          _categoriesInput.add(category['id_kategori']);
                        } else {
                          _categoriesInput.remove(category['id_kategori']);
                        }
                      });
                    },
                  )),
              FilledButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      final GlobalKey<FormState> _categoryDialog = GlobalKey();
                      String _categoryNameInput = "";

                      return Dialog(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Form(
                            key: _categoryDialog,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  "TAMBAH KATEGORI",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                                const Gap(5),
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 300),
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                      label: Text("Nama Kategori"),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Field harus diisi";
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        _categoryNameInput = value;
                                      });
                                    },
                                  ),
                                ),
                                const Gap(10),
                                FilledButton(
                                    onPressed: () async {
                                      if (!_categoryDialog.currentState!
                                          .validate()) return;
                                      await dio.post(
                                        "$apiUrl/category",
                                        data: {'nama': _categoryNameInput},
                                        options: Options(headers: {
                                          'Authorization':
                                              await session.get("Auth-Header")
                                        }),
                                      );
                                      fetchCategories();
                                    },
                                    child: const Text("Simpan Kategori"))
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                child: const Text("Tambah Kategori"),
              )
            ],
          ),
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FilledButton(
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.redAccent),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("BATAL"),
              ),
              const Gap(10),
              ElevatedButton(
                onPressed: saveProduct,
                child: const Text("SIMPAN"),
              ),
            ],
          )
        ]),
      ),
    );
  }
}
