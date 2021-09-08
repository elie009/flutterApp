class Booking {
  String fromYear;
  String fromMonth;
  String fromDay;
  String toYear;
  String toMonth;
  String toDay;
  String propsId;
  String bookId;
  String userId;
  String bookingStatus;

  Booking(
    String fromYear,
    String fromMonth,
    String fromDay,
    String toYear,
    String toMonth,
    String toDay,
    String propsId,
    String bookId,
    String userId,
    String bookingStatus,
  ) {
    this.fromYear = fromYear;
    this.fromMonth = fromMonth;
    this.fromDay = fromDay;
    this.toYear = toYear;
    this.toMonth = toMonth;
    this.toDay = toDay;
    this.propsId = propsId;
    this.bookId = bookId;
    this.userId = userId;
    this.bookingStatus = bookingStatus;
  }


  String getFromYear() {
    return this.fromYear;
  }

  String getFromMonth() {
    return this.fromMonth;
  }

  String getFromDay() {
    return this.fromDay;
  }

  String getToYear() {
    return this.toYear;
  }

  String getToMonth() {
    return this.toMonth;
  }

  String getToDay() {
    return this.toDay;
  }

  String getPropId() {
    return this.propsId;
  }

  String getBookId() {
    return this.bookId;
  }

  String getUserId() {
    return this.userId;
  }

  String getBookingStatus() {
    return this.bookingStatus;
  }
}
