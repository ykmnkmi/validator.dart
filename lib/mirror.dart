library mirror;

import 'dart:mirrors';

import 'package:meta/meta.dart';

import 'validator.dart';

// type [property : [validator]]
final _container = <Type, Validator>{};

Validator<T> getValidatorFor<T>() {
  if (_container.containsKey(T)) {
    return _container[T] as Validator<T>;
  }

  final clazz = reflectClass(T);
  final declarations = clazz.declarations;
  final members = clazz.instanceMembers;

  final validators = <PropertyValidator>[];

  for (final symbol in clazz.declarations.keys) {
    if (symbol == #hashCode || symbol == #runtimeType || symbol == #toString) {
      continue;
    }

    final meta = declarations[symbol].metadata;
    final member = members[symbol];

    if (meta.isNotEmpty && member.isGetter && !member.isStatic) {
      validators.add(PropertyValidator(
          symbol,
          meta
              .map((m) => m.reflectee)
              .whereType<Validator>()
              .toList(growable: false)));
    }
  }

  return ClassValidator<T>(validators);
}

@immutable
class PropertyValidator extends Validator {
  PropertyValidator(this.property, this.validators);

  final Symbol property;

  final List<Validator> validators;

  @override
  String get name {
    return MirrorSystem.getName(property);
  }

  @override
  String message(Object value, String property) {
    throw UnimplementedError();
  }

  @override
  bool isValid(Object value) {
    var result = true;

    for (final validator in validators) {
      result &= validator.isValid(value);
    }

    return result;
  }

  @override
  ValidatorError validate(dynamic target, [String property]) {
    final messages = <String, String>{};
    final field = reflect(target).getField(this.property);
    final value = field.reflectee as dynamic;
    property = MirrorSystem.getName(this.property);

    for (final validator in validators) {
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

    for (final validator in validators) {
      result &= validator.isValid(value);
    }

    return result;
  }

  @override
  ValidatorError validate(T value, [String property]) {
    final children = <ValidatorError>[];

    for (final validator in validators) {
      final error = validator.validate(value);

      if (error == null) {
        continue;
      }

      children.add(error);
    }

    return ValidatorError(value: this, children: children);
  }
}

List<ValidatorError> validate<T>(T value) {
  final validator = getValidatorFor<T>();

  if (validator == null) {
    throw Exception('validator for <$T> not found');
  }

  final error = validator.validate(value);

  if (error == null) {
    return null;
  }

  return error.children;
}

bool isValid<T>(T value) {
  final validator = getValidatorFor<T>();

  if (validator == null) {
    throw Exception('validator for <$T> not found');
  }

  return validator.isValid(value);
}
