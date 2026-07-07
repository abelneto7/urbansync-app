import '../entities/interdicao.dart';

class InterdicaoSaveResponse {
  final Interdicao interdicao;
  final String message;

  const InterdicaoSaveResponse({required this.interdicao, required this.message});
}
