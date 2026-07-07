import 'package:flutter/material.dart';
import '../../models/entities/profile.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/ui_helpers/snackbar_helper.dart';
import '../shared_widgets/app_text_widget.dart';
import '../../viewmodels/perfil_viewmodel.dart';
import '../../shared/ui_helpers/can_access_widget.dart';
import 'form_perfil_view.dart';

class PerfisView extends StatefulWidget {
  final String token;
  final PerfilViewModel viewModel;

  const PerfisView({
    super.key,
    required this.token,
    required this.viewModel,
  });

  @override
  State<PerfisView> createState() => _PerfisViewState();
}

class _PerfisViewState extends State<PerfisView> {
  @override
  void initState() {
    super.initState();
    _carregarPerfis();
  }

  Future<void> _carregarPerfis() async {
    await widget.viewModel.loadProfiles(widget.token);
  }

  Future<void> _removerPerfil(Profile perfil) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const AppTextWidget.subtitulo('Remover perfil?'),
        content: AppTextWidget.corpo('Deseja remover "${perfil.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const AppTextWidget('Cancelar', color: AppColors.textSecondary),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const AppTextWidget('Remover', color: AppColors.error),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    try {
      final message = await widget.viewModel.deleteProfile(widget.token, perfil.id);
      if (mounted && message != null) {
        SnackbarHelper.showSuccess(context, message);
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, 'Erro: $e');
      }
    }
  }

  Future<void> _irParaFormulario({Profile? perfil}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FormPerfilView(
          token: widget.token,
          profile: perfil,
          viewModel: widget.viewModel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: CanAccessWidget(
        permission: 'ProfileController@store',
        child: FloatingActionButton.extended(
          heroTag: 'fab_perfis',
          onPressed: () => _irParaFormulario(),
          backgroundColor: AppColors.accent,
          icon: const Icon(Icons.add_rounded, color: AppColors.textOnAccent),
          label: const AppTextWidget(
            'Novo',
            fontWeight: FontWeight.bold,
            color: AppColors.textOnAccent,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        if (widget.viewModel.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          );
        }

        if (widget.viewModel.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off_rounded, color: AppColors.textMuted, size: 48),
                const SizedBox(height: 16),
                AppTextWidget.corpo(widget.viewModel.errorMessage!),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _carregarPerfis,
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }

        if (widget.viewModel.perfis.isEmpty) {
          return const Center(
            child: AppTextWidget.corpo('Nenhum perfil cadastrado.', color: AppColors.textMuted),
          );
        }

        return RefreshIndicator(
          onRefresh: _carregarPerfis,
          color: AppColors.accent,
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80, top: 12),
            itemCount: widget.viewModel.perfis.length,
            itemBuilder: (context, index) {
              final perfil = widget.viewModel.perfis[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primaryLight),
                  boxShadow: const [
                    BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 3)),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.accent.withValues(alpha: 0.15),
                    child: Icon(Icons.shield_outlined, color: AppColors.accent, size: 20),
                  ),
                  title: AppTextWidget.subtitulo(perfil.name, color: AppColors.textPrimary),
                  subtitle: perfil.description != null && perfil.description!.isNotEmpty
                      ? AppTextWidget.pequeno(perfil.description!, color: AppColors.textSecondary)
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CanAccessWidget(
                        permission: 'ProfileController@update',
                        child: IconButton(
                          icon: const Icon(Icons.edit_outlined, color: AppColors.accent, size: 20),
                          tooltip: 'Editar perfil',
                          onPressed: () => _irParaFormulario(perfil: perfil),
                        ),
                      ),
                      CanAccessWidget(
                        permission: 'ProfileController@destroy',
                        child: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                          tooltip: 'Remover perfil',
                          onPressed: () => _removerPerfil(perfil),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
