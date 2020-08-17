library mirror;

import 'dart:mirrors';

import 'package:meta/meta.dart';

import 'validator.dart';

// type [property : [validator]]
final container = <Type, Validator>{};

Validator<T> getValidatorFor<T>() {
  if (container.containsKey(T)) {
    return container[T] as Validator<T>;
  }

  final clazz = reflectClass(T);
  final declarations = clazz.declarations;
  final members = clazz.instanceMembers;

  final validators = <PropertyValidator>[];

  for (var symbol in clazz.declarations.keys) {
    if (symbol == #hashCode || symbol == #runtimeType) {
      continue;
    }

    final meta = declarations[symbol].metadata;

    if (meta.isNotEmpty && !members[symbol].isStatic) {
      validators.add(PropertyValidator(
          symbol,
          meta
              .map<Object>((InstanceMirror m) => m.reflectee)
              .whereType<Validator<Object>>()
              .toList(growable: false)));
    }
  }

  return ClassValidator<T>(validators);
}

@immutable
class PropertyValidator extends Validator<Object> {
  PropertyValidator(this.property, this.validators);

  final Symbol property;

  final List<Validator<Object>> validators;

  @override
  String get name => MirrorSystem.getName(property);

  @override
  String message(Object value, String property) {
    throw UnimplementedError();
  }

  @override
  bool isValid(Object value) {
    var result = true;

    for (var validator in validators) {
      result &= validator.isValid(value);
    }

    return result;
  }

  @override
  ValidatorError validate(Object target, [String property]) {
    final messages = <String, String>{};
    final field = reflect(target).getField(this.property);
    final value = field.reflectee as Object;
    property = MirrorSystem.getName(this.property);

    for (var validator in validators) {
      if (validator.isValid(value)) {
        messages[validator.name] = validator.message(value, property);
      }
    }

    if (messages.isEmpty) {
      return null;
    }

    return ValidatorError(
      target: target,
      property: property,
      value: value,
      messages: messages,
    );
  }
}

@immutable
class ClassValidator<T> extends Validator<T> {
  ClassValidator(this.validators);

  final List<PropertyValidator> validators;

  @override
  String get name {
    throw UnimplementedError();
  }

  @override
  String message(T value, String property) {
    throw UnimplementedError();
  }

  @override
  bool isValid(T value) {
    var result = true;

    for (var validator in validators) {
      result &= validator.isValid(value);
    }

    return result;
  }

  @override
  ValidatorError validate(T value, [String property]) {
    final children = <ValidatorError>[];

    for (var validator in validators) {
      final error = validator.validate(value);

      if (error != null) {
        children.add(error);
      }
    }

    return ValidatorError(
      value: this,
      children: children,
    );
  }
}

List<ValidatorError> validate<T>(T value) {
  final error = getValidatorFor<T>()?.validate(value);
  return error?.children;
}
