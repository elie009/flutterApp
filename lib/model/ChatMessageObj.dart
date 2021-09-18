class ChatMessage {
  String imageUrl;
  String profilePhoto;
  String senderId;
  String senderName;
  String text;
  String time;

  ChatMessage(String imageUrl, String profilePhoto, String senderId,
      String senderName, String text, String time) {
    this.imageUrl = imageUrl;
    this.profilePhoto = profilePhoto;
    this.senderId = senderId;
    this.senderName = senderName;
    this.text = text;
    this.time = time;
  }
}
