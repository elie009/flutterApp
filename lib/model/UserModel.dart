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
  String post;
  String ratings;
  String response;
  String followers;
  String following;

  UserBaseModel({
    this.uid,
    this.firstName,
    this.image,
    this.createdDate,
    this.lastName,
    this.phoneNumber,
    this.status,
    this.displayName,
    this.location,
    this.email,
    this.post,
    this.ratings,
    this.response,
    this.followers,
    this.following,
  });
}
