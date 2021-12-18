import 'package:connect_app/Backend/DatabaseServices.dart';
import 'package:connect_app/Models/Interview.dart';
import 'package:connect_app/Screens/UpdateInterviewScreen.dart';
import 'package:connect_app/Utilities/AppStrings.dart';
import 'package:flutter/material.dart';

class ViewInterviewScreen extends StatefulWidget {
  @override
  _ViewInterviewScreenState createState() => _ViewInterviewScreenState();
}

class _ViewInterviewScreenState extends State<ViewInterviewScreen> {
  List<Interview> interviewsList = [];
  DatabaseServices dbServices = new DatabaseServices();

  @override
  void initState()  {
    super.initState();
    getInterviewList();

    //print(interviewsList);
  }
  void getInterviewList() async{
    await dbServices.getInterviews(AppStrings().ADMIN_USER_ID).then((value) async{
      await setState(() {
        interviewsList = value;
      });
    });
  }



  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: interviewsList.length,
        itemBuilder: (context, index){
      return InterviewCard(interviewsList[index]);
    });
  }
}



class InterviewCard extends StatelessWidget {
  Interview interview;
  InterviewCard(this.interview);
  @override
  Widget build(BuildContext context) {
    return Container(child:  ElevatedButton(onPressed: (){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UpdateInterviewPage(interview)),
      );
    },child: Text(interview.title),),);
  }
}
