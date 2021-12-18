import 'package:connect_app/Screens/BookInterviewScreen.dart';
import 'package:connect_app/Screens/ViewInterviews.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(

            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.timer)),
                Tab(icon: Icon(Icons.calendar_today)),
              ],
            ),
            title: const Text('Connect'),
          ),
          body: TabBarView(children:
          [
            BookInterview(),
            ViewInterviewScreen(),

          ]),
        ),
      ),
    );
  }
}
