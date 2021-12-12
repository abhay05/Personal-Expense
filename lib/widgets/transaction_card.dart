import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../models/transaction.dart';

class TransactionCard extends StatelessWidget {
  const TransactionCard({
    Key key,
    @required this.transaction,
    @required this.deleteTransaction,
  }) : super(key: key);

  final Transaction transaction;
  final Function deleteTransaction;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      child: ListTile(
        leading: CircleAvatar(
          child: FittedBox(
            child: Text("\$${transaction.amount}"),
          ),
        ),
        title:
            Text(transaction.title, style: Theme.of(context).textTheme.title),
        subtitle: Text(
          DateFormat.yMMMd().format(transaction.date),
        ),
        trailing: MediaQuery.of(context).size.width > 460
            ? FlatButton.icon(
                icon: Icon(Icons.delete),
                textColor: Theme.of(context).errorColor,
                onPressed: () {
                  deleteTransaction(transaction.id);
                },
                label: Text("Delete"),
              )
            : IconButton(
                icon: Icon(Icons.delete),
                color: Theme.of(context).errorColor,
                onPressed: () {
                  deleteTransaction(transaction.id);
                  // put inside a anonymous function which will be called
                  // when the icon is pressed
                },
                // onPressed : deleteTransaction; won't work bcz we have to
                // pass argument and onPressed by default doesn't take any arguments
              ),
      ),
    );
  }
}
