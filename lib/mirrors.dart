library mirror;

import 'dart:mirrors';

import 'package:meta/meta.dart';

import 'validator.dart';

final _container = <Type, Validator>{};

Validator<T> getValidatorFor<T>() {
  if (_container.containsKey(T)) {
    return _container[T] as Validator<T>;
  }

  final clazz = reflectClass(T);
  final declarations = clazz.declarations;
  final members = clazz.instanceMembers;

  final validators = <Symbol, List<Validator<Object?>>>{};

  for (final symbol in clazz.declarations.keys) {
    if (symbol == #hashCode || symbol == #runtimeType || symbol == #toString) {
      continue;
    }

    final meta = declarations[symbol]!.metadata;

    if (meta.isNotEmpty) {
      final member = members[symbol];

      if (member != null && member.isGetter && !member.isStatic) {
        final propertyValidators = meta
            .map<Object?>((m) => m.reflectee)
            .whereType<Validator<Object?>>()
            .toList(growable: false);
        validators[symbol] = propertyValidators;
      }
    }
  }

  return _container[T] = ClassValidator<T>(validators);
}

@immutable
class ClassValidator<T> extends Validator<T> {
  @literal
  const ClassValidator(this.validators);

  final Map<Symbol, List<Validator<Object?>>> validators;

  @override
  String get name {
    throw UnimplementedError();
  }

  @override
  String message(T value, [String? property]) {
    throw UnimplementedError();
  }

  @override
  bool isValid(T value) {
    var result = true;

    validators.forEach((symbol, validators) {
      final valueMirror = reflect(value);
      final fieldMirror = valueMirror.getField(symbol);
      final field = fieldMirror.reflectee as Object?;

      for (final validator in validators) {
        result &= validator.isValid(field);
      }
    });

    return result;
  }

  @override
  ValidatorError validate(T value, [String? property]) {
    final children = <ValidatorError>[];

    final valueMirror = reflect(value);

    validators.forEach((symbol, validators) {
      final property = MirrorSystem.getName(symbol);
      final fieldMirror = valueMirror.getField(symbol);
      final field = fieldMirror.reflectee as Object?;

      for (final validator in validators) {
        final error = validator.validate(field, property);

        if (error == null) {
          continue;
        }

        children.add(error);
      }
    });

    return ValidatorError(value: this, children: children);
  }
}

List<ValidatorError>? validate<T>(T value) {
  final error = getValidatorFor<T>().validate(value);

  if (error == null) {
    return null;
  }

  return error.children;
}

bool isValid<T>(T value) {
  return getValidatorFor<T>().isValid(value);
}
