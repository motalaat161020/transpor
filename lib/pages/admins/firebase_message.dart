// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:get/get.dart';

// import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

//   // import '../../controller/orders/pending_controller.dart';

// PirmitionNotifications() async {
//   FirebaseMessaging messaging = FirebaseMessaging.instance;

//   NotificationSettings settings = await messaging.requestPermission(
//     alert: true,
//     announcement: false,
//     badge: true,
//     carPlay: false,
//     criticalAlert: false,
//     provisional: false,
//     sound: true,
//   );
// }

// fcmNotification() {
//   FirebaseMessaging.onMessage.listen((message) {
//      ('onMessage========================== ${message.data}');
//     Get.snackbar(
//       message.notification!.title.toString(),
//       message.notification!.body.toString(),
//     );
//     FlutterRingtonePlayer().playNotification();
//     //  refreshPageNotification(message.data);
//   });
// }

// // create Method to send message  

// // refreshPageNotification(data) {
// //   //good instead of Stream Firebase // تعمل ريفرش للصفحة بالمعلومات المطلوبه يتعملها ابديت
// //    ("============================= page id ");
// //    (data['pageid']);
// //    ("============================= page name ");
// //    (data['pagename']);
// //    ("================== Current Route");
// //    (Get.currentRoute);

// //   if (Get.currentRoute == "/orderspending" &&
// //       data['pagename'] == "refreshorderpending") {
// //     OrdersPendingController controller = Get.find();
// //     controller.refrehOrder();
// //   } else if (Get.currentRoute == "/orderscompleted" &&
// //       data['pagename'] == "refreshordercompleted") {
// //     OrdersPendingController controller = Get.find();
// //     controller.refrehOrder();
// //   }
// // }
// // Firebase + stream
// // Socket io
// // Notification refresh

// // ...
