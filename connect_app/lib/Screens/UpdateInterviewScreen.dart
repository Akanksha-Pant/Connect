import 'package:connect_app/Backend/DatabaseServices.dart';
import 'package:connect_app/Models/Interview.dart';
import 'package:connect_app/Models/User.dart';
import 'package:connect_app/Utilities/AppUtilityFunctions.dart';
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
  List<User> newUsers = [];
  List<String> newParticipants = [];
  DateTime startDate;
  DateTime endDate;
  TimeOfDay startTime;
  TimeOfDay endTime;
  DateTime startDateTime;
  DateTime endDateTime;
  void findNewParticipants() async {
    await dbServices.getDummyUser().then((value) {
      setState(() {
        users = value;
      });
    });
    for (var user in users) {
      print(interview.interview_id);
      if (!interview.participants.contains(user.user_id)) {
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
              addNewParticipant();
            },
          );
        });
  }

  void addNewParticipant() async {
    await dbServices.addNewParticipants(interview, newParticipants);
  }

  void deleteParticipants() async {
    List<String> currentParticipantsId = interview.participants;
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
            onConfirm: (values) {
              values.forEach((value) {
                toBeRemoved.add(value.user_id);
              });
              dbServices.removeParticipants(interview, toBeRemoved);
            },
          );
        });
  }

  void changeTimings(){
    setState(() {
      startDateTime = new DateTime(startDate.year, startDate.month, startDate.day, startTime.hour, startTime.minute);
      endDateTime = new DateTime(endDate.year, endDate.month, endDate.day, endTime.hour, endTime.minute);
    });
    dbServices.updateTimings(interview, startDateTime, endDateTime);
  }

  void getDatePicker(bool isStart) {
    showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2022))
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
          Row(
            children: [
              Container(
                child: Text("Start Date"),
              ),
              Container(
                child: Container(
                  child: Text(
                    startDate == null ? "" : startDate.toString(),
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
            children: [
              Container(
                child: Text("Start time"),
              ),
              Container(
                child: Container(
                    child: Text(startTime == null ? "" : startTime.toString())),
              ),
              IconButton(
                  onPressed: () {
                    getTimePicker(true);
                  },
                  icon: Icon(Icons.access_time_outlined))
            ],
          ),
          Row(
            children: [
              Container(
                child: Text("End Date"),
              ),
              Container(
                child: Container(
                    child: Text(
                  endDate == null ? "" : endDate.toString(),
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
            children: [
              Container(
                child: Text("End time"),
              ),
              Container(
                child: Container(
                    child: Text(endTime == null ? "" : endTime.toString())),
              ),
              IconButton(
                  onPressed: () {
                    getTimePicker(false);
                  },
                  icon: Icon(Icons.access_time_outlined))
            ],
          ),
          Row(
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
            children: [
              ElevatedButton(onPressed: (){changeTimings();}, child: Text("Change Timing"))
            ],
          )
        ],
      ),
    );
  }
}
