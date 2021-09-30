import 'package:flutter_app/model/PropertyModel.dart';

class PropertyLotModel extends PropertyModel {
  double lotSize; //MD001PLT001001
  int saleLotOption; //MD001PLT001002
  double saleLotFixPrice; //MD001PLT001005

  int rentLotOption; //MD001PLT001002
  double rentLotFixPrice; //MD001PLT001005
  String rentAgreement; //MD001PLT001006
  String rentTermsOfPaymentCd; //MD001PLT001007
  String rentMinContactCd; //MD001PLT001007
  double rentMinContactNum; //MD001PLT001007

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
  String postdate;
  bool forSwap;
  int conditionCode;

  PropertyLotModel({
    this.lotSize,
    this.saleLotOption,
    this.saleLotFixPrice,
    this.rentLotOption,
    this.rentLotFixPrice,
    this.rentAgreement,
    this.rentTermsOfPaymentCd,
    this.rentMinContactCd,
    this.rentMinContactNum,
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
    this.forSwap,
  }) : super(
          numComments: numComments,
          numLikes: numLikes,
          numViews: numViews,
          propid: propid,
          title: title,
          description: description,
          imageName: imageName,
          saleFixPrice: saleFixPrice,
          rentFixPrice: rentFixPrice,
          installmentFixPrice: installmentFixPrice,
          location: location,
          menuid: menuid,
          ownerUid: ownerUid,
          status: status,
          postdate: postdate,
        );
}
