// ignore_for_file: constant_identifier_names
import 'package:flutter/material.dart';

const String Google_Maps_Api_key = "AIzaSyAFifret1S_CkgBUs1MyMg-0_QMoFKzn9I";
const String Api_Link = "https://backend.prometheansempiremedia.com";
// const String Api_Link = "https://trackme.cyclic.app/";
const Profile_Image = 'https://source.unsplash.com/random/1080x1080/?man';

const profile_image = 'assets/images/profile_pic.jpeg';

// const mainColor = Color.fromRGBO(14, 116, 57, 1);
// const secondaryColor = Color.fromRGBO(47, 165, 97, 1);

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

//
final Color mainColor = HexColor("#FFD700");
final Color secondaryColor = HexColor("#ED2939");
final Color thirdColor = HexColor("#08203e");

final Color txtColMain = HexColor("#d3f3f1");
final Color txtColSec = HexColor("#e9b7ce");
