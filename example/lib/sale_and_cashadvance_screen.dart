import 'dart:developer';
import 'dart:io';

import 'package:app_communication_plugin/app_communication_plugin.dart';
import 'package:app_communication_plugin/enums/transaction_type.dart';
import 'package:flutter/material.dart';

class SaleAndCashAdvanceScreens extends StatefulWidget {
  const SaleAndCashAdvanceScreens({Key? key, required this.transactionTypes}) : super(key: key);

  final TransactionTypesToPay transactionTypes;

  @override
  State<SaleAndCashAdvanceScreens> createState() => _SaleAndCashAdvanceScreensState();
}

class _SaleAndCashAdvanceScreensState extends State<SaleAndCashAdvanceScreens> {
  String _amount = "";
  String _response = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.transactionTypes.name),
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
                  amountTextField(),
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

  Widget amountTextField() {
    return TextField(
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        hintText: "Enter amount",
      ),
      onChanged: (value) {
        _amount = value;
      },
    );
  }

  // methods

  void onChargeButtonPressed() {
    if (_amount == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter amount first")),
      );
      return;
    }

    openSoftposApp();
  }

  void openSoftposApp() async {
    try {
      Map<String, dynamic> data = {};

      data.addAll({
        "amount": _amount,
        "paymentApp": "softpos",
        "industrySpecific1": "Test industry", //optional Provider name optional
        "industrySpecific2": "industry_data2", //optional
        "industrySpecific3": "specific data 3", //optional
        "industrySpecific4": "data 4", //optional
      });

      if (Platform.isIOS) {
        data.addAll({
          "bundleUrlSchemeName": "integrationpluginexample",
        });
      }

      var response = await AppCommunicationPlugin.openSoftposApp(
        data,
        widget.transactionTypes,
      );
      if (response != null) {
        log("Response :: " + response.toString());
        _response = response.toString();
        setState(() {});
      }
    } catch (error) {
      _response = error.toString();
      setState(() {});
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(error.toString()),
      //     duration: const Duration(seconds: 10),
      //   ),
      // );
    }
  }
}
