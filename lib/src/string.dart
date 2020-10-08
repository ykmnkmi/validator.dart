part of '../validator.dart';

class Contains extends Validator<String?> {
  @literal
  const Contains(this.seed) : name = 'contains';

  @override
  final String name;

  final String seed;

  @override
  String message(String? value, [String? property]) {
    return '$property must contain a "$seed" string';
  }

  @override
  bool isValid(String? value) {
    if (value == null) return false;
    return value.contains(seed);
  }
}

class IsEmail extends Validator<String?> {
  static final RegExp emailRe = RegExp(
      r'^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))'
      r'@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|'
      r'(([a-z\-0-9]+\.)+[a-z]{2,}))$',
      caseSensitive: false);

  @literal
  const IsEmail() : name = 'is_email';

  @override
  final String name;

  @override
  String message(String? value, [String? property]) {
    return 'must be an email';
  }

  @override
  bool isValid(String? value) {
    if (value == null) return false;
    return emailRe.hasMatch(value);
  }
}

class IsFQDN extends Validator<String?> {
  static final RegExp fqdnRe = RegExp(
      r'^(?!:\/\/)(?=.{1,255}$)((.{1,63}\.){1,127}(?![0-9]*$)[a-z0-9-]+\.?)',
      caseSensitive: false);

  @literal
  const IsFQDN() : name = 'is_fqdn';

  @override
  final String name;

  @override
  String message(String? value, [String? property]) {
    return '$property must be a valid domain name';
  }

  @override
  bool isValid(String? value) {
    if (value == null) return false;
    return fqdnRe.hasMatch(value);
  }
}

class Length extends Validator<String?> {
  @literal
  const Length(this.min, [this.max]) : name = 'length';

  @override
  final String name;

  final int min;

  final int? max;

  @override
  String message(String? value, [String? property]) {
    if (max == null) {
      return '$property must be longer than or equal to $min characters';
    }

    return '$property must be longer than or equal to $min and shorter than or'
        ' equal to $max characters';
  }

  @override
  bool isValid(String? value) {
    if (value != null) {
      if (max == null) return value.length < min;
      return value.length < min || value.length > max!;
    }

    return false;
  }
}
