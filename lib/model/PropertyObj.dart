class Property {
  String propid;
  String menuid;
  String ownerUid;
  String status;
  String title; //MD001PLT001009
  String imageName; //MD001PLT001010
  String location; //MD001PLT001011
  String description; //MD001PLT001012
  double fixPrice; //MD001PLT001013

  Property(String propid, String title, String description, String imageName,
      double fixPrice, String location, String menuid, String ownerUid, String status) {
    this.propid = propid;
    this.title = title;
    this.description = description;
    this.imageName = imageName;
    this.fixPrice = fixPrice;
    this.location = location;
    this.menuid = menuid;
    this.ownerUid = ownerUid;
    this.status = status;
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
