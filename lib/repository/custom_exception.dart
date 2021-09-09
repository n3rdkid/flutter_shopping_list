import 'package:hooks_riverpod/hooks_riverpod.dart';

class CustomException implements Exception {
  String? message;
  CustomException({this.message = "Something went wrong!"});
  @override
  String toString() => "Custom Exception :: ${message}";
}
