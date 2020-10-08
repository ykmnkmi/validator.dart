part of '../validator.dart';

class IsDateTime extends TypeValidation<DateTime> {
  @literal
  const IsDateTime() : super('DateTime', 'is_datetime');
}

class TypeValidation<T> extends Validator<Object?> {
  @literal
  const TypeValidation(this.type, [this.name = 'type']);

  @override
  final String name;

  final String type;

  @override
  String message(Object? value, [String? property]) {
    return '$property must be a $type instance';
  }

  @override
  bool isValid(Object? value) {
    return value is T;
  }
}
