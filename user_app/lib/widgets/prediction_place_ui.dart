import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_app/appInfo/app_info.dart';
import 'package:user_app/global/global_var.dart';
import 'package:user_app/models/address_model.dart';
import 'package:user_app/models/prediction_model.dart';

import '../methods/common_methods.dart';
import 'loading_dialog.dart';

class PredictionPlaceUI extends StatefulWidget {
  PredictionModel? predictedPlaceData;

  PredictionPlaceUI({super.key, this.predictedPlaceData});

  @override
  State<PredictionPlaceUI> createState() => _PredictionPlaceUIState();
}

class _PredictionPlaceUIState extends State<PredictionPlaceUI> {
  //Place Details - Places API
  fetchClickedDetails(String placeID) async{
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => LoadingDialog(messageText: "Getting Details ..."),
    );
    
    String urlPlaceDetailsAPI = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeID&key=$googleMAPKEY";

    var responseFromPlacesDetailsApi = await CommonMethods.sendRequestToAPI(urlPlaceDetailsAPI);

    Navigator.pop(context);

    if(responseFromPlacesDetailsApi == "error"){
      return;
    }
    if(responseFromPlacesDetailsApi["status"] == "OK"){
      AddressModel dropOffLocation = AddressModel();

      dropOffLocation.placeName = responseFromPlacesDetailsApi["result"]["name"];
      dropOffLocation.latitudePosition = responseFromPlacesDetailsApi["result"]["geometry"]["location"]["lat"];
      dropOffLocation.longitudePosition = responseFromPlacesDetailsApi["result"]["geometry"]["location"]["lng"];
      dropOffLocation.placeID = placeID;

      Provider.of<AppInfo>(context, listen: false).updateDropOffLocation(dropOffLocation);

      Navigator.pop(context, "placeSelected");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (){
        fetchClickedDetails(widget.predictedPlaceData!.place_id.toString());
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
      ),
      child: SizedBox(
        child: Column(
          children: [

            const SizedBox(height: 5,),

            Row(
              children: [
                const Icon(
                  Icons.share_location,
                  color: Colors.grey,
                ),

                const SizedBox(width: 13,),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [

                      Text(
                        widget.predictedPlaceData!.main_text.toString(),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 3,),

                      Text(
                        widget.predictedPlaceData!.secondary_text.toString(),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),

                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10,),

          ],
        ),
      ),
    );
  }
}
