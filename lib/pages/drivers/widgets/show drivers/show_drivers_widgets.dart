import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:admin_dashboard/constants/controllers.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
// import 'package:intl/intl.dart';

import '../../../../constants/style.dart';
import '../../../../widgets/custom_text.dart';

class ShowDriversTable extends StatefulWidget {
  final int? indexPage;
  const ShowDriversTable({super.key, this.indexPage});

  @override
  State<ShowDriversTable> createState() => _ShowUsersTableState();
}

class _ShowUsersTableState extends State<ShowDriversTable> {
  Widget textofTableTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
    );
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _allUsers = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _displayedUsers = [];
  final List<double> _ratingOptions = [0, 1, 2, 3, 4, 5];
  double? _selectedRating;
  final List<bool> _selectstate = [true, false];
  bool? _selectedVerfied;
  String _searchQuery = '';
  int _currentPage = 1;
  final int _itemsPerPage = 8;
  final _firestore = FirebaseFirestore.instance;
  var aa;

  Future<void> _approveDriver(String driverId, String driverUserName) async {
    try {
      String? adminId = FirebaseAuth.instance.currentUser?.uid;
      await _firestore.collection('drivers').doc(driverId).update({
        'isVerified': true,
        'isApproved': true,
        'isRejected': false,
        'rejectionReason': null,
        'approvedAt': FieldValue.serverTimestamp(),
        'approvedBy': adminId,
      });

      await _firestore.collection('adminActions').add({
        'adminId': adminId,
        'adminEmail': FirebaseAuth.instance.currentUser?.email,
        'Name': driverUserName,
        'Id': driverId,
        'newState': true,
        'type': 'change Driver State',
        'actionType': 'driverApproval',
        'timestamp': FieldValue.serverTimestamp(),
      });
      setState(() {});
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Verification Account'.tr,
              style: const TextStyle(fontSize: 20),
            ),
            content: SingleChildScrollView(
              child: Text(
                'Driver Verified'.tr,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Close'.tr),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      ('Error updating verification status: $e'.tr);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating verification status: $e'.tr),
        ),
      );
    }
  }

  Future<void> _rejectDriver(
      String driverId, String driverUserName, String? reason) async {
    try {
      String? adminId = FirebaseAuth.instance.currentUser?.uid;
      await _firestore.collection('drivers').doc(driverId).update({
        'isVerified': false,
        'isApproved': false,
        'isRejected': true,
        'rejectionReason': reason ?? '',
        'rejectedAt': FieldValue.serverTimestamp(),
        'approvedBy': null,
      });

      await _firestore.collection('adminActions').add({
        'adminId': adminId,
        'adminEmail': FirebaseAuth.instance.currentUser?.email,
        'Name': driverUserName,
        'Id': driverId,
        'newState': false,
        'type': 'change Driver State',
        'actionType': 'driverRejection',
        'reason': reason ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      ('Error updating verification status: $e'.tr);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating verification status: $e'.tr),
        ),
      );
    }
  }

  var searchController = TextEditingController();

  Widget searchBarWidgets() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: TextFormField(
            style: const TextStyle(fontSize: 17, color: Colors.blue),
            controller: searchController,
            decoration: InputDecoration(
              labelText: 'phone Number or ID'.tr,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              counterText: '',
            ),
            onEditingComplete: () {
              setState(() {
                _searchQuery = searchController.text.trim();
                _updateDisplayedUsers(); // Update displayed users after search
              });
            },
          ),
        ),
        const SizedBox(width: 25),
        Row(
          children: [
            textofTableTitle("Rate :".tr),
            Material(
              child: DropdownButton<double>(
                value: _selectedRating,
                hint: const Text('Filter by Rating'),
                onChanged: (value) {
                  setState(() {
                    _selectedRating = value;
                    _updateDisplayedUsers();
                  });
                },
                items: [
                  DropdownMenuItem<double>(
                    value: null,
                    child: Text('All'.tr),
                  ),
                  ..._ratingOptions.map((rating) {
                    return DropdownMenuItem<double>(
                      value: rating, //.ceilToDouble(), //rating.toDouble(),

                      child: Text(rating.toString()),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 25),
        Row(
          children: [
            textofTableTitle("Status :".tr),
            Material(
              child: DropdownButton<bool>(
                value: _selectedVerfied,
                hint: const Text('Filter by Status'),
                onChanged: (value) {
                  setState(() {
                    _selectedVerfied = value; // == true ? "online" : "offline";
                    _updateDisplayedUsers();
                  });
                },
                items: [
                  DropdownMenuItem<bool>(
                    value: null,
                    child: Text('All'.tr),
                  ),
                  ..._selectstate.map((state) {
                    return DropdownMenuItem<bool>(
                      value: state,
                      child: Text(state ? "online".tr : "offline".tr),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  ////////////////////////////////////////////////////////
  void _updateDisplayedUsers() {
    _displayedUsers = _allUsers
        .where((user) =>
            (user['phoneNumber']
                    .toString()
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                user.id.toString().contains(_searchQuery)) &&
            (_selectedRating == null ||
                ((user['rating'] as num).toDouble() >= _selectedRating! &&
                    (user['rating'] as num).toDouble() <
                        _selectedRating! + 1)) &&
            (_selectedVerfied == null || user['isOnline'] == _selectedVerfied))
        .toList();

    ("Filtered users count: ${_displayedUsers.length}"); // Debugging: Check the count of filtered users

    // Pagination logic remains the same
    int startIndex = (_currentPage - 1) * _itemsPerPage;
    int endIndex = startIndex + _itemsPerPage;

    if (endIndex > _displayedUsers.length) {
      endIndex = _displayedUsers.length;
    }

    _displayedUsers = _displayedUsers.sublist(startIndex, endIndex);
    setState(() {
      ("Updated displayed users for UI"); // Ensure this is called to trigger UI update
    });
  }

  @override
  void initState() {
    super.initState();
    _currentPage = widget.indexPage ?? 1;
    _fetchUsers(); // Fetch users on initialization
  }

  void _fetchUsers() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('drivers')
        .orderBy("createdAt", descending: true)
        .get();
    ("Number of documents fetched: ${snapshot.docs.length}");
    _allUsers = snapshot.docs;
    _updateDisplayedUsers(); // Initial display of users
  }

  Future<void> updateDocumentStatus(
      String documentId, userId, status, driverName) async {
    // Update the document status in Firestore
    await FirebaseFirestore.instance
        .collection('drivers')
        .doc(userId.toString())
        .collection("documents")
        .doc(documentId)
        .update({
      "status": status,
    }).catchError((error) => ("Failed to update document: $error".tr));
    String? adminId = FirebaseAuth.instance.currentUser?.uid;

    await _firestore.collection('adminActions').add({
      'adminId': adminId,
      'adminEmail': FirebaseAuth.instance.currentUser?.email,
      'Name': driverName,
      'Id': documentId,
      'newState': status,
      'type': 'changeDocumentDriverState',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    var columns = [
      DataColumn(label: textofTableTitle('No'.tr)),
      DataColumn(label: textofTableTitle('User Name'.tr)),
      DataColumn(label: textofTableTitle('rating'.tr)),
      DataColumn(label: textofTableTitle('balance'.tr)),
      DataColumn(label: textofTableTitle('service'.tr)),
      DataColumn(label: textofTableTitle('Phone Number'.tr)),
      DataColumn(label: textofTableTitle('driver ID'.tr)),
      DataColumn(label: textofTableTitle('Verification'.tr)),
      DataColumn(label: textofTableTitle('Status'.tr)),
      DataColumn(label: textofTableTitle('Account Status'.tr)),
      DataColumn(label: textofTableTitle('Action'.tr)),
    ];

    final verticalScrollController = ScrollController();
    final horizontalScrollController = ScrollController();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('drivers').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
              child: Text('Something went wrong'.tr,
                  style: const TextStyle(
                      color: Colors.red,
                      fontSize: 25,
                      fontWeight: FontWeight.bold)));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
              child: Text('No clients available'.tr,
                  style: const TextStyle(
                      color: Colors.red,
                      fontSize: 25,
                      fontWeight: FontWeight.bold)));
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: active.withOpacity(.4), width: .5),
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, 6),
                color: lightGray.withOpacity(.1),
                blurRadius: 12,
              ),
            ],
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 30),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    "show Drivers".tr,
                    style: const TextStyle(
                        fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 90,
                    child: MaterialButton(
                      height: 45,
                      color: Colors.blue,
                      child: Text(
                        " Back".tr,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  SizedBox(
                    height: 70,
                    width: 650,
                    child: searchBarWidgets(),
                  ),
                ],
              ),
              Expanded(
                child: AdaptiveScrollbar(
                  underColor: Colors.blueGrey.withOpacity(0.3),
                  sliderDefaultColor: active.withOpacity(0.7),
                  sliderActiveColor: active,
                  controller: verticalScrollController,
                  child: AdaptiveScrollbar(
                    controller: horizontalScrollController,
                    position: ScrollbarPosition.bottom,
                    underColor: lightGray.withOpacity(0.3),
                    sliderDefaultColor: active.withOpacity(0.7),
                    sliderActiveColor: active,
                    width: 13.0,
                    sliderHeight: 300,
                    child: SingleChildScrollView(
                      controller: verticalScrollController,
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        controller: horizontalScrollController,
                        scrollDirection: Axis.horizontal,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DataTable(
                            columns: columns,
                            rows: _displayedUsers.map(
                              (user) {
                                aa = user.id;
                                return DataRow(cells: [
                                  DataCell(Text(
                                      ((_currentPage - 1) * _itemsPerPage +
                                              _displayedUsers.indexOf(user) +
                                              1)
                                          .toString())),
                                  DataCell(CustomText(
                                      text: user['userName'] as String)),
                                  DataCell(Directionality(
                                      textDirection: ui.TextDirection.ltr,
                                      child: CustomText(
                                          text: user['rating'].toString()))),
                                  DataCell(Directionality(
                                      textDirection: ui.TextDirection.ltr,
                                      child: CustomText(
                                          text: "${user['balance']}"))),
                                  DataCell(StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection("services")
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      }

                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Text('Loading...'.tr);
                                      }

                                      if (snapshot.hasData &&
                                          snapshot.data!.docs.isNotEmpty) {
                                        List<DocumentSnapshot> services =
                                            snapshot.data!.docs;
                                        List<String> serviceNames = services
                                            .map((doc) =>
                                                (doc['name'] as String))
                                            .toList();

                                        String? currentDriverService =
                                            user['service'].toString();
                                        String? dropdownValue =
                                            currentDriverService.isNotEmpty &&
                                                    serviceNames.contains(
                                                        currentDriverService)
                                                ? currentDriverService
                                                : null;

                                        return DropdownButton<String>(
                                          value: dropdownValue,
                                          hint: Text('choose service'.tr),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              updateUserService(
                                                  user.id, newValue ?? "");
                                            });
                                            navigationController
                                                .navigateToDriverview(
                                                    index: _currentPage);
                                          },
                                          items: [
                                            DropdownMenuItem<String>(
                                              value: "",
                                              child: Text('choose service'.tr),
                                            ),
                                            ...serviceNames
                                                .map<DropdownMenuItem<String>>(
                                                    (value) {
                                              return DropdownMenuItem<String>(
                                                value: value.toString(),
                                                child: Text(value.toString()),
                                              );
                                            }),
                                          ],
                                        );
                                      } else {
                                        return Text('No services found'.tr);
                                      }
                                    },
                                  )),
                                  DataCell(
                                    //   CustomText(
                                    //   text: user['phoneNumber'] ?? 'N/A',
                                    // )

                                    InkWell(
                                      onTap: () {
                                        Clipboard.setData(ClipboardData(
                                            text: user['phoneNumber']
                                                .toString())); // نسخ النص إلى الحافظة
                                        Get.snackbar(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 50),
                                          "Copied to clipboard!".tr,
                                          "Phone number copied to clipboard".tr,
                                          snackPosition: SnackPosition.TOP,
                                          backgroundColor: Colors.blue[300],
                                          duration: const Duration(seconds: 2),
                                        );
                                      },
                                      child: Row(children: [
                                        CustomText(
                                          text: user['phoneNumber'].toString(),
                                        ),
                                      ]),
                                    ),
                                  ),
                                  DataCell(
                                    //   CustomText(
                                    //   text: user['phoneNumber'] ?? 'N/A',
                                    // )

                                    InkWell(
                                      onTap: () {
                                        Clipboard.setData(ClipboardData(
                                            text: user
                                                .id)); // نسخ النص إلى الحافظة
                                        Get.snackbar(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 50),
                                          "Copied to clipboard!".tr,
                                          "Phone number copied to clipboard".tr,
                                          snackPosition: SnackPosition.TOP,
                                          backgroundColor: Colors.blue[300],
                                          duration: const Duration(seconds: 2),
                                        );
                                      },
                                      child: Row(children: [
                                        CustomText(
                                          text: user.id,
                                        ),
                                      ]),
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      children: [
                                        DropdownButton<bool>(
                                          value: user['isVerified'] as bool,
                                          items: [
                                            DropdownMenuItem(
                                              value: true,
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.verified,
                                                      color: Colors.green),
                                                  const SizedBox(width: 10),
                                                  Text("Verified".tr),
                                                ],
                                              ),
                                            ),
                                            DropdownMenuItem(
                                              value: false,
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.close,
                                                      color: Colors.red),
                                                  const SizedBox(width: 10),
                                                  Text("Unverified".tr),
                                                ],
                                              ),
                                            ),
                                          ],
                                          onChanged: (value) {
                                            setState(() {
                                              user.data()['status'] =
                                                  value!.toString();
                                              if (value == true) {
                                                _approveDriver(
                                                    user.id,
                                                    user['userName']
                                                        .toString());
                                              } else {
                                                final TextEditingController
                                                    reasonController =
                                                    TextEditingController();
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text(
                                                          'Reject Driver'.tr),
                                                      content: TextField(
                                                        controller:
                                                            reasonController,
                                                        decoration:
                                                            InputDecoration(
                                                          labelText:
                                                              'Rejection Reason'
                                                                  .tr,
                                                        ),
                                                      ),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          child:
                                                              Text('Cancel'.tr),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        ),
                                                        TextButton(
                                                          child: Text(
                                                              'Confirm'.tr),
                                                          onPressed: () async {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            await _rejectDriver(
                                                                user.id,
                                                                user['userName']
                                                                    .toString(),
                                                                reasonController
                                                                    .text
                                                                    .trim());
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              }
                                            });

                                            navigationController
                                                .navigateToDriverview(
                                                    index: _currentPage);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  DataCell(Container(
                                    height: 30,
                                    //  width: 100,
                                    width: double.infinity,
                                    padding: const EdgeInsets.only(top: 3),

                                    decoration: BoxDecoration(
                                        color: user['isOnline'] == true
                                            ? Colors.green
                                            : Colors.red,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Center(
                                      child: Text(
                                        " ${user['isOnline'] == true ? "online".tr : "offline".tr} ",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ),
                                  )),
                                  DataCell(Container(
                                    height: 30,
                                    //  width: 100,
                                    width: double.infinity,
                                    padding: const EdgeInsets.only(top: 3),

                                    decoration: BoxDecoration(
                                        color: user['isDeleted'] == false
                                            ? Colors.green
                                            : Colors.red,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Center(
                                      child: Text(
                                        " ${user['isDeleted'] == true ? "Deleted".tr : "Exist".tr} ",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ),
                                  )),
                                  DataCell(Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                            Icons.remove_red_eye_outlined),
                                        onPressed: () {
                                          _showUserDetailsDialog(
                                              context,
                                              user['userName'].toString(),
                                              user["rating"] as double,
                                              user["isOnline"] as bool,
                                              user["isVerified"] as bool,
                                              user["service"].toString(),
                                              user["phoneNumber"].toString(),
                                              user["totalRide"] as int,
                                              user["createdAt"] as Timestamp,
                                              user["balance"] as double);
                                        },
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      ),

                                      IconButton(
                                        icon: const Icon(Icons.edit_document,
                                            color: Colors.green),
                                        onPressed: () {
                                          //sized box
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return StreamBuilder<
                                                  QuerySnapshot>(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection('drivers')
                                                    .doc(user.id)
                                                    .collection("documents")
                                                    .snapshots(),
                                                builder: (context,
                                                    AsyncSnapshot<QuerySnapshot>
                                                        snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.active) {
                                                    if (snapshot.hasError) {
                                                      return AlertDialog(
                                                        title: Text('Error'.tr),
                                                      );
                                                    }
                                                    if (snapshot.hasData &&
                                                        snapshot.data != null) {
                                                      List<DocumentSnapshot>
                                                          documents =
                                                          snapshot.data!.docs;
                                                      return AlertDialog(
                                                        content:
                                                            SingleChildScrollView(
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: documents
                                                                .map(
                                                                    (document) {
                                                              return Row(
                                                                  children: [
                                                                    InkWell(
                                                                      onTap:
                                                                          () {
                                                                        showDialog(
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (BuildContext context) {
                                                                              return AlertDialog(
                                                                                content: Image.network(
                                                                                  document['image'].toString(),
                                                                                  fit: BoxFit.cover,
                                                                                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                                                                    if (loadingProgress == null) {
                                                                                      return child;
                                                                                    }
                                                                                    return Center(
                                                                                      child: CircularProgressIndicator(
                                                                                        value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1) : null,
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                  errorBuilder: (context, error, stackTrace) {
                                                                                    return const Icon(Icons.warning_amber);
                                                                                  },
                                                                                ),
                                                                              );
                                                                            });
                                                                      },
                                                                      child: Image
                                                                          .network(
                                                                        document['image']
                                                                            .toString(),
                                                                        height:
                                                                            300,
                                                                        width:
                                                                            300,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        loadingBuilder: (BuildContext context,
                                                                            Widget
                                                                                child,
                                                                            ImageChunkEvent?
                                                                                loadingProgress) {
                                                                          if (loadingProgress ==
                                                                              null) {
                                                                            return child;
                                                                          }
                                                                          return Center(
                                                                            child:
                                                                                CircularProgressIndicator(
                                                                              value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1) : null,
                                                                            ),
                                                                          );
                                                                        },
                                                                        errorBuilder: (context,
                                                                            error,
                                                                            stackTrace) {
                                                                          return const Icon(
                                                                              Icons.warning_amber);
                                                                        },
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            20),
                                                                    Text(document['status'] ==
                                                                            true
                                                                        ? 'Verified      '
                                                                        : 'Rejected      '),
                                                                    Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        IconButton(
                                                                          icon:
                                                                              const Icon(Icons.check_circle_outline),
                                                                          color:
                                                                              Colors.green,
                                                                          onPressed:
                                                                              () {
                                                                            // Logic for approving the document
                                                                            updateDocumentStatus(
                                                                                document.id,
                                                                                user.id,
                                                                                true,
                                                                                user['userName']);
                                                                          },
                                                                        ),
                                                                        IconButton(
                                                                          icon:
                                                                              const Icon(Icons.cancel),
                                                                          color:
                                                                              Colors.red,
                                                                          onPressed:
                                                                              () {
                                                                            // Logic for rejecting the document
                                                                            updateDocumentStatus(
                                                                                document.id,
                                                                                user.id,
                                                                                false,
                                                                                user['userName']);
                                                                          },
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          20,
                                                                    ),
                                                                  ]);
                                                            }).toList(),
                                                          ),
                                                        ),
                                                      );
                                                    } else {
                                                      return const AlertDialog(
                                                        title:
                                                            Text('Loading...'),
                                                      );
                                                    }
                                                  } else {
                                                    return const AlertDialog(
                                                      title: Center(
                                                          child:
                                                              CircularProgressIndicator()),
                                                    );
                                                  }
                                                },
                                              );
                                            },
                                          );
                                        },
                                      ), // IconButton(
                                    ],
                                  )),
                                ]);
                              },
                            ).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              // Pagination
              ////////////////////////////////////////////////////////

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Previous Page Button
                  MaterialButton(
                    onPressed: _currentPage > 1
                        ? () {
                            setState(() {
                              _currentPage--;
                              _updateDisplayedUsers();
                            });
                          }
                        : null,
                    child: Column(
                      children: [
                        Text("Previous Page".tr),
                        const Icon(Icons.arrow_back_ios)
                      ],
                    ),
                  ),

                  // Page Number Display
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Page $_currentPage of ${(_allUsers.length / _itemsPerPage).ceil()}'
                          .tr,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),

                  // Next Page Button
                  MaterialButton(
                    onPressed: _currentPage <
                            ((_allUsers.length / _itemsPerPage).ceil())
                        ? () {
                            setState(() {
                              _currentPage++;
                              _updateDisplayedUsers();
                            });
                          }
                        : null,
                    child: Column(
                      children: [
                        Text("Next Page".tr),
                        const Icon(Icons.arrow_forward_ios)
                      ],
                    ),
                  ),
                ],
              ),
////////////////////////////////////////////////////////
            ],
          ),
        );
      },
    );
  }

  Future<void> updateUserService(String userId, String newService) async {
    try {
      await FirebaseFirestore.instance
          .collection('drivers')
          .doc(userId)
          .update({
        'service': newService,
      });
      ('Service updated successfully');
    } catch (e) {
      ('Failed to update service: $e');
    }
  }

  // Future<String> getImageUrl(String imagePath) async {
  //   try {
  //     final ref = FirebaseStorage.instance.ref().child('documents/$imagePath');
  //     final url = await ref.getDownloadURL();
  //     return url;
  //   } catch (e) {
  //     throw Exception('Failed to load image');
  //   }
  // }
}

void _showUserDetailsDialog(
    BuildContext context,
    String userName,
    double rating,
    bool isOnline,
    bool isVerified,
    String Service,
    String phoneNumber,
    int totalRide,
    Timestamp createTime,
    double balance) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          children: [
            Text("User Name: ".tr,
                style: const TextStyle(fontSize: 24, color: Colors.black)),
            Text(userName,
                style: const TextStyle(fontSize: 20, color: Colors.blue)),
          ],
        ),
        content: SingleChildScrollView(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text("balance: ".tr,
                    style: const TextStyle(fontSize: 20, color: Colors.black)),
                Directionality(
                    textDirection: ui.TextDirection.ltr,
                    child: Text("$balance",
                        style:
                            const TextStyle(fontSize: 16, color: Colors.blue))),
              ],
            ),
            Row(
              children: [
                Text("isOnline: ".tr,
                    style: const TextStyle(fontSize: 20, color: Colors.black)),
                Text("$isOnline",
                    style: const TextStyle(fontSize: 16, color: Colors.blue)),
              ],
            ),
            Row(
              children: [
                Text("Phone Number: ".tr,
                    style: const TextStyle(fontSize: 20, color: Colors.black)),
                Text(phoneNumber,
                    style: const TextStyle(fontSize: 16, color: Colors.blue)),
              ],
            ),
            Row(
              children: [
                Text("isVerified: ".tr,
                    style: const TextStyle(fontSize: 20, color: Colors.black)),
                Text("$isVerified",
                    style: const TextStyle(fontSize: 16, color: Colors.blue)),
              ],
            ),
            Row(
              children: [
                Text("Rating: ".tr,
                    style: const TextStyle(fontSize: 20, color: Colors.black)),
                Directionality(
                    textDirection: ui.TextDirection.ltr,
                    child: Text("$rating",
                        style:
                            const TextStyle(fontSize: 16, color: Colors.blue))),
              ],
            ),
            Row(
              children: [
                Text("Service: ".tr,
                    style: const TextStyle(fontSize: 20, color: Colors.black)),
                Text(Service,
                    style: const TextStyle(fontSize: 16, color: Colors.blue)),
              ],
            ),
            Row(
              children: [
                Text("Total Ride: ".tr,
                    style: const TextStyle(fontSize: 20, color: Colors.black)),
                Text("$totalRide",
                    style: const TextStyle(fontSize: 16, color: Colors.blue)),
              ],
            ),
            Row(
              children: [
                Text("Create Time: ".tr,
                    style: const TextStyle(fontSize: 20, color: Colors.black)),
                Text(DateFormat('yyyy-MM-dd HH:mm').format(createTime.toDate()),
                    style: const TextStyle(fontSize: 16, color: Colors.blue)),
              ],
            ),
          ],
        )),
        actions: <Widget>[
          TextButton(
            child: Text("Close".tr,
                style: const TextStyle(fontSize: 20)), // زيادة حجم الخط
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
