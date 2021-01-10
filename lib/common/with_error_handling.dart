import 'package:fluttertoast/fluttertoast.dart';

T withErrorHandling<T>(T f()) {
  try {
    return f();
  } catch (e) {
    Fluttertoast.showToast(msg: 'error: $e}');
  }
  return null;
}
