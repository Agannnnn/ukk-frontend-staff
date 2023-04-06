import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:frontend_staff/pages/accounts.dart';
import 'package:frontend_staff/pages/auctions.dart';
import 'package:frontend_staff/pages/login.dart';
import 'package:frontend_staff/pages/products.dart';

class DefaultLayout extends StatelessWidget {
  final Widget body;

  const DefaultLayout({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("LELANG.ID", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(103, 148, 142, 1),
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: const Color(0xFF67948E),
              child: const ListTile(
                title: Text(
                  "LELANG.ID",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            ListTile(
              title: const Text("PELELANGAN"),
              textColor: Colors.grey[700],
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const Auctions(),
                ));
              },
            ),
            ListTile(
              title: const Text("BARANG"),
              textColor: Colors.grey[700],
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const Products(),
                ));
              },
            ),
            ListTile(
              title: const Text("PETUGAS"),
              textColor: Colors.grey[700],
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const Accounts(),
                ));
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton.icon(
                onPressed: () async {
                  await SessionManager().destroy();
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const Login(),
                  ));
                },
                label: const Text("Logout"),
                icon: const Icon(Icons.logout),
              ),
            )
          ],
        ),
      ),
      body: body,
    );
  }
}
