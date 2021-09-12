String get getDateNow {
  return new DateTime.now().toString();
}

String get getDateNowMilliSecondStr {
  return new DateTime.now().millisecondsSinceEpoch.toString();
}

int get getDateNowMilliSecond {
  return new DateTime.now().millisecondsSinceEpoch;
}
