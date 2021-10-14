class WishListModel {
  String categoryid;
  String title;
  String message;
  String wishid;
  bool isSelect;
  String localstatus;

  WishListModel(
      {this.isSelect,
      this.localstatus,
      this.categoryid,
      this.title,
      this.message,
      this.wishid});
}
