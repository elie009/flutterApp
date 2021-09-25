import 'package:cloud_firestore/cloud_firestore.dart';

class PropertyModel {
  int numComments;
  int numLikes;
  int numDisLike;
  String propid;
  String menuid;
  String ownerUid;
  String status;
  String title; //MD001PLT001009
  String imageName; //MD001PLT001010
  String location; //MD001PLT001011
  String description; //MD001PLT001012
  double fixPrice; //MD001PLT001013
  String postdate;

  PropertyModel.snaphot(DocumentSnapshot<Object> value) {
    this.numComments = value.get("numComments");
    this.numLikes = value.get("numLikes");
    this.numDisLike = value.get("numDisLikes");
    this.propid = value.get("propid");
    this.title = value.get("title");
    this.description = value.get("description");
    this.imageName = value.get("imageName");
    this.fixPrice = value.get("fixPrice");
    this.location = value.get("location");
    this.menuid = value.get("menuid");
    this.ownerUid = value.get("ownerUid");
    this.status = value.get("status");
    this.postdate = value.get("postdate");
  }

  PropertyModel.instance(PropertyModel i) {
    this.numComments = i.numComments;
    this.numLikes = i.numLikes;
    this.numDisLike = i.numDisLike;
    this.propid = i.propid;
    this.title = i.title;
    this.description = i.description;
    this.imageName = i.imageName;
    this.fixPrice = i.fixPrice;
    this.location = i.location;
    this.menuid = i.menuid;
    this.ownerUid = i.ownerUid;
    this.status = i.status;
    this.postdate = i.postdate;
  }

  PropertyModel(
      int numComments,
      int numLike,
      int numDisLike,
      String propid,
      String title,
      String description,
      String imageName,
      double fixPrice,
      String location,
      String menuid,
      String ownerUid,
      String status,
      String postdate) {
    this.numComments = numComments;
    this.numLikes = numLike;
    this.numDisLike = numDisLike;
    this.propid = propid;
    this.title = title;
    this.description = description;
    this.imageName = imageName;
    this.fixPrice = fixPrice;
    this.location = location;
    this.menuid = menuid;
    this.ownerUid = ownerUid;
    this.status = status;
    this.postdate = postdate;
  }

  List<String> checkPropertySave() {
    List<String> noinput = [];

    if (title.isEmpty) noinput.add('MD001PLT001009');
    return noinput;
  }

  List<String> checkPropertySubmit() {
    List<String> noinput = [];

    if (title.isEmpty) noinput.add('MD001PLT001009');
    //if (location.isEmpty) noinput.add('MD001PLT001006');
    if (fixPrice <= 0) noinput.add('MD001PLT001013');
    return noinput;
  }
}
