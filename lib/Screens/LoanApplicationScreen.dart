import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:owlet/Components/Button.dart';
import 'package:owlet/Components/Toast.dart';
import 'package:owlet/Providers/User.dart';
import 'package:owlet/Widgets/InputContainer.dart';
import 'package:owlet/Widgets/PlainTextField.dart';
import 'package:owlet/services/user.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

class LoanApplicationScreen extends StatefulWidget {
  static const routeName = '/loan-application-screen';
  @override
  _LoanApplicationScreenState createState() => _LoanApplicationScreenState();
}

class _LoanApplicationScreenState extends State<LoanApplicationScreen> {
  UserProvider? userData;
  bool loading = true;
  String reason = '';
  String emailCode = '';
  int amount = 0;

  @override
  void initState() {
    Future.delayed(Duration.zero, initData);
    super.initState();
  }

  initData() {
    userData = Provider.of<UserProvider>(context, listen: false);
    final profile = userData!.profile;
    if (profile.hasPendingLoan) {
      Toast(context, message: 'You already have an active loan process').show();
      return Navigator.pop(context);
    }
    loading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    onVerify() async {
      final data = {
        'amount': amount.toString(),
        'reason': reason.toString(),
        'emailCode': emailCode.toString(),
      };
      if (data['emailCode'].toString().length < 1 ||
          data['amount'].toString().length < 1 ||
          data['reason'].toString().length < 1)
        return Toast(context, message: 'All fields are required').show();

      loading = true;
      setState(() {});
      final res = await loanApply(data);

      Toast(
        context,
        message: res['message'],
        type: res['ok'] ? ToastType.SUCCESS : ToastType.ERROR,
      ).showTop();

      if (res['ok']) {
        userData!.profile.hasPendingLoan = true;
        Navigator.pop(context);
      }

      loading = false;
      setState(() {});
    }

    return Scaffold(
      appBar: AppBar(
        title: 'Loan Application'.text.make(),
        elevation: 0.2,
      ),
      body: ZStack(
        [
          SingleChildScrollView(
            child: VxBox(
              child: VStack([
                'Complete these few steps to apply for a business loan. Kindly note that we\'d get intouch on your registered contact detail to process your request'
                    .text
                    .semiBold
                    .make()
                    .centered(),
                HStack([
                  'Loan Details '.text.sm.gray400.make(),
                  Divider().expand(),
                ]).box.padding(EdgeInsets.only(top: 20, bottom: 10)).make(),
                HStack([
                  InputContainer(
                    label: 'Company Name',
                    child: (userData != null
                            ? userData!.profile.company!.name
                            : '')
                        .text
                        .gray400
                        .size(16)
                        .make()
                        .box
                        .padding(
                            EdgeInsets.symmetric(vertical: 15, horizontal: 8))
                        .make(),
                  ),
                ]),
                10.heightBox,
                HStack([
                  InputContainer(
                    // \$, £
                    label:
                        'Amount (${NumberFormat.currency(symbol: "₦").format(amount)})',
                    child: PlainTextField(
                      text: amount.toString(),
                      onChange: (val) => setState(() {
                        amount = val.length < 1 ? 0 : int.parse(val);
                      }),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ]),
                10.heightBox,
                HStack([
                  InputContainer(
                    label: 'Reason for loan',
                    child: TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                      onChanged: (val) => reason = val,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      minLines: 4,
                      maxLines: 5,
                    ).px8(),
                  ),
                ]),
                HStack([
                  'Verification'.text.sm.gray400.make(),
                  Divider().expand(),
                ]).box.padding(EdgeInsets.only(top: 30, bottom: 10)).make(),
                HStack([
                  InputContainer(
                    label: 'Email verification code',
                    child: TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                      onChanged: (val) => emailCode = val,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.newline,
                    ).px8(),
                    showButton: true,
                    onTapBtn: () async =>
                        await userData!.sendEmailCode(type: 'VERIFY'),
                  ),
                ]),
                10.heightBox,
                30.heightBox,
                HStack([
                  Button(
                    loading: loading,
                    text: 'APPLY',
                    press: onVerify,
                    paddingVert: 15,
                  ).expand(),
                ]),
                10.heightBox,
              ]),
            ).padding(EdgeInsets.all(15)).make(),
          ),
          if (loading)
            Container(
              child: Center(child: CupertinoActivityIndicator()),
              color: Colors.white38,
            ),
        ],
      ),
    );
  }
}
