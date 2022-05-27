import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:owlet/models/walletRefresh.dart';
import 'package:provider/provider.dart';
import '../../Components/Loading.dart';
import '../../Components/Toast.dart';
import '../../Components/bottomsheetbutton.dart';
import '../../Providers/Auth.dart';

import '../../Widgets/PullToRefresh.dart';
import '../../Widgets/SettingsBar.dart';
import '../../constants/constants.dart';
import '../../constants/images.dart';
import '../../constants/palettes.dart';

import '../../services/auth.dart';
import '../NotificationScreen.dart';
import '../PassBookScreen.dart';

class WalletScreen extends StatefulWidget {
  WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final formKey = new GlobalKey<FormState>();
  // String value = '';
  int senderUserId = 0,
      receiverUserId = 0,
      walletAmount = 0,
      walletTransferAmount = 0;
  String status = '', message = '', email = '';
  String username = '', phone = '', fullName = '';
  String avartar = '', fname = '', bio = '';
  String password = '', lname = '', website = '';
  String confirmation_token = '', lastQueryAt = '', createdAt = '';
  String updatedAt = '', deletedAt = '', countryIso = '';
  String lastWalletUpdate = '', transferMessage = '';
  bool isloading = false;
  var amount;
  int sellectedindex = 0;
  final plugin = PaystackPlugin();
  bool isloadingstate = true;

  @override
  void initState() {
    // Future.delayed(Duration.zero, () => getData(true));
    final data = Provider.of<WalletRefresh>(context, listen: false);
    data.fetchData(context);

    Timer(Duration(seconds: 3), () async {
      setState(() {
        isloadingstate = false;
      });
    });

    super.initState();
    plugin.initialize(publicKey: Global.paystackPublicKey);
  }

  TextEditingController _Walletcontroller = TextEditingController();
  List<String> Amounts = [
    "10",
    "20",
    "50",
    "100",
  ];

  Future<void> _pullRefresh(refresh) async {
    if (refresh == true) {
      CupertinoActivityIndicator();

      final data = Provider.of<WalletRefresh>(context, listen: false);
      await data.fetchData(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<WalletRefresh>(context);
    // final data = Provider.of<Transaction>(context);
    // var auth = Provider.of<AuthProvider>(context);
    // final data = Provider.of<Transaction>(context);
    AuthProvider auth = Provider.of<AuthProvider>(context);
    final loadData;
    loadData = data.getData;
    // onInput(String query) async =>
    //     await loadData(data.walletData, refresh: true, searchQuery: query);
    var doAdd = () {
      var value = _Walletcontroller.text;

      if (value == "0" || value.isEmpty) {
        Toast(context, message: 'Please Enter valid Amount').show();
      } else {
        setState(() {
          isloading = true;
        });
        final form = formKey.currentState;
        form!.save();
        if (form.validate()) {
          auth.Transation(
              _Walletcontroller,
              Update(
                senderUserId: senderUserId,
                receiverUserId: receiverUserId,
                walletAmount: walletAmount,
                message: message,
                email: email,
                username: username,
                phone: phone,
                fullName: fullName,
                avartar: avartar,
                fname: fname,
                bio: bio,
                password: password,
                lname: lname,
                website: website,
                confirmation_token: confirmation_token,
                lastQueryAt: lastQueryAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                countryIso: countryIso,
                lastWalletUpdate: lastWalletUpdate,
                transferMessage: transferMessage,
                walletTransferAmount: walletTransferAmount,
                status: status,
              )).then(
            (response) {
              setState(() {
                isloading = false;
              });
              print("Hello" + response.toString());
              if (response['status']) {
                Toast(context, message: response['message']).show();
                _Walletcontroller.clear();
                amount = 0;
              } else {
                setState(() {
                  _Walletcontroller.clear();
                  amount = 0;
                });
                Toast(
                  context,
                  title: "Report Problem Failed",
                  message: response['message'],
                ).show();
              }
            },
          );
        }
      }
      setState(() {});
    };
    return isloadingstate
        ? Container(
            color: Colors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Center(
                      child: Text("Loading wallet data..!",
                          style: TextStyle(
                              decoration: TextDecoration.none,
                              color: Colors.black,
                              fontSize: 20)))
                ],
              ),
            ),
          )
        : Form(
            key: formKey,
            child: SettingsBar(
              trailing: false,
              isappbar: false,
              child: Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 170,
                    color: walletbgcolor,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height,
                    child: Flexible(
                      child: Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 70,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.2,
                                    child: Icon(
                                      Icons.arrow_back_outlined,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Text(
                                  'Wallet',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.2,
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Expanded(
                            child: PullToLoad(
                              refresh: () => _pullRefresh(true),
                              load: () => _pullRefresh(false),
                              child: ScrollConfiguration(
                                behavior: ScrollBehavior()
                                    .copyWith(overscroll: false),
                                child: SingleChildScrollView(
                                  child: Container(
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 140,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.90,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                                width: 0.6,
                                                color: Colors.grey
                                                    .withOpacity(0.3)),
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 20),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    Text(
                                                      "The Owlet Balance",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: walletcolor,
                                                      ),
                                                    ),
                                                    Text(
                                                      "\$ ${data.walletData['response']['user']['walletAmount']}.00",
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Image.asset(
                                                  wallet,
                                                  height: 45,
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 30,
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.90,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Add Money to ",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              Text(
                                                "The Owlet Wallet",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.red,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                        ),
                                        WalletField(
                                            MediaQuery.of(context).size.width *
                                                0.90,
                                            "",
                                            _Walletcontroller, (value) {
                                          setState(() {
                                            amount = value;
                                          });
                                        }),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        SizedBox(
                                          height: 32,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.90,
                                          child: ListView.builder(
                                              padding: EdgeInsets.zero,
                                              scrollDirection: Axis.horizontal,
                                              itemCount: Amounts.length,
                                              itemBuilder: (context, index) {
                                                bool checked =
                                                    index == sellectedindex;
                                                return InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      // controller:   _Walletcontroller;
                                                      amount = Amounts[index];
                                                      _Walletcontroller.text =
                                                          Amounts[index];
                                                      sellectedindex = index;
                                                    });
                                                  },
                                                  child: Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 5.5),
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.5)),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(40)),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 5,
                                                          horizontal: 20),
                                                      child: Center(
                                                        child: Text("\$ " +
                                                            Amounts[index]),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                        ),
                                        SizedBox(
                                          height: 30,
                                        ),
                                        isloading
                                            ? Loading(message: 'Authenticating')
                                            : bottomsheetbutton(
                                                text:
                                                    'Proceed to add \$ ${amount == null ? "00.00" : amount.toString() + ".00"}',
                                                press: doAdd
                                                //     () async {
                                                //   Charge charge = Charge()
                                                //     ..amount =
                                                //         int.parse(amount + "00")
                                                //     ..reference =
                                                //         _getReference()
                                                //     // or ..accessCode = _getAccessCodeFrmInitialization()
                                                //     ..email =
                                                //         'helpdesk@theowlette.com';
                                                //   CheckoutResponse response =
                                                //       await plugin.checkout(
                                                //     context,
                                                //     method: CheckoutMethod
                                                //         .card, // Defaults to CheckoutMethod.selectable
                                                //     charge: charge,
                                                //   );
                                                // },
                                                ),
                                        SizedBox(
                                          height: 80,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        PassBookScreen()));
                                          },
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.90,
                                            height: 70,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                    color: Colors.grey
                                                        .withOpacity(0.4))),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 5),
                                                      child: SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.1,
                                                          height: 30,
                                                          child: Image.asset(
                                                              passbook)),
                                                    ),
                                                    SizedBox(
                                                      width: 20,
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          'Passbook',
                                                          style: TextStyle(
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.02,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                        Text(
                                                          'Check your payment from wallet',
                                                          style: TextStyle(
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.015,
                                                              color:
                                                                  Colors.grey),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.1,
                                                    height: 20,
                                                    child: Image.asset(
                                                        right_arrow))
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 80,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }

    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  Widget WalletField(
    screenWidth,
    String lable,
    controller,
    final Function(String?)? onSaved,
  ) {
    return Container(
      margin: EdgeInsets.all(5),
      width: screenWidth,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 5,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: onSaved,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              controller: controller,
              decoration: InputDecoration(
                hintText: "Enter amount",
                prefix: Text(
                  "\$ ",
                  style: TextStyle(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.grey.withOpacity(0.4), width: 1.2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.grey.withOpacity(0.4), width: 1.2),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0.0),
                ),
                isDense: true,
                contentPadding: EdgeInsets.all(12),
              ),
              onTap: () async {},
            ),
          ],
        ),
      ),
    );
  }

  // _handleCheckout(BuildContext context) async {
  //
  //
  //
  //   Charge charge = Charge()
  //     ..amount = 10000 // In base currency
  //     ..email = 'customer@email.com'
  //     ..card = _getCardFromUI();
  //
  //   charge.reference = _getReference();
  //
  //
  //   try {
  //     CheckoutResponse response = await plugin.checkout(
  //       context,
  //       method: _method,
  //       charge: charge,
  //       fullscreen: false,
  //       logo: MyLogo(),
  //     );
  //     print('Response = $response');
  //     setState(() => _inProgress = false);
  //     _updateStatus(response.reference, '$response');
  //   } catch (e) {
  //     setState(() => _inProgress = false);
  //     _showMessage("Check console for error");
  //     rethrow;
  //   }
  // }
  //
  // PaymentCard _getCardFromUI() {
  //   // Using just the must-required parameters.
  //   return PaymentCard(
  //     number: _cardNumber,
  //     cvc: _cvv,
  //     expiryMonth: _expiryMonth,
  //     expiryYear: _expiryYear,
  //   );
  //
  //   Using Cascade notation (similar to Java's builder pattern)
  //  return PaymentCard(
  //      number: cardNumber,
  //      cvc: cvv,
  //      expiryMonth: expiryMonth,
  //      expiryYear: expiryYear)
  //    ..name = 'Segun Chukwuma Adamu'
  //    ..country = 'Nigeria'
  //    ..addressLine1 = 'Ikeja, Lagos'
  //    ..addressPostalCode = '100001';
  //
  //   Using optional parameters
  //  return PaymentCard(
  //      number: cardNumber,
  //      cvc: cvv,
  //      expiryMonth: expiryMonth,
  //      expiryYear: expiryYear,
  //      name: 'Ismail Adebola Emeka',
  //      addressCountry: 'Nigeria',
  //      addressLine1: '90, Nnebisi Road, Asaba, Deleta State');
  // }
  //
  // String _getReference() {
  //   String platform;
  //   if (Platform.isIOS) {
  //     platform = 'iOS';
  //   } else {
  //     platform = 'Android';
  //   }
  //
  //   return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  // }

}
