import 'package:flutter/material.dart';
import '../../models/entities/user.dart';
import '../../shared/utils/app_colors.dart';
import '../global_widgets/app_text.dart';
import '../../viewmodels/home_viewmodel.dart';

class HomeView extends StatefulWidget {
  final String token;
  final User? usuario;
  final HomeViewModel viewModel;

  const HomeView({
    super.key,
    required this.token,
    required this.viewModel,
    this.usuario,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.carregarEstatisticas(widget.token);
  }

  @override
  Widget build(BuildContext context) {
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
                const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                const SizedBox(height: 16),
                AppText.corpo(widget.viewModel.errorMessage!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      widget.viewModel.carregarEstatisticas(widget.token),
                  child: const Text('Tentar Novamente'),
                ),
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
              _buildInfoCard('Obras', widget.viewModel.obras, AppColors.tipoObra, Icons.construction_rounded),
              const SizedBox(height: 16),
              _buildInfoCard('Eventos', widget.viewModel.eventos, AppColors.tipoEvento, Icons.event_rounded),
              const SizedBox(height: 16),
              _buildInfoCard('Acidentes', widget.viewModel.acidentes, AppColors.tipoAcidente, Icons.car_crash_rounded),
            ],
          ),
        );
      },
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
          ),
        ],
      ),
    );
  }
}
