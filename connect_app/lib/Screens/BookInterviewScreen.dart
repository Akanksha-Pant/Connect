import 'package:connect_app/Backend/DatabaseServices.dart';
import 'package:connect_app/Models/Interview.dart';
import 'package:connect_app/Models/User.dart';
import 'package:connect_app/Utilities/AppUtilityFunctions.dart';
import 'package:flutter/material.dart';


class BookInterview extends StatefulWidget {
  @override
   List<String> selectedUsers  = [];
   BookInterview({this.selectedUsers});
  _BookInterviewState createState() => _BookInterviewState(participantList: selectedUsers);
}

class _BookInterviewState extends State<BookInterview> {
  @override
  DateTime startDateTime;
  DateTime endDateTime;
  DateTime startDate;
  DateTime endDate;
  TimeOfDay startTime;
  TimeOfDay endTime;
  List<String> participantList = [];
  DatabaseServices dbServices = new DatabaseServices();

  _BookInterviewState({this.participantList});
  void getDatePicker(bool isStart){
    showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2022)).then((date) {
      setState(() {
        if(isStart){
          startDate = date;
        }
        else{
          endDate = date;
        }
        print(date);
      });
    } );
  }

  void getTimePicker(bool isStart){
    showTimePicker(context: context,initialTime: TimeOfDay.now()).then((time) {
      setState(() {
        if(isStart){
          startTime = time;
        }
        else{
          endTime = time;
        }

      });
    });
  }

  void submit(DateTime startdate, DateTime endDate , TimeOfDay startTime, TimeOfDay endTime){
    setState(() {
      startDateTime = new DateTime(startdate.year, startdate.month, startdate.day, startTime.hour, startTime.minute);
      endDateTime = new DateTime(endDate.year, endDate.month, endDate.day, endTime.hour, endTime.minute);
    });
    if(startDateTime.isAfter(endDateTime)){
      showDialog(context: context, builder: (ctx) => AlertDialog(
        title: Text("Oops"),
        content: Text("Hey your start time and date should be before your end time and date"),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text("okay"),
          ),
        ],
      ));

    }
    String interviewId = AppUtilityFunctions().getInterviewId(startDateTime, endDateTime, "1a");
    dbServices.addInterview(new Interview(startTime: startDateTime, endTime: endDateTime, interviewId: interviewId, admin: "1a", participants: participantList));
    print(startDateTime);
    print(endDateTime);
  }
  Widget build(BuildContext context) {
    return Scaffold(
      body:  SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Container(child:  Text("Start Date"),),
                Container(child:  Container(child: Text( startDate == null ? "" : startDate.toString(),),),),
                IconButton(onPressed: (){
                  getDatePicker(true);
                }, icon: Icon(Icons.calendar_today_rounded))
              ],
            ),
            Row(
              children: [
                Container(child:  Text("Start time"),),
                Container(child:  Container(child : Text(startTime == null ? "" : startTime.toString())),),
                IconButton(onPressed: (){getTimePicker(true);}, icon: Icon(Icons.access_time_outlined))
              ],
            ),
            Row(
              children: [
                Container(child:  Text("End Date"),),
                Container(child:  Container(
                    child: Text( endDate == null ? "" : endDate.toString(),)
                ),),
                IconButton(onPressed: (){getDatePicker(false);}, icon: Icon(Icons.calendar_today_rounded))
              ],
            ),
            Row(
              children: [
                Container(child:  Text("End time"),),
                Container(child:  Container(child : Text(endTime == null ? "" : endTime.toString())),),
                IconButton(onPressed: (){getTimePicker(false);}, icon: Icon(Icons.access_time_outlined))
              ],
            ),
            ElevatedButton(onPressed: (){}, child: Text("Add Participants")),
            ElevatedButton(onPressed: (){
              submit(startDate, endDate, startTime, endTime);
            }, child: Text("Submit"))
          ],
        ),
      ),
    );
  }
}
