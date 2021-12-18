class RequiredLengthNotFound implements Exception{
  String errMsg() => 'You need to have more than two participants in this meeting to schedule this meeting.';
}