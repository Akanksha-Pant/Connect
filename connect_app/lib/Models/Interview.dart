import 'package:cloud_firestore/cloud_firestore.dart';

class Interview{

  DateTime _start_time;
  DateTime _endTime;
  String _admin;
  String _interview_id;
  List<String> _participants = <String>[];

  Interview({DateTime startTime, DateTime endTime, String admin, String interviewId, List<String> participants}){
    this._start_time = startTime;
    this._endTime = endTime;
    this._admin = admin;
    this._interview_id = interviewId;
    this._participants = participants;
  }

  Map<String, dynamic> toJson (){
    return <String, dynamic>{
      "start_time" : _start_time.millisecondsSinceEpoch,
      "end_time" : _endTime.millisecondsSinceEpoch,
      "admin" :  _admin,
      "interview_id" : _interview_id,
      "participants" : _participants
    };
  }


  factory Interview.fromFireStore(Map<dynamic, dynamic> json){
    return Interview(
      startTime : DateTime.fromMillisecondsSinceEpoch(json["start_time"]) ,
      endTime : DateTime.fromMillisecondsSinceEpoch(json["end_time"]),
      admin : json["admin"],
      interviewId: json["interview_id"],
      participants: convertList(json["participants"])
    );
  }

  
  DateTime get start_time => _start_time;

  DateTime get end_time => _endTime;

  String get admin => _admin;

  String get interview_id => _interview_id;

  List<String> get participants => _participants;

  void setId(String interviewId){
    _interview_id = interviewId;
  }
}

List<String> convertList(List<dynamic> participants){
  List<String> ls = [];
  participants.forEach((participant) {
    ls.add(participant.toString());
  });
}

