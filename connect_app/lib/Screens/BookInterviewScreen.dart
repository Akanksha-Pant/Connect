import 'package:connect_app/Backend/DatabaseServices.dart';
import 'package:connect_app/Backend/Exceptions/IntervieweeBusyException.dart';
import 'package:connect_app/Backend/Exceptions/RequiredLengthNotFound.dart';
import 'package:connect_app/Components/BookInterviewHeader.dart';
import 'package:connect_app/Models/Interview.dart';
import 'package:connect_app/Models/User.dart';
import 'package:connect_app/Utilities/AppStrings.dart';
import 'package:connect_app/Utilities/AppUtilityFunctions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/dialog/mult_select_dialog.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';


class BookInterview extends StatefulWidget {
  @override
  _BookInterviewState createState() => _BookInterviewState();
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
  List<User> ls = [];
  String title = "";

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

  void getContactPicker() async{

    await dbServices.getUserList().then((value) {
      setState(() {
        ls = value;
      });
    });
    User toBeRemoved;
    for(var user in ls){
      if(user.user_id == AppStrings().ADMIN_USER_ID){
        toBeRemoved = user;
      }
    }
    ls.remove(toBeRemoved);
    participantList.clear();
    await showDialog(context: context, builder:(ctx){
      return MultiSelectDialog(items: ls.map((e) => MultiSelectItem(e, e.name)).toList(),onConfirm: (values){
        values.forEach((value) { participantList.add(value.user_id);});
      }, );
    });
    print(participantList);
  }

  void submit(DateTime startdate, DateTime endDate , TimeOfDay startTime, TimeOfDay endTime) async{
    setState(() {
      startDateTime = new DateTime(startdate.year, startdate.month, startdate.day, startTime.hour, startTime.minute);
      endDateTime = new DateTime(endDate.year, endDate.month, endDate.day, endTime.hour, endTime.minute);
    });
    if(startDateTime.isAfter(endDateTime)){
      await showDialog(context: context, builder: (ctx) => AlertDialog(
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
    else{
      bool canBeBooked = true;
      if(!participantList.contains(AppStrings().ADMIN_USER_ID)){
        participantList.add(AppStrings().ADMIN_USER_ID);
      }
      print(participantList);
      String error = "";
      Interview interview = new Interview(startTime: startDateTime, endTime: endDateTime, interviewId: "",
          admin: AppStrings().ADMIN_USER_ID, participants: participantList, title: title);
      try{
        await dbServices.check(interview);
      } on RequiredLengthNotFound catch(e){
        canBeBooked = false;
        error = e.errMsg();
        print(error);
      } on IntervieweeBusyException catch(e){
        canBeBooked = false;
        error = e.errMsg();
        print(e.errMsg());
      }
      finally{
        if(canBeBooked){
          await dbServices.addInterview(interview);
          showDialog(context: context, builder: (ctx){
            return AlertDialog(
              title: Text("Success"),
              content: Text("Interview successfully scheduled"),
            );
          });
        }
        else{
          showDialog(context: context, builder: (ctx){
            return AlertDialog(
              title: Text("Interview can't be scheduled"),
              content: Text(error),
            );
          });
        }
      }
      print(canBeBooked);
    }


    print(startDateTime);
    print(endDateTime);
  }
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.all(10),
      child:  SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Schedule an Interview", style:  TextStyle(fontSize: 30, fontWeight: FontWeight.bold),textAlign: TextAlign.center,)
              ],
            ),
            PageHeader("assets/interview.png", false),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(child:  Text("Start Date"),),
                Container(child:  Container(child: Text( startDate == null ? "" : startDate.toString(),),),),
                IconButton(onPressed: (){
                  getDatePicker(true);
                }, icon: Icon(Icons.calendar_today_rounded))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(child:  Text("Start time"),),
                Container(child:  Container(child : Text(startTime == null ? "" : startTime.toString())),),
                IconButton(onPressed: (){getTimePicker(true);}, icon: Icon(Icons.access_time_outlined))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(child:  Text("End Date"),),
                Container(child:  Container(
                    child: Text( endDate == null ? "" : endDate.toString(),)
                ),),
                IconButton(onPressed: (){getDatePicker(false);}, icon: Icon(Icons.calendar_today_rounded))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(child:  Text("End time"),),
                Container(child:  Container(child : Text(endTime == null ? "" : endTime.toString())),),
                IconButton(onPressed: (){getTimePicker(false);}, icon: Icon(Icons.access_time_outlined))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
              Text("Title:  "),
              SizedBox(width: 100,),
              Container(
                width: 140,
                child:   TextField(
                  onChanged: (value) {
                    setState(() {
                      this.title = value;
                    });
                  },
                ),
              )
            ],),
            ElevatedButton(onPressed: (){
              //print(participantList);
              getContactPicker();
              }, child: Text("Add Participants")),
            ElevatedButton(onPressed: (){
              submit(startDate, endDate, startTime, endTime);
            }, child: Text("Submit"))
          ],
        ),
      ),
    );
  }
}
