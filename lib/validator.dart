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

  String message(T value, String property);

  bool isValid(T value);

  ValidatorError validate(T value, [String property]) {
    if (isValid(value)) {
      return null;
    }

    return ValidatorError(
      property: property,
      value: value,
      messages: {
        name: message(value, property),
      },
    );
  }
}

@immutable
class ValidatorError extends Error {
  static bool includeTarget = false;

  ValidatorError({
    this.property,
    this.value,
    this.messages,
    this.target,
    this.children,
  });

  final dynamic target;

  final String property;

  final dynamic value;

  final Map<String, String> messages;

  final List<ValidatorError> children;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (includeTarget && target != null) 'target': target,
      if (property != null) 'property': property,
      if (value != null) 'value': value,
      if (messages != null) 'messages': messages,
      if (children != null) 'children': children,
    };
  }
}
