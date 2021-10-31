class UserBaseModel {
  String uid;
  String email;
  String firstName;
  String lastName;
  String phoneNumber;
  String status;
  String image;
  String displayName;
  String location;
  String createdDate;

  UserBaseModel(
      {this.uid,
      this.firstName,
      this.image,
      this.createdDate,
      this.lastName,
      this.phoneNumber,
      this.status,
      this.displayName,
      this.location,
      this.email});
}
