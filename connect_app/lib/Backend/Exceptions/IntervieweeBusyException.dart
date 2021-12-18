class IntervieweeBusyException implements Exception{
  String errMsg() => 'Looks like this interviewee already has an interview scheduled at this time';
}