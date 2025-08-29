class GeneralHelper {
  static String getBestAddress(List<String> addresses) {
    for (var element in addresses) {
      if (!element.contains("+")) {
        return element;
      }
    }
    return addresses[0];
  }

  static String calculationTotalCash(
      {required int cost,
      required String totalDistance,
      required List<dynamic> serviceTimeList,
      required bool isFreeRide,
      required num minimumFare}) {
    //if()

    var datetime = DateTime.now();
    String time = '${datetime.hour}:${datetime.minute}';

    if (isFreeRide) {
      for (var serviceTime in serviceTimeList) {
        if (calculationHours(time) >=
                calculationHours((serviceTime['startingTime'] as String)) &&
            calculationHours(time) <=
                calculationHours((serviceTime['endingTime'] as String))) {
          if (((serviceTime['costPerKiloInTime'] as num)).round().toDouble() <
              minimumFare.toDouble()) {
            return "$minimumFare MRU";
          }
          return "${(((serviceTime['costPerKiloInTime'] as num).toDouble() * double.parse(totalDistance.split("m").first))).round()} MRU";
        }
      }
      return "$cost MRU";
    }

    if (totalDistance.contains(",")) {
      if (totalDistance.contains("m")) {
        return "20 MRU";
      }
      totalDistance = totalDistance.replaceAll(',', '');
    }
    if (totalDistance.contains("k")) {
      for (var serviceTime in serviceTimeList) {
        final Map<String, dynamic> st = serviceTime as Map<String, dynamic>;
        if (calculationHours(time) >=
                calculationHours((st['startingTime'] as String)) &&
            calculationHours(time) <=
                calculationHours((st['endingTime'] as String))) {
          if (!isFreeRide) {
            final List<dynamic> listOfKilos =
                (st['listOfKilos'] as List<dynamic>);
            for (int i = 0; i < listOfKilos.length; i++) {
              final Map<String, dynamic> kiloRange =
                  listOfKilos[i] as Map<String, dynamic>;
              if (double.parse(totalDistance.split(" ").first) >=
                      (kiloRange['initialDistance'] as num).toDouble() &&
                  double.parse(totalDistance.split(" ").first) <=
                      (kiloRange['finalDistance'] as num).toDouble()) {
                return "${((kiloRange['costForDistance'] as num).toDouble())} MRU";
              }
            }
          }
          if ((((st['costPerKiloInTime'] as num).toDouble()) *
                      double.parse(totalDistance.split("km").first))
                  .round()
                  .toDouble() <
              minimumFare.toDouble()) {
            return "$minimumFare MRU";
          }
          return "${(((st['costPerKiloInTime'] as num).toDouble() * double.parse(totalDistance.split("km").first))).round()} MRU";
        }
      }
    }
    if (totalDistance.contains("k")) {
      if ((cost * double.parse(totalDistance.split("km").first))
              .round()
              .toDouble() <
          minimumFare) {
        return "$minimumFare MRU";
      }
      return "${(cost * double.parse(totalDistance.split("km").first)).round().toString()} MRU";
    }

    return "$minimumFare MRU";
  }

  static double calculationHours(String time) {
    return double.parse(time.split(":").first) +
        double.parse(time.split(":")[1]) / 60;
  }

  static double calculationCostPerKilo({
    required double cost,
    required List<dynamic> serviceTimeList,
    required double totalDistance,
    required bool isFreeRide,
  }) {
    var datetime = DateTime.now();
    String time = '${datetime.hour}:${datetime.minute}';

    for (var serviceTime in serviceTimeList) {
      final Map<String, dynamic> st = serviceTime as Map<String, dynamic>;
      if (calculationHours(time) >=
              calculationHours((st['startingTime'] as String)) &&
          calculationHours(time) <=
              calculationHours((st['endingTime'] as String))) {
        if (!isFreeRide) {
          final List<dynamic> listOfKilos =
              (st['listOfKilos'] as List<dynamic>);
          for (int i = 0; i < listOfKilos.length; i++) {
            final Map<String, dynamic> kiloRange =
                listOfKilos[i] as Map<String, dynamic>;
            if (totalDistance >=
                    (kiloRange['initialDistance'] as num).toDouble() &&
                totalDistance <=
                    (kiloRange['finalDistance'] as num).toDouble()) {
              return (((kiloRange['costForDistance'] as num).toDouble() /
                      totalDistance))
                  .round()
                  .toDouble();
            }
          }
        }

        return (st['costPerKiloInTime'] as num).toDouble();
      }
    }
    return cost;
  }

  static double calculationTotalCashDouble(
      {required double cost,
      required String totalDistance,
      required bool isFreeRide,
      required List<dynamic> serviceTimeList,
      required num minimumFare}) {
    var datetime = DateTime.now();
    String time = '${datetime.hour}:${datetime.minute}';

    if (isFreeRide) {
      for (var serviceTime in serviceTimeList) {
        if (calculationHours(time) >=
                calculationHours((serviceTime['startingTime'] as String)) &&
            calculationHours(time) <=
                calculationHours((serviceTime['endingTime'] as String))) {
          if (minimumFare.toDouble() >
              (serviceTime['costPerKiloInTime'] as num).toDouble()) {
            return minimumFare.toDouble();
          }
          return (serviceTime['costPerKiloInTime'] as num).toDouble() *
              double.parse(totalDistance.split("km").first);
        }
      }
      return cost;
    }

    if (totalDistance.contains(",")) {
      if (totalDistance.contains("m")) {
        return 50;
      }
      totalDistance = totalDistance.replaceAll(',', '');
    }

    if (totalDistance.contains('k')) {
      for (var serviceTime in serviceTimeList) {
        final Map<String, dynamic> st = serviceTime as Map<String, dynamic>;
        if (calculationHours(time) >=
                calculationHours((st['startingTime'] as String)) &&
            calculationHours(time) <=
                calculationHours((st['endingTime'] as String))) {
          if (!isFreeRide) {
            final List<dynamic> listOfKilos =
                (st['listOfKilos'] as List<dynamic>);
            for (int i = 0; i < listOfKilos.length; i++) {
              final Map<String, dynamic> kiloRange =
                  listOfKilos[i] as Map<String, dynamic>;
              if (double.parse(totalDistance.split(" ").first) >=
                      (kiloRange['initialDistance'] as num).toDouble() &&
                  double.parse(totalDistance.split(" ").first) <=
                      (kiloRange['finalDistance'] as num).toDouble()) {
                return (kiloRange['costForDistance'] as num).toDouble();
              }
            }
          }

          if (minimumFare.toDouble() >
              (serviceTime['costPerKiloInTime'] as num).toDouble() *
                  double.parse(totalDistance.split("km").first)) {
            return minimumFare.toDouble();
          }
          return (serviceTime['costPerKiloInTime'] as num).toDouble() *
              double.parse(totalDistance.split("km").first);
        }
      }
      if (minimumFare.toDouble() >
          cost * double.parse(totalDistance.split("km").first)) {
        return minimumFare.toDouble();
      }
      return (cost * double.parse(totalDistance.split("km").first))
          .round()
          .toDouble();
    }
    return minimumFare.toDouble();
  }

  static String transDistance(String distance) {
    if (distance.contains("km")) {
      distance = distance.replaceAll("km", "كم");
    }
    if (distance.contains("m")) {
      distance = distance.replaceAll("m", "متر");
    }
    return distance;
  }

  static String transDuration(String duration) {
    if (duration.contains("mins")) {
      duration = duration.replaceAll("mins", "دقائق");
    }
    if (duration.contains("min")) {
      duration = duration.replaceAll("min", "دقيقة");
    }
    if (duration.contains("hours")) {
      duration = duration.replaceAll("hours", "ساعات");
    }
    if (duration.contains("hour")) {
      duration = duration.replaceAll("hour", "ساعة");
    }
    return duration;
  }

  static bool isContains(String serviceRegion, String userRegion) {
    List<String> serviceRegionList = serviceRegion.split(",");
    for (var element in serviceRegionList) {
      if (userRegion.contains(element)) {
        return true;
      }
    }
    return false;
  }

  static double getDis(String distance) {
    try {
      if (distance.contains("k")) {
        return double.parse(distance.replaceAll("km", '').trim());
      }
    } catch (e) {
      return 10;
    }
    return 10;
  }
}
//"${(HomeCubit.get(context).services[index].costPerKilo * double.parse(HomeCubit.get(context).directions!.totalDistance.split("km").first)).toString()} UM",
