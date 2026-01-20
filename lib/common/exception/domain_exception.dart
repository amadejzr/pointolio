enum DomainErrorCode {
  notFound,
  storage,
  conflict,
  validation,
  unauthorized,
}

class DomainException implements Exception {
  const DomainException(this.code, {this.message, this.context, this.cause});

  final DomainErrorCode code;
  final String? message;
  final Map<String, Object?>? context;
  final Object? cause;

  @override
  String toString() => 'DomainException($code, $message, $context, $cause)';
}
