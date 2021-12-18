import 'package:connect_app/Models/Interview.dart';
import 'package:connect_app/Screens/UpdateInterviewScreen.dart';
import 'package:flutter/material.dart';

class InterviewCard extends StatelessWidget {
  Interview interview;
  InterviewCard(this.interview);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 0.5, color: Colors.blueGrey),
          )
      ),
      child: ListTile(
        trailing: IconButton(onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateInterviewPage(interview)),);
        }, icon:  Icon(Icons.update),),
        title: Text(interview.title),

        leading: CircleAvatar(backgroundColor: Colors.blue, radius: 60, backgroundImage: AssetImage("assets/EmployeeAvataar.png",), ),

      ),
    );
  }
}

