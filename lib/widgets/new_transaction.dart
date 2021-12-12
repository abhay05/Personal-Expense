import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:personal_expense/widgets/adaptive_flatButton.dart';

class NewTransaction extends StatefulWidget {
  final Function addTransaction;
  NewTransaction({this.addTransaction});

  @override
  _NewTransactionState createState() => _NewTransactionState();
}

class _NewTransactionState extends State<NewTransaction> {
  TextEditingController titleController = new TextEditingController();
  TextEditingController amountController = new TextEditingController();
  DateTime _selectedDate;

  void submitTxs() {
    if (amountController.text.isEmpty) {
      return; // to avoid error if empty amount is submitted
    }
    String title = titleController.text;
    double amount = double.parse(amountController.text);
    if (title.isEmpty || amount <= 0 || _selectedDate == null) {
      return;
    }
    widget.addTransaction(title, amount, _selectedDate);
    // widget gives access to class and it's properties
    Navigator.of(context).pop();
    //context is context related to widget
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      // function in then is stored in memory and called only when user selects something
      // this means app is not blocked just bcz user has not select anything. print statement below will
      // run in any case.
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
      });
    });
    print(
        "..."); // this is the print statement which talked about in above comment
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        elevation: 5,
        child: Container(
          padding: EdgeInsets.only(
              top: 10,
              left: 10,
              right: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom + 10
              // MediaQuery.of(context).viewInsets.bottom -> to get the space occupied by
              // the keyboard at the bottom
              ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                decoration: InputDecoration(labelText: "Title"),
                controller: titleController,
                onSubmitted: (_) =>
                    submitTxs(), // we are passing reference to an anyonymous functoin
              ),
              TextField(
                decoration: InputDecoration(labelText: "Amount"),
                controller: amountController,
                keyboardType: TextInputType.number,
                onSubmitted: (_) =>
                    submitTxs(), // we are passing reference to an anyonymous functoin
              ),
              Container(
                //padding: EdgeInsets.symmetric(vertical: 10),
                height: 70, // for vertical spacing
                child: Row(
                  children: [
                    Expanded(
                      // to push button to the right and get as much space as possible
                      child: Text(_selectedDate == null
                          ? "No Date chosen"
                          : DateFormat.yMMMd().format(_selectedDate)),
                    ),
                    AdaptiveFlatButton(
                        text: "Choose Date", handler: _presentDatePicker),
                  ],
                ),
              ),
              RaisedButton(
                onPressed: submitTxs, // no wrapping anonymous function
                child: Text("Submit"),
                color: Theme.of(context).primaryColor,
                textColor: Theme.of(context).textTheme.button.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
