import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import './transaction_card.dart';
import '../models/transaction.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  final Function deleteTransaction;
  TransactionList({this.transactions, this.deleteTransaction});

  @override
  Widget build(BuildContext context) {
    return transactions.isEmpty
        ? LayoutBuilder(
            builder: (ctx, constraints) {
              return Column(children: <Widget>[
                Text("No transactions added yet"),
                SizedBox(height: 10),
                Container(
                  height: 250,
                  width: 100,
                  child:
                      Image.asset('../assets/images/An.png', fit: BoxFit.cover),
                ),
              ]);
            },
          )
        : ListView.builder(
            // List view is scrollable
            itemBuilder: (context, index) {
              return TransactionCard(
                  transaction: transactions[index],
                  deleteTransaction: deleteTransaction);
            },
            itemCount: transactions.length,
          );
  }
}
