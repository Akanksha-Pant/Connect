import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect_app/Models/Interview.dart';


class User{

  String _name = "";
  String _email_Id = "";
  String _user_Id = "";

  User({String name, String email_id, String user_id}){
      this._name = name;
      this._email_Id = email_id;
      this._user_Id = user_id;
  }

  factory User.fromFireStore(Map<dynamic, dynamic> json){
    return User(
        name: json["name"],
        email_id :json["email_Id"],
        user_id: json["user_id"],
    );
  }

  String get name => _name;

  String get email_id => _email_Id;

  String get user_id => _user_Id;
}

