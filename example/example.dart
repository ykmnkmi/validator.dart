import 'dart:convert';

import 'package:validator/validator.dart';
import 'package:validator/mirrors.dart';

class Post {
  @Length(10, 20)
  String? title;

  @Contains('hello')
  String? text;

  @Min(0)
  @Max(10)
  int? rating;

  @IsEmail()
  String? email;

  @IsFQDN()
  String? site;

  @IsDateTime()
  DateTime? createDate;
}

void main() {
  final post = Post()
    ..title = 'Hello'
    ..text = 'this is a great post about hell world'
    ..rating = 11
    ..email = 'google.com'
    ..site = 'google.com';
  print(const JsonEncoder.withIndent('  ').convert(validate(post)));
}
