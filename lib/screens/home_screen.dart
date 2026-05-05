import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/interdicao_service.dart';
import '../utils/app_colors.dart';
import '../widgets/app_text.dart';
import '../models/interdicao.dart';

class HomeScreen extends StatefulWidget {
  final String token;
  final User? usuario;

  const HomeScreen({
    super.key,
    required this.token,
    this.usuario,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _interdicaoService = InterdicaoService();
  bool _isLoading = true;
  String? _errorMessage;
  
  int _obras = 0;
  int _eventos = 0;
  int _acidentes = 0;

  @override
  void initState() {
    super.initState();
    _carregarEstatisticas();
  }

  Future<void> _carregarEstatisticas() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final lista = await _interdicaoService.listar(widget.token);
      setState(() {
        _obras = lista.where((i) => i.tipo == 1).length;
        _eventos = lista.where((i) => i.tipo == 2).length;
        _acidentes = lista.where((i) => i.tipo == 3).length;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            AppText.corpo(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _carregarEstatisticas,
              child: const Text('Tentar Novamente'),
            )
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText.titulo('Visão Geral da Cidade', color: AppColors.textPrimary),
          const SizedBox(height: 8),
          const AppText.corpo('Estatísticas em tempo real do sistema UrbanSync.'),
          const SizedBox(height: 30),
          
          _buildInfoCard('Obras', _obras, AppColors.tipoObra, Icons.construction_rounded),
          const SizedBox(height: 16),
          _buildInfoCard('Eventos', _eventos, AppColors.tipoEvento, Icons.event_rounded),
          const SizedBox(height: 16),
          _buildInfoCard('Acidentes', _acidentes, AppColors.tipoAcidente, Icons.car_crash_rounded),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, int value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.pequeno(label, color: AppColors.textSecondary),
                AppText(value.toString(), fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ],
            ),
          )
        ],
      ),
    );
  }
}
