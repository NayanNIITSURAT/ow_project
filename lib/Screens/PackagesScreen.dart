import 'package:flutter/material.dart';
import 'package:owlet/Components/BackArrow.dart';
import 'package:owlet/Components/Toast.dart';
import 'package:owlet/Providers/Package.dart';
import 'package:owlet/Providers/User.dart';
import 'package:owlet/Screens/AddListingScreen.dart';
import 'package:owlet/Widgets/PackageItem.dart';
import 'package:owlet/constants/images.dart';
import 'package:owlet/constants/palettes.dart';
import 'package:owlet/models/User.dart';
// import 'package:paystack_manager/paystack_manager.dart';
import 'package:provider/provider.dart';

class PackagesScreen extends StatelessWidget {
  static const routeName = '/packages';
  @override
  Widget build(BuildContext context) {
    List<Color> bgColors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
    ];
    final userData = Provider.of<UserProvider>(context);
    User? profile = userData.profile;
    void _onSubscribe(Package plan) {
      // if (plan.price < 1)
      //   userData.subscribe(plan,
      //       onComplete: (plan) => Navigator.of(context)
      //           .pushReplacementNamed(AddListingScreen.routeName));
      // else
      //   PaystackPayManager(context: context)
      //     ..setSecretKey("sk_test_506d48f9ac48704719df5f97dd930aa52fb432d3")
      //     //accepts widget
      //     ..setReference(
      //         "OWLET_${DateTime.now().millisecondsSinceEpoch.toString()}")
      //     ..setCompanyAssetImage(Image(
      //       image: AssetImage(logo),
      //     ))
      //     ..setAmount(plan.price * 100)
      //     ..setCurrency("NGN")
      //     ..setEmail(profile.email)
      //     ..setFirstName(profile.fullName)
      //     ..setMetadata(
      //       {
      //         "custom_fields": [
      //           {
      //             "display_name": "Payment to",
      //             "variable_name": "payment_to",
      //             "value": "Owlet",
      //           },
      //           {
      //             "display_name": "For",
      //             "variable_name": "for",
      //             "value": "${plan.name} Subsciption",
      //           },
      //         ]
      //       },
      //     )
      //     ..onSuccesful((Transaction txn) {
      //       userData.subscribe(plan,
      //           onComplete: (plan) => Navigator.of(context)
      //               .pushReplacementNamed(AddListingScreen.routeName));
      //     })
      //     ..onFailed(() => print('Payment Failed'))
      //     ..onCancel(() => print('Payment Cancelled'))
      //     // ..onPending(onPending)
      //     ..initialize();
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: BackArrow(),
        ),
        title: Text(
          'Packages',
          style: TextStyle(color: Palette.primaryColor),
        ),
        toolbarHeight: 50,
        elevation: 1,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            child: Consumer<PackageProvider>(
              builder: (_, packageData, __) {
                var packages = packageData.items;
                return Column(
                  children: [
                    SizedBox(height: 20),
                    ...packages.map(
                      (e) => PackageItem(
                        color: e.price > 1
                            ? Colors.grey.shade400
                            : bgColors[packages.indexOf(e)],
                        title: e.name,
                        price: e.price < 1 ? 'FREE' : '₦${e.price}',
                        contents: e.features,
                        onPressed: () => userData.profile.subscription !=
                                        null &&
                                    userData.profile.subscription?.package !=
                                        e ||
                                e.price > 1
                            ? Toast(context, message: 'Feature coming soon...')
                                .show()
                            : _onSubscribe(e),
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
