import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect_app/Models/Interview.dart';


class User{

  String _name = "";
  String _email_Id = "";
  String _user_Id = "";
  List<String> _interviewIds = <String>[];

  User({String name, String email_id, String user_id, List<String> interviewIds}){
      this._name = name;
      this._email_Id = email_id;
      this._user_Id = user_id;
      this._interviewIds = interviewIds;
  }

  factory User.fromFireStore(Map<dynamic, dynamic> json){
    return User(
        name: json["name"],
        email_id :json["email_Id"],
        user_id: json["user_id"],
        interviewIds: convert(json["interviews"])
    );
  }

  String get name => _name;

  String get email_id => _email_Id;

  String get user_id => _user_Id;

  List<String> get interviewIds => _interviewIds;


}

List<String> convert(List<dynamic> ids){
  List<String> lst = [];
  ids.forEach((id) { lst.add(id.toString());});
  return lst;
}