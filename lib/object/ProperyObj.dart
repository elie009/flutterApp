class Property {
  String propid;
  String title;
  String description;
  String imageName;
  int fromPrice;
  int toPrice;
  int fixPrice;
  String location;
  String menuid;


  Property(
      String propid,
      String title,
      String description,
      String imageName,
      int fromPrice,
      int toPrice,
      int fixPrice,
      String location,
      String menuid) {
    this.propid = propid;
    this.title = title;
    this.description = description;
    this.imageName = imageName;
    this.fromPrice = fromPrice;
    this.toPrice = toPrice;
    this.fixPrice = fixPrice;
    this.location = location;
    this.menuid = menuid;
  }

  String getPropId() {
    return this.propid;
  }

  String getTitle() {
    return this.title;
  }

  String getDescription() {
    return this.description;
  }

  String getImageName() {
    return this.imageName;
  }

  int getFromPrice() {
    return this.fromPrice;
  }

  int getToPrice() {
    return this.toPrice;
  }

  int getFixPrice() {
    return this.fixPrice;
  }

  String getLocation() {
    return this.location;
  }

  String getMenuId() {
    return this.menuid;
  }
}
