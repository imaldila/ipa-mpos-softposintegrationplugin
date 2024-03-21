// ignore_for_file: unnecessary_null_comparison

import 'dart:async';
import 'dart:developer';

import 'package:app_communication_plugin/enums/transaction_type.dart';
import 'package:flutter/services.dart';

class AppCommunicationPlugin {
  static const MethodChannel _channel = MethodChannel('app_communication_plugin');
  static const MethodChannel _channelSzzt = MethodChannel('app_communication_plugin_szzt');

  static const String _errorName = "app_communication_plugin";

  /// SOFTPOS
  ///
  /// to check if it is open from another app
  static Future<bool> checkSoftposOpenFromOtherApp() async {
    try {
      Map<String, dynamic>? data = await getDataReceivedInSoftpos();
      bool isAppOpen = false;
      if (data != null) {
        isAppOpen = true;
      }
      return isAppOpen;
    } catch (error) {
      log(error.toString(), name: _errorName);
      rethrow;
    }
  }

  /// SOFTPOS
  ///
  /// to throw any error from Softpos
  static Future<void> throwErrorFromSoftpos(String errorCode, String errorMessage, String errorDetails) async {
    try {
      Map<String, dynamic> responseData = {};
      responseData.addAll({"errorCode": errorCode, "errorMessage": errorMessage, "errorDetails": errorDetails});

      await _channel.invokeMethod("throwErrorFromSoftpos", responseData);
    } catch (error) {
      rethrow;
    }
  }

  /// SOFTPOS
  ///
  /// method used to get all the data that is received from another app
  static Future<Map<String, dynamic>?> getDataReceivedInSoftpos() async {
    try {
      var data = await _channel.invokeMethod("getDataReceivedInSoftpos");
      log("---- Data received in softpos : " + data.toString());

      if (data != null) {
        // CommunicationRequestData commData = CommunicationRequestData.fromJson(Map<String, dynamic>.from(data));
        return Map<String, dynamic>.from(data);
      }
      return null;
    } catch (error) {
      log("Some error in getting data received. " + error.toString(), name: _errorName);
      rethrow;
    }
  }

  /// SOFTPOS
  ///
  /// need to use when data to be sent back from SOFTPOS to called app
  static Future<void> sendDataBackToSource(Map<String, dynamic>? responseData, bool isFailed) async {
    try {
      log("Response data : " + responseData.toString());
      if (responseData == null) {
        await _channel.invokeMethod("sendDataBackToSource", null);
      } else {
        responseData.addAll({"isFailed": isFailed});
        await _channel.invokeMethod("sendDataBackToSource", responseData);
      }
    } catch (error) {
      log("Some error in sending data back from softpos. " + error.toString(), name: _errorName);
      rethrow;
    }
  }

  /// except SOFTPOS
  ///
  /// use this method from another app to open softpos app and to wait for the result to come from softpos
  /// request parameters => amount
  static Future<Map<String, dynamic>?> openSoftposApp(Map<String, dynamic> requestData, TransactionTypesToPay transactionType) async {
    try {
      assert(requestData["amount"] != null, "amount must not be null");
      assert(double.tryParse(requestData["amount"].toString()) != null, "Unable to parse amount");
      double amount = double.parse(requestData["amount"].toString());

      // if type is cashback
      if (transactionType == TransactionTypesToPay.PurchaseCashBack) {
        assert(requestData["cashBackAmount"] != null, "cashBackAmount must not be null");
        assert(double.tryParse(requestData["cashBackAmount"].toString()) != null, "Unable to parse amount");
        double cashBackAmount = double.parse(requestData["cashBackAmount"].toString());
        assert(cashBackAmount < amount, "cashBackAmount must not be greater than amount");
        // requestData.addAll({"cashBackAmount": cashBackAmount.toStringAsFixed(2)});
        requestData["cashBackAmount"] = cashBackAmount.toStringAsFixed(2);
      }

      if (transactionType == TransactionTypesToPay.Refund) {
        assert(requestData["approvalCode"] != null, "approvalCode must not be null");
        assert(requestData["originalTransactionAmount"] != null, "originalTransactionAmount must not be null");
        assert(requestData["retrievalReferenceNumber"] != null, "retrievalReferenceNumber must not be null");
        assert(requestData["transactionDate"] != null, "transactionDate must not be null");
        assert(requestData["txnToHostId"] != null, "txnToHostId must not be null");
      }

      requestData["amount"] = amount.toStringAsFixed(2);

      requestData.addAll({"transaction_type": transactionType.name});
      log("Data sent : " + requestData.toString());
      // ignore: prefer_typing_uninitialized_variables
      var data;
      if (requestData["paymentApp"] == "softpos") {
        data = await _channel.invokeMethod("openSoftposApp", requestData);
      } else if (requestData["paymentApp"] == "softpos_szzt") {
        data = await _channelSzzt.invokeMethod("openSoftposApp", requestData);
      }

      // log("Data received :: " + data.toString());

      if (data != null) {
        // CommunicationResponseData? commData = CommunicationResponseData.fromJson(Map<String, dynamic>.from(data));
        return Map<String, dynamic>.from(data);
      }
      return null;
    } catch (error) {
      log("Some error in opening softpos app. " + error.toString(), name: _errorName);
      rethrow;
    }
  }
}
