import 'package:fluttertoast/fluttertoast.dart';
import 'package:githun_account/config/config.dart';

class Utils {
  static void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: btnBg,
      textColor: textColor,
    );
  }
}
