class SpecialitiesModel {
  final String id;
  final String name;
  final String description;
  final String typeId;
  final int itemCount;
  final String imageAppName;
  final String imageWebName;

  SpecialitiesModel(
      {this.typeId,
      this.imageAppName,
      this.imageWebName,
      this.id,
      this.name,
      this.description,
      this.itemCount});
}
