import 'package:connect_app/Models/User.dart';
import 'package:flutter/material.dart';


class UserCard extends StatelessWidget {
  @override
  User user;
  UserCard(this.user);
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(user.name),
    );
  }
}