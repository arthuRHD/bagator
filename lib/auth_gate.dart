import 'package:bagator/models/product.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<void> _showMyDialog() async {
      final products = FirebaseFirestore.instance
          .collection('products')
          .orderBy('name')
          .limit(20)
          .withConverter<Product>(
            fromFirestore: (snapshot, _) => Product.fromJson(snapshot.data()!),
            toFirestore: (product, _) => product.toJson(),
          );

      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Listes des produits'),
            content: FirestoreListView(
              query: products,
              itemBuilder: (context, doc) {
                Product product = doc.data();
                return ListTile(title: Text(product.name));
              },
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Approve'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(
            headerBuilder: (context, constraints, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset(""),
                ),
              );
            },
            footerBuilder: (context, _) {
              return const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Center(
                  child: Text(
                    'By signing in, you agree to our terms and conditions.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            },
          );
        }

        Future.microtask(
          () => FirebaseAnalytics.instance
              .setCurrentScreen(screenName: 'Profile'),
        );

        Future.microtask(
          () => FirebaseAnalytics.instance.logLogin(),
        );

        return ProfileScreen(
          avatarSize: 140,
          appBar: AppBar(actions: [
            IconButton(
              color: Colors.white,
              icon: const Icon(Icons.shopping_basket),
              onPressed: _showMyDialog,
            ),
          ]),
          actions: [
            SignedOutAction((context) {
              Navigator.pushReplacementNamed(context, '/');
            }),
          ],
        );
      },
    );
  }
}
