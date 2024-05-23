import 'dart:developer';
import 'dart:io';

import 'package:app_communication_plugin/app_communication_plugin.dart';
import 'package:app_communication_plugin/enums/transaction_type.dart';
import 'package:flutter/material.dart';

class RefundScreen extends StatefulWidget {
  const RefundScreen({Key? key}) : super(key: key);

  @override
  State<RefundScreen> createState() => _RefundScreenState();
}

class _RefundScreenState extends State<RefundScreen> {
  String _amount = "";
  String _originalAmount = "";
  String _txnId = "";
  String _retrievalReferenceNumber = "";
  String _approvalCode = "";
  String _transactionDate = "";
  String _response = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Refund"),
        ),
        body: buildBody());
  }

  Widget buildBody() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _response != "" ? Text(_response.toString()) : Container(),
                  const SizedBox(height: 12),
                  amountTextField(),
                  const SizedBox(height: 12),
                  originalAmountTextField(),
                  const SizedBox(height: 12),
                  txnIdTextField(),
                  const SizedBox(height: 12),
                  retrievalReferenceNumberTextField(),
                  const SizedBox(height: 12),
                  approvalCodeTextField(),
                  const SizedBox(height: 12),
                  transactionDateTextField(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: chargeButton(),
        ),
      ],
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

  Widget originalAmountTextField() {
    return TextField(
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        hintText: "Enter original amount",
      ),
      onChanged: (value) {
        _originalAmount = value;
      },
    );
  }

  Widget txnIdTextField() {
    return TextField(
      // keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        hintText: "Enter transaction id",
      ),
      onChanged: (value) {
        _txnId = value;
      },
    );
  }

  Widget retrievalReferenceNumberTextField() {
    return TextField(
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        hintText: "Enter retrieval reference number",
      ),
      onChanged: (value) {
        _retrievalReferenceNumber = value;
      },
    );
  }

  Widget approvalCodeTextField() {
    return TextField(
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        hintText: "Enter approval code",
      ),
      onChanged: (value) {
        _approvalCode = value;
      },
    );
  }

  Widget transactionDateTextField() {
    return TextField(
      // keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        hintText: "Transaction date (yyyy-mm-dd hh:mm:ss format)",
      ),
      onChanged: (value) {
        _transactionDate = value;
      },
    );
  }

  // methods

  void onChargeButtonPressed() {
    if (_amount == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter amount")),
      );
      return;
    }
    if (_originalAmount == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter cashback amount")),
      );
      return;
    }
    if (_txnId == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter transaction id")),
      );
      return;
    }
    if (_retrievalReferenceNumber == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter retrieval reference number")),
      );
      return;
    }
    if (_approvalCode == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter approval code")),
      );
      return;
    }
    if (_transactionDate == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter transaction date")),
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
        "approvalCode": _approvalCode,
        "originalTransactionAmount": _originalAmount,
        "retrievalReferenceNumber": _retrievalReferenceNumber,
        "transactionDate": _transactionDate,
        "txnToHostId": _txnId,
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
        TransactionTypesToPay.Refund,
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
