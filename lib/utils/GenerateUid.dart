import 'package:flutter_app/utils/StaticString.dart';
import 'package:uuid/uuid.dart';

// Create uuid object
var uuid = Uuid();

/* 
 * Generate a v1 (time-based) id
 * ex. '6c84fb90-12c4-11e1-840d-7b25c5ee775a'
 */
String uidV1() {
  return (uuid.v1());
}

/* 
 * Generate a v4 (random) id
 * ex. '110ec58a-a0f2-4ac4-8393-c866d813b8d1'
 */
String itemID() {
  return ("item" + uuid.v4());
}

/* 
 * Generate a v4 (random) id
 * ex. '110ec58a-a0f2-4ac4-8393-c866d813b8d1'
 */
String get bookingID {
  return ("book" + uuid.v4());
}

/* 
 * Generate a v4 (random) id
 * ex. '110ec58a-a0f2-4ac4-8393-c866d813b8d1'
 */
String get chatID {
  return ("chat" + uuid.v4());
}

String get contactID {
  return ("contact" + uuid.v4());
}
