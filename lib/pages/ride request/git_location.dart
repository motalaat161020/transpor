// ignore_for_file: file_names

import 'dart:convert';

 
import 'package:http/http.dart' as http;
 
 
import 'dart:async';

class GoogleMapSearchModel {
  List<Prediction>? predictions;
  String? status;

  GoogleMapSearchModel({this.predictions, this.status});

  factory GoogleMapSearchModel.fromJson(Map<String, dynamic> json) {
    return GoogleMapSearchModel(
      predictions: json['predictions'] != null ? (json['predictions'] as List).map((i) => Prediction.fromJson(i as Map<String, dynamic> )).toList() : null,
      status: json['status'] as String ,
    );
  }

 
 
 

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (predictions != null) {
      data['predictions'] = predictions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Prediction {
  String? description;
  String? placeId;
  String? reference;
  List<String>? types;

  Prediction({this.description, this.placeId, this.reference,  this.types});

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      description: json['description'].toString(),
      placeId: json['place_id'].toString(),
      reference: json['reference'].toString(),
      types: json['types'] != null ? List<String>.from(json['types'] as Iterable<dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['description'] = description;
    data['place_id'] = placeId;
    data['reference'] = reference;
    if (types != null) {
      data['types'] = types;
    }
    return data;
 }
}

 String GOOGLE_MAP_API_KEY =
    'AIzaSyBw2yjQlova1YwxnvA733FZ9PK7sn99jlU'; 


Future<GoogleMapSearchModel?> searchListAddress({required String value}) async {
  try {
    // Validate that value is not null or empty
    if (value.isEmpty) {
      print('Error: Search value cannot be empty');
      return null;
    }

    final response = await http.get(Uri.parse('https://dashboard.ghayti.app/proxy.php?input=$value&components=country:eg'));
    
    if (response.statusCode == 200) {
      final responseBody = response.body;
      if (responseBody.isNotEmpty) {
        return GoogleMapSearchModel.fromJson(json.decode(responseBody) as Map<String, dynamic>);
      } else {
        print('Error: Empty response body');
        return null;
      }
    } else {
      print('Error: Request failed with status ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error in searchListAddress: $e');
    return null;
  }
}


 

 
 
// Future<GoogleMapSearchModel?> searchListAddress({required String value}) async {
//   try {
// final client = CorsMiddleware();
// // final response = await client.get(Uri.parse('https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$value&key=$GOOGLE_MAP_API_KEY&components=country:mr'));
//     final response = await http.get(Uri.parse('https://yourserver.com/proxy.php?input=$value&components=country:eg'));

//     if (response.statusCode == 200) {
//       final decodedResponse = json.decode(response.body);
//  //     if (decodedResponse['status'] == 'OK') {
//         return GoogleMapSearchModel.fromJson(decodedResponse);
//     //  } else {
//        //  return null;
//      // }
//     } else {
//        return null;
//     }
//   } catch (e, stackTrace) {
 
//     return null;
//   }


// Future<GoogleMapSearchModel?> searchListAddress(
//       {required String value}) async {
//     try {
//       Response response = await  DioFactory.getDio().get(
//           'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$value&key=$GOOGLE_MAP_API_KEY&components=country:eg');
//       if (response.statusCode == 200) {
//         return GoogleMapSearchModel.fromJson(response.data);
//       } else {
//         return null;
//       }
//     } catch (e) {
//        return null;
//     }}
