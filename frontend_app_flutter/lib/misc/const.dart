// ignore_for_file: constant_identifier_names
// Re-exports from core/constants for backwards compatibility.
// New code should import 'package:frontend_app_flutter/core/constants/app_constants.dart' directly.
import 'package:frontend_app_flutter/core/constants/app_constants.dart';
export 'package:frontend_app_flutter/core/constants/app_constants.dart'
    show HexColor, mainColor, secondaryColor, thirdColor, txtColMain, txtColSec;

// Legacy constants kept for compatibility with existing screens
const String Google_Maps_Api_key = AppConstants.googleMapsApiKey;
const String Api_Link = AppConstants.apiBaseUrl;
const Profile_Image = 'https://source.unsplash.com/random/1080x1080/?man';
const profile_image = 'assets/images/profile_pic.jpeg';
