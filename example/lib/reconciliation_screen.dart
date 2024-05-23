import 'dart:developer';
import 'dart:io';

import 'package:app_communication_plugin/app_communication_plugin.dart';
import 'package:app_communication_plugin/enums/transaction_type.dart';
import 'package:flutter/material.dart';

class ReconciliationScreen extends StatefulWidget {
  const ReconciliationScreen({Key? key}) : super(key: key);

  @override
  State<ReconciliationScreen> createState() => _ReconciliationScreenState();
}

class _ReconciliationScreenState extends State<ReconciliationScreen> {
  String _response = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Reconciliation"),
        ),
        body: buildBody());
  }

  Widget buildBody() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _response != "" ? Text(_response.toString()) : Container(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          chargeButton(),
        ],
      ),
    );
  }

  Widget chargeButton() {
    return ElevatedButton(
      onPressed: () {
        onChargeButtonPressed();
      },
      child: const Text("Charge"),
      style: ButtonStyle(
        fixedSize: MaterialStateProperty.all(Size(MediaQuery.of(context).size.width, 40)),
      ),
    );
  }

  // methods

  void onChargeButtonPressed() {
    openSoftposApp();
  }

  void openSoftposApp() async {
    try {
      Map<String, dynamic> data = {};

      data.addAll({
        "paymentApp": "softpos",//optional
      });

      if (Platform.isIOS) {
        data.addAll({
          "bundleUrlSchemeName": "integrationpluginexample",
        });
      }

      var response = await AppCommunicationPlugin.openSoftposApp(
        data,
        TransactionTypesToPay.Reconciliation,
      );
      if (response != null) {
        log("Response :: " + response.toString());
        _response = response.toString();
        setState(() {});
      }
    } catch (error) {
      _response = error.toString();
      setState(() {});
    }
  }
}
