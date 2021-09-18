class UserBase {
  String uid;
  String email;
  String firstName;
  String lastName;
  String phoneNumber;
  String status;
  String image;

  UserBase.auth(
      {this.uid,
      this.firstName,
      this.image,
      this.lastName,
      this.phoneNumber,
      this.status,
      this.email});

  UserBase(String uid, String firstName, String image, String lastName,
      String phoneNumber, String status, String email) {
    this.uid = uid;
    this.firstName = firstName;
    this.image = image;
    this.lastName = lastName;
    this.phoneNumber = phoneNumber;
    this.status = status;
    this.email = email;
  }
}
