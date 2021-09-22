import 'PropertyModel.dart';

class PropertyLotModel extends PropertyModel {
  double lotSize; //MD001PLT001001
  double perSqm; //MD001PLT001002
  String nearby; //MD001PLT001003
  String amenities; //MD001PLT001004
  String rentBillabletype; //MD001PLT001005
  String rentRestrictions; //MD001PLT001006
  String saleContainPaper; //MD001PLT001007
  String tradableItems; //MD001PLT001008
  String status;

  PropertyLotModel(
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
    double lotSize,
    double perSqm,
    String nearby,
    String amenities,
    String rentBillabletype,
    String rentRestrictions,
    String saleContainPaper,
    String tradableItems,
    String status,
    String postdate,
  ) : super(numComments, numLike, numDisLike, propid, title, description,
            imageName, fixPrice, location, menuid, ownerUid, status, postdate) {
    this.lotSize = lotSize;
    this.perSqm = perSqm;
    this.nearby = nearby;
    this.amenities = amenities;
    this.rentBillabletype = rentBillabletype;
    this.rentRestrictions = rentRestrictions;
    this.saleContainPaper = saleContainPaper;
    this.tradableItems = tradableItems;
  }

  List<String> checkPropertyLotSubmit(bool isRent, bool isTrade) {
    List<String> noinput = [];

    if (lotSize <= 0) noinput.add('MD001PLT001001');
    if (isRent && rentRestrictions.isEmpty) noinput.add('MD001PLT001006');
    if (isTrade && tradableItems.isEmpty) noinput.add('MD001PLT001008');
    noinput.addAll(checkPropertySubmit());
    return noinput;
  }
}
