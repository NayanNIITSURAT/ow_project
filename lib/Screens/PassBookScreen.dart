import 'dart:async';
import 'dart:html';
import 'package:file_saver/file_saver.dart';
import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:owlet/Components/Loading.dart';
import 'package:owlet/Widgets/PullToRefresh.dart';
import 'package:provider/provider.dart';

import '../../Widgets/SettingsBar.dart';
import '../../constants/palettes.dart';
import '../Components/Toast.dart';
import '../models/passbooknotifier.dart';

class PassBookScreen extends StatefulWidget {
  const PassBookScreen({Key? key}) : super(key: key);

  @override
  State<PassBookScreen> createState() => _PassBookScreenState();
}

class _PassBookScreenState extends State<PassBookScreen> {
  bool isloadingstate = true;
  final List<String> labels = ["No", "Title", "Date and time", "Amount"];

  @override
  void initState() {
    final data = Provider.of<passbooknotifier>(context, listen: false);
    data.fetchData(context);
    Timer(Duration(seconds: 3), () async {
      setState(() {
        isloadingstate = false;
      });
    });
    super.initState();
  }

  Future<void> _pullRefresh(refresh) async {
    if (refresh == true) {
      CupertinoActivityIndicator();

      final data = Provider.of<passbooknotifier>(context, listen: false);
      await data.fetchData(context);
    }
  }

  String formatISOTime(DateTime date) {
    date = date.toUtc();
    final convertedDate = date.toLocal();
    String formated_date = "";

    formated_date = (DateFormat("dd MMM,h:mm a").format(convertedDate));
    return formated_date;
    // var duration = date.timeZoneOffset;
    // if (duration.isNegative) {
    //   fstring = (DateFormat("dd MMM , HH:mm a").format(date) +
    //       "-${duration.inHours.toString().padLeft(2, '0')}${(duration.inMinutes - (duration.inHours * 60)).toString().padLeft(2, '0')}");
    //   String result = fstring.replaceAll("+0000", " ");
    //
    //   return result;
    // } else {
    //   fstring = (DateFormat("dd MMM , HH:mm a").format(date) +
    //       "+${duration.inHours.toString().padLeft(2, '0')}${(duration.inMinutes - (duration.inHours * 60)).toString().padLeft(2, '0')}");
    //   String result = fstring.replaceAll("+0000", " ");
    //   return result;
    // }
  }

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<passbooknotifier>(context);
    print("sampledata" + data.toString());
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
                      child: Text("Loading Passbook data..!",
                          style: TextStyle(
                              decoration: TextDecoration.none,
                              color: Colors.black,
                              fontSize: 20)))
                ],
              ),
            ),
          )
        : SettingsBar(
            trailing: true,
            isappbar: true,
            Title: "Passbook",
            trailingTap: () {
              downLoadExcel(data.pmodel['response'], "passbooklist");
            },
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05),
              child: ScrollConfiguration(
                behavior: ScrollBehavior().copyWith(overscroll: false),
                child: PullToLoad(
                  refresh: () => _pullRefresh(true),
                  load: () => _pullRefresh(false),
                  child: ListView.builder(
                      itemCount: data.pmodel['response'].length,
                      itemBuilder: (context, index) {
                        return Container(
                          height: 60,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.withOpacity(0.5),
                              ),
                            ),
                          ),
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data.pmodel['response']['$index']
                                                ['message'] ==
                                            null
                                        ? "-"
                                        : data.pmodel['response']['$index']
                                            ['message'],
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    formatISOTime(DateTime.parse(
                                        data.pmodel['response']['$index']
                                            ['createdAt'])),
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.withOpacity(0.8)),
                                  ),
                                ],
                              ),
                              Text(
                                "${data.pmodel['response']['$index']['transactionType'] == "credit" ? "+" : "-"}" +
                                    " \$ " +
                                    "${data.pmodel['response']['$index']['amount']}.00"
                                        .toString() +
                                    " ${data.pmodel['response']['$index']['transactionType'] == "credit" ? "Cr" : "Dr"}",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: data.pmodel['response']['$index']
                                                ['transactionType'] ==
                                            "credit"
                                        ? Colors.green
                                        : kErrorColor),
                              ),
                            ],
                          ),
                        );
                      }),
                ),
              ),
            ),
          );
  }

  downLoadExcel(pdata, String name) async {
    List<List<String>> csvList = [];
    csvList.add(labels);
    for (int i = 0; i < pdata.length; i++) {
      var date =
          formatISOTime(DateTime.parse(pdata[i.toString()]['createdAt']));
      List<String> dataList = [
        i.toString(),
        pdata[i.toString()]['transactionType']!,
        date,
        pdata[i.toString()]['amount'].toString(),
      ];
      csvList.add(dataList);
    }

    String csvData = ListToCsvConverter().convert(csvList);

    Uint8List obj = Uint8List.fromList(csvData.codeUnits);
    MimeType type = MimeType.CSV;
    var str =
        await FileSaver.instance.saveFile(name, obj, "csv", mimeType: type);
    if (str != null)
      Toast(
        context,
        message: 'File created sucessfully on $str',
        type: ToastType.SUCCESS,
      ).showTop();
  }
}
