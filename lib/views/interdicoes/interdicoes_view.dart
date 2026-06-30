import 'package:flutter/material.dart';
import '../../models/entities/interdicao.dart';
import '../../shared/utils/app_colors.dart';
import '../../shared/utils/snackbar_utils.dart';
import '../global_widgets/app_text.dart';
import '../global_widgets/interdicao_card.dart';
import '../../viewmodels/interdicoes_viewmodel.dart';
import '../../viewmodels/cadastro_interdicao_viewmodel.dart';
import '../../models/repositories/interdicao_repository.dart';
import '../../models/services/interdicao_service.dart';
import '../cadastro_interdicao/cadastro_interdicao_view.dart';

class InterdicoesView extends StatefulWidget {
  final String token;
  final InterdicoesViewModel viewModel;

  const InterdicoesView({
    super.key,
    required this.token,
    required this.viewModel,
  });

  @override
  State<InterdicoesView> createState() => _InterdicoesViewState();
}

class _InterdicoesViewState extends State<InterdicoesView> {
  @override
  void initState() {
    super.initState();
    _carregarInterdicoes();
  }

  Future<void> _carregarInterdicoes() async {
    await widget.viewModel.carregarInterdicoes(widget.token);
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
      final message = await widget.viewModel.removerInterdicao(widget.token, interdicao);
      if (mounted && message != null) {
        SnackbarUtils.showSuccess(context, message);
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Erro: $e');
      }
    }
  }

  Future<void> _irParaCadastro() async {
    // Ponto de navegação: monta o ViewModel com o Repository correto.
    final resultado = await Navigator.of(context).push<Interdicao>(
      MaterialPageRoute(
        builder: (_) => CadastroInterdicaoView(
          token: widget.token,
          viewModel: CadastroInterdicaoViewModel(InterdicaoRepository(InterdicaoService())),
        ),
      ),
    );

    if (resultado != null) {
      widget.viewModel.adicionarInterdicaoLocal(resultado);
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
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        if (widget.viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.accent));
        }

        if (widget.viewModel.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off_rounded, color: AppColors.textMuted, size: 48),
                const SizedBox(height: 16),
                AppText.corpo(widget.viewModel.errorMessage!),
                ElevatedButton(
                  onPressed: _carregarInterdicoes,
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }

        if (widget.viewModel.interdicoes.isEmpty) {
          return const Center(
            child: AppText.corpo('Nenhuma interdição cadastrada.', color: AppColors.textMuted),
          );
        }

        return RefreshIndicator(
          onRefresh: _carregarInterdicoes,
          color: AppColors.accent,
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80, top: 12),
            itemCount: widget.viewModel.interdicoes.length,
            itemBuilder: (context, index) {
              final interdicao = widget.viewModel.interdicoes[index];
              return InterdicaoCard(
                interdicao: interdicao,
                onRemover: () => _removerInterdicao(interdicao),
              );
            },
          ),
        );
      },
    );
  }
}
