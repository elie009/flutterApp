import 'package:cloud_firestore/cloud_firestore.dart';

class PropertyModel {
  int numComments;
  int numLikes;
  int numViews;
  String propid;
  String menuid;
  String ownerUid;
  String status;
  String title; //MD001PLT001009
  String imageName; //MD001PLT001010
  String location; //MD001PLT001011
  String description; //MD001PLT001012
  double saleFixPrice; //MD001PLT001013
  double rentFixPrice; //MD001PLT001013
  double installmentFixPrice; //MD001PLT001013
  bool forSwap;
  String conditionCode;

  String postdate;

  PropertyModel.init() {
    this.numComments = 0;
    this.numLikes = 0;
    this.numViews = 0;
    this.propid = '';
    this.title = '';
    this.description = '';
    this.imageName = '';
    this.saleFixPrice = 0.00;
    this.rentFixPrice = 0.00;
    this.installmentFixPrice = 0.00;
    this.location = '';
    this.menuid = '';
    this.ownerUid = '';
    this.status = '';
    this.postdate = '';
    this.forSwap = false;
    // ignore: unnecessary_statements
    this.conditionCode ='';
  }

  PropertyModel.snaphot(DocumentSnapshot<Object> value) {
    this.numComments = value.get("numComments");
    this.numLikes = value.get("numLikes");
    this.numViews = value.get("numViews");
    this.propid = value.get("propid");
    this.title = value.get("title");
    this.description = value.get("description");
    this.imageName = value.get("imageName");
    this.saleFixPrice = value.get("saleFixPrice");
    this.rentFixPrice = value.get("rentFixPrice");
    this.installmentFixPrice = value.get("installmentFixPrice");
    this.location = value.get("location");
    this.menuid = value.get("menuid");
    this.ownerUid = value.get("ownerUid");
    this.status = value.get("status");
    this.postdate = value.get("postdate");
    this.forSwap = value.get("forSwap");
    this.conditionCode = value.get("conditionCode");
  }

  PropertyModel.instance(PropertyModel i) {
    this.numComments = i.numComments;
    this.numLikes = i.numLikes;
    this.numViews = i.numViews;
    this.propid = i.propid;
    this.title = i.title;
    this.description = i.description;
    this.imageName = i.imageName;
    this.saleFixPrice = i.saleFixPrice;
    this.rentFixPrice = i.rentFixPrice;
    this.installmentFixPrice = i.installmentFixPrice;
    this.location = i.location;
    this.menuid = i.menuid;
    this.ownerUid = i.ownerUid;
    this.status = i.status;
    this.postdate = i.postdate;
    this.forSwap = i.forSwap;
    this.conditionCode = i.conditionCode;
  }
  PropertyModel.obj(
    int numComments,
    int numLike,
    int numDisLike,
    String propid,
    String title,
    String description,
    String imageName,
    double saleFixPrice,
    double rentFixPrice,
    double installmentFixPrice,
    String location,
    String menuid,
    String ownerUid,
    String status,
    String postdate,
    bool forSwap,
    String conditionCode,
  ) {
    this.numComments = numComments;
    this.numLikes = numLike;
    this.numViews = numViews;
    this.propid = propid;
    this.title = title;
    this.description = description;
    this.imageName = imageName;
    this.saleFixPrice = saleFixPrice;
    this.rentFixPrice = rentFixPrice;
    this.installmentFixPrice = installmentFixPrice;
    this.location = location;
    this.menuid = menuid;
    this.ownerUid = ownerUid;
    this.status = status;
    this.postdate = postdate;
    this.forSwap = forSwap;
    this.conditionCode = conditionCode;
  }

  PropertyModel({
    this.numComments,
    this.numLikes,
    this.numViews,
    this.propid,
    this.title,
    this.description,
    this.imageName,
    this.saleFixPrice,
    this.rentFixPrice,
    this.installmentFixPrice,
    this.location,
    this.menuid,
    this.ownerUid,
    this.status,
    this.postdate,
    this.conditionCode,
  });

  List<String> checkPropertySave() {
    List<String> noinput = [];

    if (title.isEmpty) noinput.add('MD001PLT001009');
    return noinput;
  }

  List<String> checkPropertySubmit() {
    List<String> noinput = [];

    if (title.isEmpty) noinput.add('MD001PLT001009');
    //if (location.isEmpty) noinput.add('MD001PLT001006');
    if (saleFixPrice <= 0) noinput.add('MD001PLT001013');
    return noinput;
  }
}
