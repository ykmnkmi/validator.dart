library validator;

import 'package:meta/meta.dart';

part 'src/comparable.dart';
part 'src/string.dart';
part 'src/type.dart';

@immutable
abstract class Validator<T> {
  @literal
  const Validator();

  String get name;

  String message(T value, [String? property]);

  bool isValid(T value);

  ValidatorError? validate(T value, [String? property]) {
    if (isValid(value)) {
      return null;
    }

    return ValidatorError(
      property: property,
      value: value,
      constraints: <String, String>{
        name: message(value, property),
      },
    );
  }
}

@immutable
class ValidatorError implements Exception {
  static bool includeTarget = false;

  const ValidatorError({this.property, this.value, this.constraints, this.target, this.children});

  final Object? target;

  final String? property;

  final Object? value;

  final Map<String, String>? constraints;

  final List<ValidatorError>? children;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      if (includeTarget && target != null) 'target': target,
      if (property != null) 'property': property,
      if (value != null) 'value': value,
      if (constraints != null) 'constraints': constraints,
      if (children != null) 'children': children,
    };
  }
}
