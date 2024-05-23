import 'package:app_communication_plugin/enums/transaction_type.dart';
import 'package:app_communication_plugin_example/purchase_cashback_screen.dart';
import 'package:app_communication_plugin_example/reconciliation_screen.dart';
import 'package:app_communication_plugin_example/refund_screen.dart';
import 'package:app_communication_plugin_example/sale_and_cashadvance_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text("Sale Transaction"),
              onPressed: () {
                openSaleAndCashAdvanceScreen(TransactionTypesToPay.Sale);
              },
            ),
            ElevatedButton(
              child: const Text("Cash Advance Transaction"),
              onPressed: () {
                openSaleAndCashAdvanceScreen(TransactionTypesToPay.CashAdvanceSale);
              },
            ),
            ElevatedButton(
              child: const Text("Purchase Cashback Transaction"),
              onPressed: () {
                openPurchaseCashbackScreen();
              },
            ),
            ElevatedButton(
              child: const Text("Refund"),
              onPressed: () {
                openRefundScreen();
              },
            ),
            ElevatedButton(
              child: const Text("Reconciliation"),
              onPressed: () {
                openReconciliationScreen();
              },
            ),
          ],
        ),
      ),
    );
  }

  void openSaleAndCashAdvanceScreen(TransactionTypesToPay type) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return SaleAndCashAdvanceScreens(transactionTypes: type);
    }));
  }

  void openPurchaseCashbackScreen() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const PurchaseCashbackScreen();
    }));
  }

  void openRefundScreen() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const RefundScreen();
    }));
  }

  void openReconciliationScreen() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const ReconciliationScreen();
    }));
  }
}
