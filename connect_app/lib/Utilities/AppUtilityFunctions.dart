
class AppUtilityFunctions{

  String getInterviewId(DateTime startTime, DateTime endTime, String userId){
    String start = startTime.year.toString() + startTime.month.toString() + startTime.day.toString() + startTime.hour.toString() +
        startTime.minute.toString();
    String end =   endTime.year.toString() + endTime.month.toString() + endTime.day.toString() + endTime.hour.toString() +
        endTime.minute.toString();
    String interviewId = userId + start + end;
    return interviewId;
  }

  
}