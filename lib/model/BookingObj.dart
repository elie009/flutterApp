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
}
