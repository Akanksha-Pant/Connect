import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect_app/Backend/Exceptions/IntervieweeBusyException.dart';
import 'package:connect_app/Backend/Exceptions/RequiredLengthNotFound.dart';
import 'package:connect_app/Models/Interview.dart';
import 'package:connect_app/Models/User.dart';
import 'package:connect_app/Utilities/AppUtilityFunctions.dart';

class DatabaseServices{

  final CollectionReference userCollection = FirebaseFirestore.instance.collection("Users");
  final CollectionReference interviewCollection = FirebaseFirestore.instance.collection("Interviews");

  //USER RELATED QUERIES

  //GETTING LIST OF EXISTING USERS FROM DATABASE
  Future<List<User>> getUserList() async{
    List<User> userList = [];
    await userCollection.get().then((value) => {
      value.docs.forEach((user) {
        userList.add(new User.fromFireStore(user.data()));
      })
    });
    return userList;
  }


  //GETTING A USER IF USER ID IS PROVIDED
  Future<User> getUserbyId(String userId) async{
    User user ;
    await userCollection.doc(userId).get().then((value) {
      user = User.fromFireStore(value.data());
    });
    return user;
  }

  //ADDING NEWLY CREATED INTERVIEW TO THE PARTICIPANT WHO WILL BE A PART OF THIS INTERVIEW
  Future<void> addInterviewIdToUserCollection(String interviewId, String userId){
    userCollection.doc(userId).update({"interviews" : FieldValue.arrayUnion([interviewId])});
  }


  //QUERIES RELATED TO INTERVIEW

  //ADDING A NEW INTERVIEW
  Future<void> addInterview(Interview interview) async{

    await interviewCollection.add(interview.toJson()).then((value) => (
        updateInterviewId(value.id.toString(), interview)
    ));
    interview.participants.forEach((participant) {
      addInterviewIdToUserCollection(interview.interview_id, participant);
    });
  }

  // UPDATING ID OF THE EXISTING INYTERVIEW
  Future<void> updateInterviewId(String docRef, Interview interview) async{
    interview.setId(docRef);
    await interviewCollection.doc(docRef).update(interview.toJson());
  }

  // GETTING LIST OF INTERVIEWS THAT ARE ALREADY SCHEDULED BY THE ADMIN
  Future<List<Interview>> getInterviews(String userId) async{
    List<String > interviewIds = [];
    List<Interview>  interviews = [];

    await userCollection.doc(userId).get().then((value){
      User user = new User.fromFireStore(value.data());
      interviewIds = user.interviewIds;
    });
    for(var interviewId in interviewIds){
      await interviewCollection.doc(interviewId).get().then((value) {
        Interview interview = new Interview.fromFireStore(value.data());
        interviews.add(interview);
        print(interview.participants.toString());
      });
    }
    return interviews;
  }

  Future<Interview> getInterviewById(String interviewId) async{
    Interview interview;
    await interviewCollection.doc(interviewId).get().then((value) {
      interview = new Interview.fromFireStore(value.data());
    });
    return interview;
  }

  // QUERIES TO UPDATE INTERVIEWS

  //ADDING NEW PARTICIPANTS TO AN EXISTING INTERVIEW
  Future<void> addNewParticipants(Interview interview, List<String> newParticipants) async{
    Interview newInterview = interview;
    newInterview.setParticipants(newParticipants);
    await check(newInterview, true);

    for(String participant in newParticipants){
      userCollection.doc(participant).update({"interviews" : FieldValue.arrayUnion([interview.interview_id])});
    }

    interviewCollection.doc(interview.interview_id).update({"participants" : FieldValue.arrayUnion(interview.participants)});
  }

  //REMOVING EXISTING PARTICIPANTS FROM INTERVIEW
  Future<void> removeParticipants(Interview interview, List<String> participantsToBeRemoved){
    if(interview.participants.length - participantsToBeRemoved.length <= 3){
      throw RequiredLengthNotFound();
    }
    interviewCollection.doc(interview.interview_id).update({"participants" : FieldValue.arrayRemove(participantsToBeRemoved)});
    participantsToBeRemoved.forEach((participantId) {
      userCollection.doc(participantId).update({"interviews" : FieldValue.arrayRemove([interview.interview_id])});
    });
  }

  //CHANGING TIMINGS OF THE INTERVIEW
  Future<void> updateTimings(Interview interview, DateTime startTime, DateTime endTime){
    interviewCollection.doc(interview.interview_id).update({"start_time" : startTime.millisecondsSinceEpoch, "end_time" : endTime.millisecondsSinceEpoch});
    print("Timings updated Successfully");

  }

  //CHECKING IF THE PARTICIPANT ALREADY HAS A MEETING SCHEDULED
  Future<void> check(Interview interview, bool isUpdating) async {
    List<User> users = [];
    for(var participant in interview.participants){
      await userCollection.doc(participant).get().then((value) {
        User user = new User.fromFireStore(value.data());
        users.add(user);
      });
    }
    for(User user in users){
      for(String interviewId in user.interviewIds){
        await interviewCollection.doc(interviewId).get().then((value) {

          Interview schedulledInterview = new Interview.fromFireStore(value.data());
          if(interview.interview_id != schedulledInterview.interview_id  && AppUtilityFunctions().intersects(interview.start_time, schedulledInterview.start_time, interview.end_time, schedulledInterview.end_time)){
            print(user.name + "" + schedulledInterview.start_time.toString() + " " + schedulledInterview.end_time.toString() + " " + interview.start_time.toString() + interview.end_time.toString());
            throw  IntervieweeBusyException();
          }
        });
      }
    }
    if(!isUpdating && interview.participants.length <= 3){
      throw  RequiredLengthNotFound();
    }
  }



}