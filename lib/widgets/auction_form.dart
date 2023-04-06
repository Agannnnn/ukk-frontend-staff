import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:frontend_staff/main.dart';
import 'package:gap/gap.dart';

class AuctionForm extends StatefulWidget {
  final String? auctionId;
  final String? productId;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final int? startingPrice;
  final int? minBid;
  final int? auctionTimeout;

  const AuctionForm({
    super.key,
    this.auctionId,
    this.productId,
    this.startsAt,
    this.endsAt,
    this.startingPrice,
    this.minBid,
    this.auctionTimeout,
  });

  @override
  State<AuctionForm> createState() => _AuctionFormState();
}

class _AuctionFormState extends State<AuctionForm> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  String _auctionId = "";
  String? _productId;
  DateTime _startsAt = DateTime.now();
  DateTime _endsAt = DateTime.now();
  int _startingPrice = 0;
  int _minBid = 0;
  int _auctionTimeout = 0;
  List _products = [];
  SessionManager session = SessionManager();

  @override
  void initState() {
    super.initState();

    setState(() {
      _auctionId = super.widget.auctionId ?? _auctionId;
      _productId = super.widget.productId ?? _productId;
      _startsAt = super.widget.startsAt ?? _startsAt;
      _endsAt = super.widget.endsAt ?? _endsAt;
      _startingPrice = super.widget.startingPrice ?? _startingPrice;
      _minBid = super.widget.minBid ?? _minBid;
      _auctionTimeout = super.widget.auctionTimeout ?? _auctionTimeout;
    });

    fetchProducts();
  }

  Future fetchProducts() async {
    try {
      if (super.widget.productId == null) {
        Response res = await dio.get(
          '$apiUrl/products',
          options: Options(
              headers: {'Authorization': await session.get("Auth-Header")}),
        );
        setState(() {
          _products = (res.data['data'] as List)
              .map((product) =>
                  {'id': product['id_barang'], 'nama': product['nama']})
              .toList();
        });
      } else {
        Response res = await dio.get(
          '$apiUrl/product/${super.widget.productId}',
          options: Options(
              headers: {'Authorization': await session.get("Auth-Header")}),
        );
        setState(() {
          _products = [
            {
              'id': res.data['data']['id_barang'],
              'nama': res.data['data']['nama']
            }
          ];
        });
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

  Future saveAuction() async {
    try {
      if (super.widget.auctionId == null) {
        Response res = await dio.post("$apiUrl/auction",
            options: Options(
                headers: {'Authorization': await session.get("Auth-Header")}),
            data: {
              'mulai_lelang': _startsAt.toUtc().toIso8601String().toString(),
              'selesai_lelang': _endsAt.toUtc().toIso8601String().toString(),
              'harga_awal': _startingPrice,
              'min_penawaran': _minBid,
              'id_barang': _productId,
              'timeout': _auctionTimeout
            });
        if (res.statusCode == 201) {
          Navigator.of(context).pop();
        }
      } else {
        Response res = await dio.patch("$apiUrl/auction",
            options: Options(
                headers: {'Authorization': await session.get("Auth-Header")}),
            data: {
              'id_lelang': _auctionId,
              'mulai_lelang': _startsAt.toUtc().toIso8601String().toString(),
              'selesai_lelang': _endsAt.toUtc().toIso8601String().toString(),
              'harga_awal': _startingPrice,
              'min_penawaran': _minBid,
              'id_barang': _productId,
              'timeout': _auctionTimeout
            });
        if (res.statusCode == 200) {
          Navigator.of(context).pop();
        }
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
                "${super.widget.auctionId != null ? 'UBAH' : 'BUAT'} JADWAL LELANG",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
              const Divider(thickness: 2),
              const Gap(20),
              // Auction's product
              const Text("BARANG UNTUK DILELANG"),
              DropdownButton(
                items: _products.map((product) {
                  return DropdownMenuItem(
                    value: (product['id'] as String?) ?? "",
                    child: Text(product['nama'] ?? ""),
                  );
                }).toList(),
                value: _productId,
                onChanged: (value) {
                  setState(() {
                    _productId = value;
                  });
                },
                isExpanded: true,
                hint: const Text("Pilih barang"),
              ),
              // -Auction's product
              const Gap(5),
              // Auction's schedule
              Row(
                children: [
                  // Starts at
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_startsAt),
                        ).then((value) {
                          if (value == null) return;
                          setState(() {
                            _startsAt = DateTime(
                              _startsAt.year,
                              _startsAt.month,
                              _startsAt.day,
                              value.hour,
                              value.minute,
                            );
                          });
                        });
                        showDatePicker(
                          context: context,
                          initialDate: _startsAt,
                          firstDate: DateTime(DateTime.now().year),
                          lastDate: DateTime(2040),
                        ).then((value) {
                          if (value == null) return;
                          setState(() {
                            _startsAt = DateTime(
                              value.year,
                              value.month,
                              value.day,
                              _startsAt.hour,
                              _startsAt.minute,
                            );
                          });
                        });
                      },
                      icon: const Icon(Icons.date_range),
                      label: const Text("MULAI PADA"),
                    ),
                  ),
                  const Gap(8),
                  // Ends at
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_endsAt),
                        ).then((value) {
                          if (value == null) return;
                          setState(() {
                            _endsAt = DateTime(
                              _endsAt.year,
                              _endsAt.month,
                              _endsAt.day,
                              value.hour,
                              value.minute,
                            );
                          });
                        });
                        showDatePicker(
                          context: context,
                          initialDate: _endsAt,
                          firstDate: DateTime(DateTime.now().year),
                          lastDate: DateTime(2040),
                        ).then((value) {
                          if (value == null) return;
                          setState(() {
                            _endsAt = DateTime(
                              value.year,
                              value.month,
                              value.day,
                              _endsAt.hour,
                              _endsAt.minute,
                            );
                          });
                        });
                      },
                      icon: const Icon(Icons.date_range),
                      label: const Text("SELESAI PADA"),
                    ),
                  ),
                ],
              ),
              const Gap(10),
              // Starting price
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  label: Text("PENAWARAN AWAL"),
                  prefix: Text("Rp"),
                ),
                initialValue: _startingPrice.toString(),
                validator: checkNumberInput,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: (value) {
                  setState(() {
                    if (value == "") {
                      _startingPrice = 0;
                    } else {
                      if (_formKey.currentState!.validate()) {
                        _startingPrice = int.parse(value);
                      }
                    }
                  });
                },
              ),
              const Gap(10),
              // Minimum bid ammount
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  label: Text("PENAWARAN MINIMAL"),
                  prefix: Text("Rp"),
                ),
                initialValue: _minBid.toString(),
                validator: checkNumberInput,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: (value) {
                  setState(() {
                    if (value == "") {
                      _minBid = 0;
                    } else {
                      if (_formKey.currentState!.validate()) {
                        _minBid = int.parse(value);
                      }
                    }
                  });
                },
              ),
              const Gap(10),
              // Auction timeout
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  label: Text("TIMOUT LELANG"),
                  suffix: Text("Detik"),
                ),
                initialValue: _auctionTimeout.toString(),
                validator: checkNumberInput,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: (value) {
                  setState(() {
                    if (value == "") {
                      _auctionTimeout = 0;
                    } else {
                      if (_formKey.currentState!.validate()) {
                        _auctionTimeout = int.parse(value);
                      }
                    }
                  });
                },
              ),
              const Gap(10),
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
                    onPressed: saveAuction,
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
