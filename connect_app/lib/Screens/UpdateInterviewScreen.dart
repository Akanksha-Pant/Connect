import 'package:connect_app/Backend/DatabaseServices.dart';
import 'package:connect_app/Components/BookInterviewHeader.dart';
import 'package:connect_app/Models/Interview.dart';
import 'package:connect_app/Models/User.dart';
import 'package:connect_app/Utilities/AppUtilityFunctions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/dialog/mult_select_dialog.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class UpdateInterviewPage extends StatefulWidget {
  Interview interview;
  UpdateInterviewPage(this.interview);
  @override
  _UpdateInterviewPageState createState() =>
      _UpdateInterviewPageState(interview);
}

class _UpdateInterviewPageState extends State<UpdateInterviewPage> {
  Interview interview;
  _UpdateInterviewPageState(this.interview);
  DatabaseServices dbServices = new DatabaseServices();
  List<User> users = [];

  DateTime startDate;
  DateTime endDate;
  TimeOfDay startTime;
  TimeOfDay endTime;
  DateTime startDateTime;
  DateTime endDateTime;


  void findNewParticipants() async {
    List<User> newUsers = [];
    List<String> newParticipants = [];
    Interview currInterviewStatus;
    await dbServices.getInterviewById(interview.interview_id).then((value) {
      currInterviewStatus = value;
    });
    await dbServices.getUserList().then((value) {
      setState(() {
        users = value;
      });
    });
    for (var user in users) {
      if (!currInterviewStatus.participants.contains(user.user_id)) {
        newUsers.add(user);
      }
    }
    ;
    await showDialog(
        context: context,
        builder: (ctx) {
          return MultiSelectDialog(
            items: newUsers.map((e) => MultiSelectItem(e, e.name)).toList(),
            onConfirm: (values) {
              values.forEach((value) {
                newParticipants.add(value.user_id);
              });
              addNewParticipant(newParticipants);
            },
          );
        });
  }

  void addNewParticipant(List<String> newParticipants) async {
    String error = "";
    bool isUpdated = true;
    try{
      await dbServices.check(interview, true);
    }catch(e){
      isUpdated = false;
      error = e;
    }
    finally{
      if(isUpdated){
        await dbServices.addNewParticipants(interview, newParticipants);
      }else{
        showDialog(context: context, builder: (ctx){
          return AlertDialog(content: Text(error),);
        });
      }

    }

  }

  void deleteParticipants() async {
    List<String> currentParticipantsId;
    await dbServices.getInterviewById(interview.interview_id).then((value) {
      currentParticipantsId = value.participants;
    });
    List<User> currentParticipants = [];
    List<String> toBeRemoved = [];
    for (String id in currentParticipantsId) {
      await dbServices.getUserbyId(id).then((value) {
        currentParticipants.add(value);
      });
    }
    await showDialog(
        context: context,
        builder: (ctx) {
          return MultiSelectDialog(
            items: currentParticipants
                .map((e) => MultiSelectItem(e, e.name))
                .toList(),
            onConfirm: (values) async{
              values.forEach((value) {
                toBeRemoved.add(value.user_id);
              });
              bool isUpdated = false;
              String Error = "Items deleted SucessFully";

              try {
                Interview currNewinterview;
                await dbServices.getInterviewById(interview.interview_id).then((value) {
                  currNewinterview = value;
                });
                await dbServices.removeParticipants(currNewinterview, toBeRemoved);
              }
              catch(e){
                Error = e.errMsg();
              }
              finally{
                showDialog(context: context, builder: (ctx){
                  return AlertDialog(content: Text(Error),);
                });
              }
            },
          );
        });
  }

  void changeTimings() async{
    setState(() {
      startDateTime = new DateTime(startDate.year, startDate.month, startDate.day, startTime.hour, startTime.minute);
      endDateTime = new DateTime(endDate.year, endDate.month, endDate.day, endTime.hour, endTime.minute);
    });
    String error = "";
    bool isUpdating = true;
    try{
      await dbServices.check(interview, true);
    } catch(e){
      error = e.errMsg();
      isUpdating = false;
    }
    finally{
      if(isUpdating){
        await dbServices.updateTimings(interview, startDateTime, endDateTime);
      }
      else{
        showDialog(context: context, builder: (ctx){
          return AlertDialog(
            content: Text(error),
          );
        });
      }
    }

  }

  void getDatePicker(bool isStart) {
    showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2023))
        .then((date) {
      setState(() {
        if (isStart) {
          startDate = date;
        } else {
          endDate = date;
        }
        print(date);
      });
    });
  }

  void getTimePicker(bool isStart) {
    showTimePicker(context: context, initialTime: TimeOfDay.now()).then((time) {
      setState(() {
        if (isStart) {
          startTime = time;
        } else {
          endTime = time;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Update Interviews"),),
      body: ListView(
        children: [
          PageHeader("assets/ListHeader.png", true),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Text("Start Date"),
              ),
              Container(
                child: Container(
                  child: Text(
                      startDate == null ? "" : startDate.day.toString() + "-" + startDate.month.toString() + "-" + startDate.year.toString()
                  ),
                ),
              ),
              IconButton(
                  onPressed: () {
                    getDatePicker(true);
                  },
                  icon: Icon(Icons.calendar_today_rounded))
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Text("Start time"),
              ),
              Container(
                child: Container(
                    child:  Text(startTime == null ? "" : startTime.hour.toString() + " : " + startTime.minute.toString())),
              ),
              IconButton(
                  onPressed: () {
                    getTimePicker(true);
                  },
                  icon: Icon(Icons.access_time_outlined))
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Text("End Date"),
              ),
              Container(
                child: Container(
                    child: Text(
                        endDate == null ? "" : endDate.day.toString() + "-" + endDate.month.toString() + "-" + endDate.year.toString()
                )),
              ),
              IconButton(
                  onPressed: () {
                    getDatePicker(false);
                  },
                  icon: Icon(Icons.calendar_today_rounded))
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Text("End time"),
              ),
              Container(
                child: Container(
                    child:  Text(endTime == null ? "" : endTime.hour.toString() + " : " + endTime.minute.toString())),
              ),
              IconButton(
                  onPressed: () {
                    getTimePicker(false);
                  },
                  icon: Icon(Icons.access_time_outlined))
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                  onPressed: () {
                    findNewParticipants();
                  },
                  child: Text("Add Participants")),
              ElevatedButton(
                  onPressed: () {
                    deleteParticipants();
                  },
                  child: Text("Remove Participants"))
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(onPressed: (){changeTimings();}, child: Text("Change Timing"))
            ],
          )
        ],
      ),
    );
  }
}
