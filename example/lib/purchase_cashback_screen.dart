import 'dart:developer';
import 'dart:io';

import 'package:app_communication_plugin/app_communication_plugin.dart';
import 'package:app_communication_plugin/enums/transaction_type.dart';
import 'package:flutter/material.dart';

class PurchaseCashbackScreen extends StatefulWidget {
  const PurchaseCashbackScreen({Key? key}) : super(key: key);

  @override
  State<PurchaseCashbackScreen> createState() => _PurchaseCashbackScreenState();
}

class _PurchaseCashbackScreenState extends State<PurchaseCashbackScreen> {
  String _amount = "";
  String _cashbackAmount = "";
  String _response = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("PurchaseCashback"),
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
                  cashbackTextField(),
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

  Widget cashbackTextField() {
    return TextField(
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        hintText: "Enter cashback amount",
      ),
      onChanged: (value) {
        _cashbackAmount = value;
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
    if (_cashbackAmount == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter cashback amount")),
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
        "cashBackAmount": _cashbackAmount,
        "paymentApp": "softpos_szzt",
      });

      if (Platform.isIOS) {
        data.addAll({
          "bundleUrlSchemeName": "integrationpluginexample",
        });
      }

      var response = await AppCommunicationPlugin.openSoftposApp(
        data,
        TransactionTypesToPay.PurchaseCashBack,
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
