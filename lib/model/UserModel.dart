class UserBaseModel {
  String uid;
  String email;
  String firstName;
  String lastName;
  String phoneNumber;
  String status;
  String image;
  String displayName;

  UserBaseModel(
      {this.uid,
      this.firstName,
      this.image,
      this.lastName,
      this.phoneNumber,
      this.status,
      this.displayName,
      this.email});
}
