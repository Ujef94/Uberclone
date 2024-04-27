import 'package:flutter/cupertino.dart';
import 'package:user_app/models/address_model.dart';

class AppInfo extends ChangeNotifier{
  AddressModel? pickUpLocation;
  AddressModel? dropOffLocation;

  void updatePickUpLocation(AddressModel pickUpModel){
    pickUpLocation = pickUpModel;
    notifyListeners();
  }

  void updateDropOffLocation(AddressModel dropOffModel){
    dropOffLocation = dropOffModel;
    notifyListeners();
  }
}