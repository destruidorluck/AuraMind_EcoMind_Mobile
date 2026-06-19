class AppError implements Exception {
  AppError(this.message, {this.code, this.statusCode, this.details});

  final String message;
  final String? code;
  final int? statusCode;
  final Object? details;

  @override
  String toString() => message;
}

class UnauthorizedError extends AppError {
  UnauthorizedError([super.message = 'Sessao expirada. Faca login novamente.'])
      : super(code: 'unauthorized', statusCode: 401);
}

class ForbiddenError extends AppError {
  ForbiddenError([super.message = 'Sem permissao para esta acao.'])
      : super(code: 'forbidden', statusCode: 403);
}

class BackendOfflineError extends AppError {
  BackendOfflineError([super.message = 'Backend indisponivel no momento.'])
      : super(code: 'backend_offline');
}

class InvalidResponseError extends AppError {
  InvalidResponseError([super.message = 'Resposta invalida do servidor.'])
      : super(code: 'invalid_response');
}
