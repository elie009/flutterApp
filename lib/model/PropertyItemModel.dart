import 'package:cloud_firestore/cloud_firestore.dart';

class PropertyItemModel {
  String title;
  String conditionCode;
  String priceselectionCode;
  double price;
  String description;
  bool ismoreandsameitem;
  String dealmethodCode;
  String location_cityprovinceCode;
  String location_streetaddress;

  String branchCode;
  String featureCode;

  double lotarea;
  int bedroms;
  int bathrooms;
  double floorarea;
  int carspace;
  String furnishingCode;
  String roomCode;
  String termCode;

  double installment_downpayment;
  double installment_equity;
  double installment_amort;
  double installment_monthstopay;

  int numComments;
  int numLikes;
  int numViews;

  String propid;
  String menuid;
  String ownerUid;
  String ownerUsername;
  String status;
  String imageId;

  bool forSale;
  bool forRent;
  bool forInstallment;
  bool forSwap;

  PropertyItemModel.snapshot(DocumentSnapshot<Object> value) {
    this.title = value.get("title");
    this.conditionCode = value.get("conditionCode");
    this.priceselectionCode = value.get("priceselectionCode");
    this.price = value.get("price");
    this.description = value.get("description");
    this.ismoreandsameitem = value.get("ismoreandsameitem");
    this.dealmethodCode = value.get("dealmethodCode");
    this.location_cityprovinceCode = value.get("location_cityprovinceCode");
    this.location_streetaddress = value.get("location_streetaddress");
    this.branchCode = value.get("branchCode");
    this.featureCode = value.get("featureCode");
    this.lotarea = value.get("lotarea");
    this.bedroms = value.get("bedroms");
    this.bathrooms = value.get("bathrooms");
    this.floorarea = value.get("floorarea");
    this.carspace = value.get("carspace");
    this.furnishingCode = value.get("furnishingCode");
    this.roomCode = value.get("roomCode");
    this.numComments = value.get("numComments");
    this.numLikes = value.get("numLikes");
    this.numViews = value.get("numViews");
    this.propid = value.get("propid");
    this.menuid = value.get("menuid");
    this.ownerUid = value.get("ownerUid");
    this.ownerUsername = value.get("ownerUsername");
    this.status = value.get("status");
    this.imageId = value.get("imageId");
    this.forSale = value.get("forSale");
    this.forRent = value.get("forRent");
    this.forInstallment = value.get("forInstallment");
    this.forSwap = value.get("forSwap");
    this.termCode = value.get("termCode");

    this.installment_downpayment = value.get("installment_downpayment");
    this.installment_equity = value.get("installment_equity");
    this.installment_amort = value.get("installment_amort");
    this.installment_monthstopay = value.get("installment_monthstopay");
  }

  PropertyItemModel({
    this.title,
    this.conditionCode,
    this.priceselectionCode,
    this.price,
    this.description,
    this.ismoreandsameitem,
    this.dealmethodCode,
    this.location_cityprovinceCode,
    this.location_streetaddress,
    this.branchCode,
    this.featureCode,
    this.lotarea,
    this.bedroms,
    this.bathrooms,
    this.floorarea,
    this.carspace,
    this.furnishingCode,
    this.roomCode,
    this.numComments,
    this.numLikes,
    this.numViews,
    this.propid,
    this.menuid,
    this.ownerUid,
    this.ownerUsername,
    this.status,
    this.imageId,
    this.forSale,
    this.forRent,
    this.forInstallment,
    this.forSwap,
    this.termCode,
    this.installment_downpayment,
    this.installment_equity,
    this.installment_amort,
    this.installment_monthstopay,
  });
}
