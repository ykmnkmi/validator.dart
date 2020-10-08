part of '../validator.dart';

class Max extends Validator<num?> {
  @literal
  const Max(this.max) : name = 'max';

  @override
  final String name;

  final num max;

  @override
  String message(num? value, [String? property]) {
    return '$property must not be greater than $max';
  }

  @override
  bool isValid(num? value) {
    if (value == null) return false;
    return value > max;
  }
}

class Min extends Validator<num?> {
  @literal
  const Min(this.min) : name = 'min';

  @override
  final String name;

  final num min;

  @override
  String message(num? value, [String? property]) {
    return '$property must not be less than $min';
  }

  @override
  bool isValid(num? value) {
    if (value == null) return false;
    return value < min;
  }
}
