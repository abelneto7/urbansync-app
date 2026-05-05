import 'package:flutter/material.dart';
import '../models/interdicao.dart';
import '../services/interdicao_service.dart';
import '../utils/app_colors.dart';
import '../widgets/app_text.dart';
import '../widgets/interdicao_card.dart';
import 'cadastro_screen.dart';

class InterdicoesScreen extends StatefulWidget {
  final String token;

  const InterdicoesScreen({super.key, required this.token});

  @override
  State<InterdicoesScreen> createState() => _InterdicoesScreenState();
}

class _InterdicoesScreenState extends State<InterdicoesScreen> {
  final List<Interdicao> _interdicoes = [];
  final _interdicaoService = InterdicaoService();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _carregarInterdicoes();
  }

  Future<void> _carregarInterdicoes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final lista = await _interdicaoService.listar(widget.token);
      setState(() {
        _interdicoes.clear();
        _interdicoes.addAll(lista);
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _removerInterdicao(Interdicao interdicao) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const AppText.subtitulo('Remover interdição?'),
        content: AppText.corpo('Deseja remover "${interdicao.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const AppText('Cancelar', color: AppColors.textSecondary),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const AppText('Remover', color: AppColors.error),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      final message = await _interdicaoService.remover(token: widget.token, id: interdicao.id);
      setState(() {
        _interdicoes.removeWhere((i) => i.id == interdicao.id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AppText.corpo(message, color: AppColors.textOnAccent),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: AppText.corpo('Erro: $e', color: AppColors.error)),
        );
      }
    }
  }

  Future<void> _irParaCadastro() async {
    final resultado = await Navigator.of(context).push<Interdicao>(
      MaterialPageRoute(
        builder: (_) => CadastroScreen(token: widget.token),
      ),
    );

    if (resultado != null) {
      setState(() {
        _interdicoes.insert(0, resultado);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_interdicoes',
        onPressed: _irParaCadastro,
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add_rounded, color: AppColors.textOnAccent),
        label: const AppText('Nova', fontWeight: FontWeight.bold, color: AppColors.textOnAccent),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.accent));
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, color: AppColors.textMuted, size: 48),
            const SizedBox(height: 16),
            AppText.corpo(_errorMessage!),
            ElevatedButton(onPressed: _carregarInterdicoes, child: const Text('Tentar novamente'))
          ],
        ),
      );
    }

    if (_interdicoes.isEmpty) {
      return const Center(
        child: AppText.corpo('Nenhuma interdição cadastrada.', color: AppColors.textMuted),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarInterdicoes,
      color: AppColors.accent,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80, top: 12),
        itemCount: _interdicoes.length,
        itemBuilder: (context, index) {
          final interdicao = _interdicoes[index];
          return InterdicaoCard(
            interdicao: interdicao,
            onRemover: () => _removerInterdicao(interdicao),
          );
        },
      ),
    );
  }
}
