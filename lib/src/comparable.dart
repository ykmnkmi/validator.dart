part of '../validator.dart';

class Max extends Validator<num> {
  @literal
  const Max(this.max) : name = 'max';

  final num max;

  @override
  final String name;

  @override
  String message(num value, String property) {
    return '$property must not be greater than $max';
  }

  @override
  bool isValid(num value) {
    return value  > max;
  }
}

class Min extends Validator<num> {
  @literal
  const Min(this.min) : name = 'min';

  final num min;

  @override
  final String name;

  @override
  String message(num value, String property) {
    return '$property must not be less than $min';
  }

  @override
  bool isValid(num value) {
    return value < min;
  }
}
