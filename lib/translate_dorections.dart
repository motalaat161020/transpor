
import 'package:admin_dashboard/localization/services.dart';
import 'package:get/get.dart%20';

translateDatabase(columnar, columnen) {
  MyServices myServices = Get.find();

  if (myServices.sharedPreferences.getString("lang") == "ar") {
    return columnar;
  } else {
    return columnen;
  }

}

  