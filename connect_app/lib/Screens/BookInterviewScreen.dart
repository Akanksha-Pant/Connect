import 'package:flutter/material.dart';


class BookInterview extends StatefulWidget {
  @override
  _BookInterviewState createState() => _BookInterviewState();
}

class _BookInterviewState extends State<BookInterview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  SingleChildScrollView(
        child: Column(
          children: [
            ElevatedButton(onPressed: (){}, child: Container(child:  Text("Create"),))
          ],
        ),
      ),
    );
  }
}
