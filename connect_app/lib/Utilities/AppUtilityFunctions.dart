
class AppUtilityFunctions{


  bool intersects(DateTime startTime1 , DateTime startTime2, DateTime endTime1, DateTime endTime2){
    return (startTime1.isAfter(startTime2) && startTime1.isBefore(endTime2)) || (endTime1.isAfter(startTime2) && endTime1.isBefore(endTime2));
  }
  
}