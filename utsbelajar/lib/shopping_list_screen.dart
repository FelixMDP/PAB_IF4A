import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:utsbelajar/shopping_services.dart';
import 'package:utsbelajar/signinscreen.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});
  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  @override
  final TextEditingController _controller = TextEditingController();
  final Shopingservice _shoppingService = Shopingservice();

  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const SignInScreen(),
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Shopping List'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(
                onPressed: () {
                  signOut(context);
                },
                icon: Icon(Icons.logout))
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                          hintText: "Masukkan Nama Barang"),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _shoppingService.addItem((_controller.text));
                      _controller.clear();
                    },
                    icon: const Icon(Icons.add),
                  )
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<Map<String, String>>(
                stream: _shoppingService.getShoppingList(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final items = snapshot.data!;
                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final key = items.keys.elementAt(index);
                        final value = items[key];
                        return ListTile(
                          title: Text(value!),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _shoppingService.removeItem(key);
                            },
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            )
          ],
        ));
  }
}
