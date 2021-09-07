class PropertyModel {
  final String propid;
  final String title;
  final String description;
  final String imageName;
  final int fromPrice;
  final int toPrice;
  final int fixPrice;
  final String location;
  final String menuid;
  

  PropertyModel(
      {this.propid,
      this.title,
      this.description,
      this.imageName,
      this.fromPrice,
      this.toPrice,
      this.fixPrice,
      this.location,
      this.menuid});
}
