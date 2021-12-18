import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect_app/Backend/DatabaseServices.dart';
import 'package:connect_app/Screens/BookInterviewScreen.dart';
import 'package:connect_app/Screens/HomePage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'Models/User.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(HomePage());
}

