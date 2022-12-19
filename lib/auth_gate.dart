import 'package:bagator/models/product.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/gestures.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<void> showMyDialog() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Listes des produits'),
            content: FirestoreListView<Product>(
              query: FirebaseFirestore.instance
                  .collection('products')
                  .orderBy('name')
                  .withConverter<Product>(
                    fromFirestore: (snapshot, _) =>
                        Product.fromJson(snapshot.data()!),
                    toFirestore: (product, _) => product.toJson(),
                  ),
              itemBuilder: (context, snapshot) {
                Product product = snapshot.data();
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
            sideBuilder: (context, constraints) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    color: Colors.black,
                    child: Stack(
                      children: [
                        Image.asset(
                          "assets/icons/baguette-3d.png",
                          fit: BoxFit.scaleDown,
                        ),
                        const Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Text(
                            "Bagator.",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 56,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            footerBuilder: (context, _) {
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      text:
                          'By signing in, you agree to our terms and conditions.',
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launchUrl(
                            Uri(
                              scheme: 'https',
                              host: 'www.nature.com',
                              path: 'info/terms-and-conditions',
                            ),
                          );
                        },
                    ),
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
              onPressed: showMyDialog,
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
