# SoftPOS Integration Plugin

A plugin to open SoftPOS to complete payment and get payment response back from SoftPOS.

## Android Integration

1. Add queries before "application" tag in your Android Manifest file.

```
    <!-- Explicit apps you know in advance about: -->
   <queries>
        <!-- Add this if using softpos in mobile -->
        <package android:name="com.interpaymea.softpos"/>
        <!-- Add this if using softpos in szzt device -->
        <package android:name="com.interpaymea.softpos.szzt"/>
    </queries>
```

2. Add app_communication_plugin package to your pubspec.yaml file with latest version.

3. Add import statement to your dart file

```
import 'package:app_communication_plugin/app_communication_plugin.dart';
```

4. To open softpos app, add below code

```
  void openSoftposApp() async {

    Map<String, dynamic> data = {};
    data.addAll({
      "amount": "123.00",    // required
      "paymentApp" : "softpos" // required => #if you are running your app in SZZT device, then replace "softpos" to "softpos_szzt"
    });

    var response = await AppCommunicationPlugin.openSoftposApp(
      data,
      TransactionTypesToPay.Sale,
    );

  }
```

Note :- Add "amount" field in map to pass data.
Also note that please keep the precision of amount by two digits after dot.
Also add 2nd parameter as Transaction type.

5. You will get JSON response with following data, you can convert that into a model :-

```
isFailed
status
responseCode
message
rrNumber
approvalCode
cashBackAmount
de55Response
txnAmount
cardSequenceNumber
txnId
deviseSerialNo
serverDatetime
txnDate
txnMode
txnType
subTxnType
cardType
localReferenceNumber
isTerminalUpdateAvailable
isForceReconciliation
cardSchemeName
maskedCardNumber
```

## IOS Integration

1. Add below lines in your Info.plist file

```
  <key>LSApplicationQueriesSchemes</key>
    <array>
         <string>interpaymeasoftpos</string>    // keep this string as it, otherwise your app will not be able to SoftPOS app
    </array>
	<key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleTypeRole</key>
			<string>Editor</string>
			<key>CFBundleURLName</key>
			<string>YOUR_BUNDLE_IDENTIFIER</string>    // add your bundle identifier here
			<key>CFBundleURLSchemes</key>
			<array>
				<string>YOUR_URL_SCHEME</string>      // add your URL scheme here (it could be anything without any spaces and special characters. eg. integrationpluginexample)
			</array>
		</dict>
	</array>
```

Step 2 and 3 same as Android.

4. To open softpos app in ios, add below code

```
  void openSoftposApp() async {

    Map<String, dynamic> data = {};
    data.addAll({
        "amount": "123.00",
        "bundleUrlSchemeName": "integrationpluginexample",    // required => #add this parameter for IOS
      });

    var response = await AppCommunicationPlugin.openSoftposApp(
      data,
      TransactionTypesToPay.Sale,
    );

  }
```

Note :- Add "amount" and "bundleUrlSchemeName" field in map to pass data. Where "bundleUrlSchemeName" is the CFBundleURLSchemes of your app, which you have defined in Step 1. Please pass this parameter without fail.
Also note that please keep the precision of amount by two digits after dot.
Also add 2nd parameter as Transaction type.

#### If you dont add "CFBundleURLSchemes" in Info.plist file OR If you dont pass "bundleUrlSchemeName" or if you pass wrong "bundleUrlSchemeName" then SoftPOS will unable to send data back to your application.

5. You will get same response when payment will be completed and will return to app.

6. Please set your IOS version minimum to 10.1

## Error Handle

Exceptions will be thrown in below cases. So when you call openSoftposApp, then add it inside try catch bloc.

1. If no data is received, then it will send null in that case.
2. If user presses back button without completing payment, it will send 400 Error with "User has cancelled the payment" error message.

## Transaction Types

1. Sale
   For Sale Transaction Types, you will need to send data as shown above.

2. CashAdvance
   For CashAdvance Transaction Types, you will need to send data as shown above.

3. PurchaseCashback
   For PurchaseCashback, data need to be send as follow.

```
  void openSoftposApp() async {
    Map<String, dynamic> data = {};

    data.addAll({
      "amount": "123.00",
       "paymentApp" : "softpos", // required => #if you are running your app in SZZT device, then replace "softpos" to "softpos_szzt"
      "cashBackAmount": "10.00",    // add this
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
  }
```

Note : cashBackAmount should not be greater than amount, otherwise it will throw assertion error

4. Refund
   For Refund, data need to be send as follow.

```
void openSoftposApp() async {
    Map<String, dynamic> data = {};

    data.addAll({
      "amount": _amount,
       "paymentApp" : "softpos", // required => #if you are running your app in SZZT device, then replace "softpos" to "softpos_szzt"
      "approvalCode": _approvalCode,
      "originalTransactionAmount": _originalAmount,
      "retrievalReferenceNumber": _retrievalReferenceNumber,
      "transactionDate": _transactionDate,
      "txnToHostId": _txnId,
      "txnType": txnType
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
  }
```

Note : For refund, you need to send all the above fields, for all this fields you will get from your transaction response. Please see example code for more information.
Send data without any change in all these fields.
