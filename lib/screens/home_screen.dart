import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/interdicao_service.dart';
import '../utils/app_colors.dart';
import '../widgets/app_text.dart';
import '../viewmodels/home_viewmodel.dart';

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
  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel(InterdicaoService());
    _viewModel.carregarEstatisticas(widget.token);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        if (_viewModel.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          );
        }

        if (_viewModel.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                const SizedBox(height: 16),
                AppText.corpo(_viewModel.errorMessage!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _viewModel.carregarEstatisticas(widget.token),
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
              
              _buildInfoCard('Obras', _viewModel.obras, AppColors.tipoObra, Icons.construction_rounded),
              const SizedBox(height: 16),
              _buildInfoCard('Eventos', _viewModel.eventos, AppColors.tipoEvento, Icons.event_rounded),
              const SizedBox(height: 16),
              _buildInfoCard('Acidentes', _viewModel.acidentes, AppColors.tipoAcidente, Icons.car_crash_rounded),
            ],
          ),
        );
      }
    );
  }

  Widget _buildInfoCard(String label, int value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
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
