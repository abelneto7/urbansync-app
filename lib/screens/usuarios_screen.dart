import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../utils/app_colors.dart';
import '../widgets/app_text.dart';
import '../widgets/botao_remover.dart';
import 'cadastro_usuario_screen.dart';

class UsuariosScreen extends StatefulWidget {
  final String token;

  const UsuariosScreen({super.key, required this.token});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  final List<User> _usuarios = [];
  final _userService = UserService();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _carregarUsuarios();
  }

  Future<void> _carregarUsuarios() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final lista = await _userService.listar(widget.token);
      setState(() {
        _usuarios.clear();
        _usuarios.addAll(lista);
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
      final message = await _userService.remover(token: widget.token, id: usuario.id);
      setState(() {
        _usuarios.removeWhere((i) => i.id == usuario.id);
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
    final novoUser = await Navigator.of(context).push<User>(
      MaterialPageRoute(
        builder: (_) => CadastroUsuarioScreen(token: widget.token),
      ),
    );

    if (novoUser != null) {
      setState(() {
        _usuarios.insert(0, novoUser);
      });
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
            ElevatedButton(onPressed: _carregarUsuarios, child: const Text('Tentar novamente'))
          ],
        ),
      );
    }

    if (_usuarios.isEmpty) {
      return const Center(
        child: AppText.corpo('Nenhum usuário encontrado.', color: AppColors.textMuted),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarUsuarios,
      color: AppColors.accent,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80, top: 12),
        itemCount: _usuarios.length,
        itemBuilder: (context, index) {
          final usuario = _usuarios[index];
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
                  backgroundColor: AppColors.accent.withOpacity(0.2),
                  child: AppText.subtitulo(usuario.nome.substring(0, 1).toUpperCase(), color: AppColors.accent),
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
  }
}
