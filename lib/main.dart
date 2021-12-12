import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:personal_expense/widgets/new_transaction.dart';
import 'package:flutter/services.dart';

import 'widgets/new_transaction.dart';
import 'widgets/transaction_list.dart';
import 'widgets/chart.dart';
import 'models/transaction.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown,
  // ]);
  runApp(PersonalExpense());
}

class PersonalExpense extends StatefulWidget {
  @override
  _PersonalExpenseState createState() => _PersonalExpenseState();
}

class _PersonalExpenseState extends State<PersonalExpense> {
  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? CupertinoApp(
            title: "Personal Expenses",
            theme: CupertinoThemeData(
              primaryColor: Colors.purple,
              primaryContrastingColor: Colors.white,
              textTheme: CupertinoTextThemeData(),
            ),
            home: MyHomePage(),
          )
        : MaterialApp(
            title: "Personal Expenses",
            theme: ThemeData(
              primarySwatch: Colors.purple,
              accentColor: Colors.amber,
              textTheme: ThemeData.light().textTheme.copyWith(
                    button: TextStyle(color: Colors.white),
                  ),
            ),
            home: MyHomePage(),
          );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  final List<Transaction> _userTransactions = [
    // Transaction(id: "t1", title: "CHART!", amount: 23.4, date: DateTime.now()),
    // Transaction(
    //     id: "t2", title: "LIST OF TX", amount: 1.0, date: DateTime.now())
  ];

  @override
  void initState() {
    WidgetsBinding.instance
        .addObserver(this); // whenever lifecyle changes go to this observer
    // and call didChangeAppLifeCycleState
    // this class itself is a observer
    // that's why we defined didChangeLifeCycleState here
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //print("Hello");
    print(state);
  }

  @override
  dispose() {
    WidgetsBinding.instance.removeObserver(
        this); // to clear all the listeners to WidgetsBindingObserver
    // after state is deleted otherwise it will consume memory.
    // currentyly this is the listener
    super.dispose();
  }

  List<Transaction> get _recentTransactions {
    return _userTransactions.where((tx) {
      return tx.date.isAfter(DateTime.now().subtract(
        Duration(days: 7),
      ));
    }).toList();
    //where return iterable, so use toList;
  }

  void _addTransaction(String title, double amount, DateTime selectedDate) {
    final tx = Transaction(
        title: title,
        amount: amount,
        date: selectedDate,
        id: DateTime.now().toString());
    setState(() {
      _userTransactions.add(tx);
    });
  }

  void _deleteTransaction(String id) {
    setState(() {
      _userTransactions.removeWhere((tx) => tx.id == id);
    });
  }

  void startAddingNewTransactions(BuildContext ctx) {
    showModalBottomSheet(
        context: ctx,
        builder: (bcontext) {
          return GestureDetector(
              onTap: () {}, // to catch the tap on inputs and do nothing
              behavior: HitTestBehavior
                  .opaque, // to control behaviour of the tap on underlying modal
              child: NewTransaction(addTransaction: _addTransaction));
        });
    // bcontext is a different context to the buildContext which we pass,
    // bcontext is the context of the modal sheet
  }

  bool _showChart = false;

  List<Widget> _buildsLandscapeContent(
      MediaQueryData mediaQuery, AppBar appBar, Widget txListWidget) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("Show Chart"),
          Switch.adaptive(
            value: _showChart,
            onChanged: (val) {
              setState(() {
                _showChart = val;
              });
            },
          )
        ],
      ),
      _showChart
          ? Container(
              height: (mediaQuery.size.height -
                      appBar.preferredSize.height -
                      mediaQuery.padding.top) *
                  // -mediaQuery.padding.top -> statusbar height
                  0.7,
              child: Chart(_recentTransactions),
            )
          : txListWidget,
    ];
  }

  List<Widget> _buildsPortraitContent(
      MediaQueryData mediaQuery, AppBar appBar, Widget txListWidget) {
    return [
      Container(
        height: (mediaQuery.size.height -
                appBar.preferredSize.height -
                mediaQuery.padding.top) *
            // -mediaQuery.padding.top -> statusbar height
            .3,
        child: Chart(_recentTransactions),
      ),
      txListWidget
    ];
  }

  Widget _buildAppBar(bool platform) {
    return platform
        ? CupertinoNavigationBar(
            middle: Text('Personal Expense'),
            trailing: Row(
                mainAxisSize:
                    MainAxisSize.min, // bcz row takes all the width it can get
                // so "Personal Expense" text will not be visible if it is not set to minimum
                children: <Widget>[
                  GestureDetector(
                    child: Icon(CupertinoIcons.add),
                    onTap: () => startAddingNewTransactions(context),
                  )
                ]),
          )
        : AppBar(
            title: Text('Personal Expense'),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  startAddingNewTransactions(context);
                },
              )
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final PreferredSizeWidget appBar = _buildAppBar(Platform.isIOS);
    final txListWidget = Container(
      height: (mediaQuery.size.height -
              appBar.preferredSize.height -
              // error bcz flutter is unable to identify if cupertino has preferredSize property
              // so we need to explicitly defined type for the appBar, in this case it is
              // PreferredSizeWidget
              mediaQuery.padding.top) *
          0.7,
      child: TransactionList(
          transactions: _userTransactions,
          deleteTransaction: _deleteTransaction),
    );
    final pageBody = SafeArea(
      child: SingleChildScrollView(
        child: Column(children: [
          if (isLandscape)
            ..._buildsLandscapeContent(mediaQuery, appBar, txListWidget),
          if (!isLandscape)
            ..._buildsPortraitContent(mediaQuery, appBar, txListWidget),
        ]),
      ),
    ); //safeArea widget makes sure we respect the space reserved on both IOS  and android
    // that ensures that our ui looks the way we wanted.
    return Platform.isIOS
        ? CupertinoPageScaffold(
            child: pageBody,
            navigationBar: appBar,
          )
        : Scaffold(
            appBar: appBar,
            body: pageBody,
            floatingActionButton: Platform.isIOS
                ? Container()
                : FloatingActionButton(
                    child: Icon(Icons.add),
                    onPressed: () => startAddingNewTransactions(context),
                  ),
          );
  }
}
