import 'package:flutter/material.dart';
import 'package:frontend_staff/main.dart';
import 'package:frontend_staff/widgets/product_form.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class ProductCard extends StatelessWidget {
  final String productId;
  final String productName;
  final String uploadedAt;
  final String? productImage;
  final String? productDescription;
  final Set<String>? productCategory;
  final Function(String id) delete;

  const ProductCard({
    super.key,
    required this.productId,
    required this.productName,
    required this.uploadedAt,
    this.productImage,
    this.productDescription,
    this.productCategory,
    required this.delete,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(productImage == null
                ? "https://images.unsplash.com/photo-1679068476679-5057c5c5d256?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=687&q=80"
                : "$apiAssetUrl/$productImage"),
            const Gap(8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                productName,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(
                "DIUPLOAD PADA ${DateFormat('d/M/y h:m').format(DateTime.parse(uploadedAt))}",
                style: const TextStyle(fontSize: 12),
              ),
            ),
            const Divider(thickness: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    label: const Text("Edit Produk"),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => ProductForm(
                        productId: productId,
                        productCategory: productCategory,
                        productName: productName,
                        productDescription: productDescription,
                      ),
                    ),
                    icon: const Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () => delete(productId),
                    icon: const Icon(Icons.delete),
                    color: Colors.white,
                    style: const ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll(Colors.redAccent),
                    ),
                  )
                ],
              ),
            ),
            const Gap(10),
          ],
        ),
      ),
    );
  }
}
