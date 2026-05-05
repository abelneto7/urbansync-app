import 'package:flutter/material.dart';
import '../models/interdicao.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/interdicao_service.dart';
import '../utils/app_colors.dart';
import '../widgets/app_text.dart';
import '../widgets/interdicao_card.dart';
import 'cadastro_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String token;
  final User usuario;

  const HomeScreen({
    super.key,
    required this.token,
    required this.usuario,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Interdicao> _interdicoes = [];

  final _interdicaoService = InterdicaoService();
  final _authService = AuthService();

  bool _isLoading = true;
  String? _errorMessage;

  int get _totalInterdicoes => _interdicoes.length;

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const AppText.subtitulo('Remover interdição?'),
        content: AppText.corpo(
          'Deseja remover "${interdicao.titulo}"? Esta ação não pode ser desfeita.',
        ),
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
      await _interdicaoService.remover(
          token: widget.token, id: interdicao.id);

      setState(() {
        _interdicoes.removeWhere((i) => i.id == interdicao.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AppText.corpo(
              '${interdicao.titulo} removida com sucesso.',
              color: AppColors.textPrimary,
            ),
            backgroundColor: AppColors.surface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AppText.corpo(
              'Erro ao remover: ${e.toString().replaceFirst('Exception: ', '')}',
              color: AppColors.error,
            ),
            backgroundColor: AppColors.surface,
            behavior: SnackBarBehavior.floating,
          ),
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

  Future<void> _handleLogout() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const AppText.subtitulo('Sair da conta?'),
        content: AppText.corpo('Olá, ${widget.usuario.nome}. Deseja encerrar a sessão?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const AppText('Cancelar', color: AppColors.textSecondary),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const AppText('Sair', color: AppColors.error),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    await _authService.logout(widget.token);
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFab(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      titleSpacing: 20,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'UrbanSync',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.accent,
          ),
          AppText.pequeno('Olá, ${widget.usuario.nome}'),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: AppColors.accent.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.traffic_rounded,
                  color: AppColors.accent, size: 14),
              const SizedBox(width: 4),
              AppText(
                '$_totalInterdicoes',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded,
              color: AppColors.textSecondary, size: 20),
          tooltip: 'Recarregar',
          onPressed: _isLoading ? null : _carregarInterdicoes,
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded,
              color: AppColors.textSecondary, size: 20),
          tooltip: 'Sair',
          onPressed: _handleLogout,
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.accent),
            SizedBox(height: 16),
            AppText.corpo('Carregando interdições...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded,
                  color: AppColors.textMuted, size: 48),
              const SizedBox(height: 16),
              AppText.corpo(_errorMessage!,
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _carregarInterdicoes,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Tentar novamente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.textOnAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_interdicoes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.traffic_rounded,
                color: AppColors.textMuted.withOpacity(0.4), size: 64),
            const SizedBox(height: 16),
            const AppText.subtitulo(
              'Nenhuma interdição cadastrada',
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 8),
            const AppText.corpo(
              'Toque no botão + para adicionar a primeira.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.surface,
      onRefresh: _carregarInterdicoes,
      child: Column(
        children: [
          _buildListHeader(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80, top: 4),
              itemCount: _interdicoes.length,
              itemBuilder: (context, index) {
                final interdicao = _interdicoes[index];
                return InterdicaoCard(
                  interdicao: interdicao,
                  onRemover: () => _removerInterdicao(interdicao),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader() {
    final obras = _interdicoes.where((i) => i.tipo == 1).length;
    final eventos = _interdicoes.where((i) => i.tipo == 2).length;
    final acidentes = _interdicoes.where((i) => i.tipo == 3).length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          _buildStatChip(
              'Obras', obras.toString(), AppColors.tipoObra,
              Icons.construction_rounded),
          _buildDivider(),
          _buildStatChip(
              'Eventos', eventos.toString(), AppColors.tipoEvento,
              Icons.event_rounded),
          _buildDivider(),
          _buildStatChip(
              'Acidentes', acidentes.toString(), AppColors.tipoAcidente,
              Icons.car_crash_rounded),
        ],
      ),
    );
  }

  Widget _buildStatChip(
      String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          AppText(value,
              fontSize: 18, fontWeight: FontWeight.bold, color: color),
          AppText.pequeno(label, color: AppColors.textMuted),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.divider,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton.extended(
      onPressed: _irParaCadastro,
      backgroundColor: AppColors.accent,
      foregroundColor: AppColors.textOnAccent,
      icon: const Icon(Icons.add_rounded),
      label: const AppText(
        'Nova Interdição',
        fontWeight: FontWeight.bold,
        color: AppColors.textOnAccent,
      ),
      elevation: 4,
    );
  }
}
