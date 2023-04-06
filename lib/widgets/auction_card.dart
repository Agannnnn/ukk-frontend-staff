import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import 'auction_form.dart';

class AuctionCard extends StatelessWidget {
  final String auctionId;
  final String productId;
  final String productName;
  final DateTime startsAt;
  final DateTime endsAt;
  final int startingPrice;
  final int minBid;
  final int auctionTimeout;
  final bool status;
  final Function closeAuction;

  const AuctionCard({
    super.key,
    required this.auctionId,
    required this.productName,
    required this.productId,
    required this.startsAt,
    required this.endsAt,
    required this.startingPrice,
    required this.minBid,
    required this.auctionTimeout,
    required this.status,
    required this.closeAuction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        // Product name
        title: Text(
          productName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        subtitle: Column(
          children: [
            const Gap(10),
            // Starting price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("HARGA AWAL"),
                Text(
                  NumberFormat.currency(locale: "id_ID", name: "Rp")
                      .format(startingPrice)
                      .toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            // Divider line
            const Divider(thickness: 2),
            // Starts at
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("DIMULAI PADA"),
                Text(
                  DateFormat.yMd().add_Hm().format(startsAt),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
            const Gap(5),
            // Ends at
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("SELESAI PADA"),
                Text(
                  DateFormat.yMd().add_Hm().format(endsAt),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
            const Gap(10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton(
                  onPressed: () {
                    if (status) closeAuction(auctionId);
                  },
                  style: const ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll(Colors.redAccent)),
                  child: Text((status) ? "Tutup" : "Pelelangan Telah Ditutup"),
                ),
              ],
            )
          ],
        ),
        enabled: status,
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AuctionForm(
              auctionId: auctionId,
              productId: productId,
              startsAt: startsAt,
              endsAt: endsAt,
              startingPrice: startingPrice,
              minBid: minBid,
              auctionTimeout: auctionTimeout,
            ),
          );
        },
      ),
    );
  }
}
