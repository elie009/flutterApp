class CategoryModel {
  String catid;
  String title;
  String iconapp;
  String iconweb;
  String status;
  bool issale;
  bool isrent;
  bool isinstallment;
  bool isswap;
  String dateadded;
  String headcategory;

  CategoryModel(
      {this.catid,
      this.title,
      this.iconapp,
      this.iconweb,
      this.status,
      this.issale,
      this.isrent,
      this.isinstallment,
      this.isswap,
      this.dateadded,
      this.headcategory});
}
