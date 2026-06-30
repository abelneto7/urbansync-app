import 'package:flutter/material.dart';
import '../models/user.dart';
import '../utils/app_colors.dart';
import '../utils/snackbar_utils.dart';
import '../widgets/app_text.dart';
import '../widgets/botao_remover.dart';
import '../viewmodels/usuarios_viewmodel.dart';
import '../viewmodels/cadastro_usuario_viewmodel.dart';
import '../repositories/user_repository.dart';
import '../services/user_service.dart';
import 'cadastro_usuario_screen.dart';

class UsuariosScreen extends StatefulWidget {
  final String token;
  final UsuariosViewModel viewModel;

  const UsuariosScreen({
    super.key,
    required this.token,
    required this.viewModel,
  });

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  @override
  void initState() {
    super.initState();
    _carregarUsuarios();
  }

  Future<void> _carregarUsuarios() async {
    await widget.viewModel.carregarUsuarios(widget.token);
  }

  Future<void> _removerUsuario(User usuario) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const AppText.subtitulo('Remover usuário?'),
        content: AppText.corpo('Deseja remover "${usuario.nome}"?'),
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
      final message = await widget.viewModel.removerUsuario(widget.token, usuario);
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
    final novoUser = await Navigator.of(context).push<User>(
      MaterialPageRoute(
        builder: (_) => CadastroUsuarioScreen(
          token: widget.token,
          viewModel: CadastroUsuarioViewModel(UserRepository(UserService())),
        ),
      ),
    );

    if (novoUser != null) {
      widget.viewModel.adicionarUsuarioLocal(novoUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_usuarios',
        onPressed: _irParaCadastro,
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.person_add_rounded, color: AppColors.textOnAccent),
        label: const AppText('Novo', fontWeight: FontWeight.bold, color: AppColors.textOnAccent),
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
                  onPressed: _carregarUsuarios,
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }

        if (widget.viewModel.usuarios.isEmpty) {
          return const Center(
            child: AppText.corpo('Nenhum usuário encontrado.', color: AppColors.textMuted),
          );
        }

        return RefreshIndicator(
          onRefresh: _carregarUsuarios,
          color: AppColors.accent,
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80, top: 12),
            itemCount: widget.viewModel.usuarios.length,
            itemBuilder: (context, index) {
              final usuario = widget.viewModel.usuarios[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primaryLight),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.accent.withValues(alpha: 0.2),
                      child: AppText.subtitulo(
                        usuario.nome.substring(0, 1).toUpperCase(),
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText.subtitulo(usuario.nome, color: AppColors.textPrimary),
                          const SizedBox(height: 4),
                          AppText.pequeno(usuario.email, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                    BotaoRemover(
                      tooltip: 'Remover usuário',
                      onPressed: () => _removerUsuario(usuario),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
