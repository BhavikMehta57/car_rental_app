class AppUser {
  String name;
  String bloodGroup;
  String licenseNumber;
  String phoneNumber;
  String age;
  String emailID;
  // String dpURL;
  bool hasCompleteProfile = false;
  String uuid;
  String ownAddress;

  AppUser();

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'bloodGroup': bloodGroup,
      'licenseNumber': licenseNumber,
      'phoneNumber': phoneNumber,
      'age': age,
      'emailID': emailID,
      // 'dpURL': dpURL,
      'hasCompletedProfile': hasCompleteProfile,
      'uuid': uuid,
      'ownAddress': ownAddress
    };
  }

  AppUser.fromMap(Map<String, dynamic> data) {
    name = data['name'];
    bloodGroup = data['bloodGroup'];
    licenseNumber = data['licenseNumber'];
    phoneNumber = data['phoneNumber'];
    age = data['age'];
    emailID = data['emailID'];
    // dpURL = data['dpURL'];
    hasCompleteProfile = data['hasCompleteProfile'];
    uuid = data['uuid'];
    ownAddress = data['ownAddress'];
  }
}

class VehicleUser {
  String vehicleId;
  String modelName;
  String vehicleNumber;
  String vehicleLoc;
  String vehicleLatitude;
  String vehicleLongitude;
  String ownerName;
  String color;
  String vehicleImg;
  String aadharNumber;
  bool hasCompletedRegistration = false;
  String amount;
  String ownerphoneNumber;
  String status;

  VehicleUser();

  Map<String, dynamic> toMap() {
    return {
      'vehicleId': vehicleId,
      'modelName': modelName,
      'vehicleNumber': vehicleNumber,
      'vehicleLocation': vehicleLoc,
      'vehicleLatitude': vehicleLatitude,
      'vehicleLongitude': vehicleLongitude,
      'ownerName': ownerName,
      'color': color,
      'vehicleImg' : vehicleImg,
      'aadharNumber': aadharNumber,
      'hasCompletedRegistration': hasCompletedRegistration,
      'amount': amount,
      'ownerphoneNumber': ownerphoneNumber,
      'status': status
    };
  }

  VehicleUser.fromMap(Map<String, dynamic> data) {
    vehicleId = data['vehicleId'];
    modelName = data['modelName'];
    vehicleNumber = data['vehicleNumber'];
    vehicleLoc = data['vehicleLocation'];
    vehicleLatitude = data['vehicleLatitude'];
    vehicleLongitude = data['vehicleLongitude'];
    ownerName = data['ownerName'];
    color = data['color'];
    vehicleImg = data['vehicleImg'];
    aadharNumber = data['aadharNumber'];
    hasCompletedRegistration = data['hasCompletedRegistration'];
    amount = data['amount'];
    ownerphoneNumber = data['ownerPhoneNumber'];
  }
}
