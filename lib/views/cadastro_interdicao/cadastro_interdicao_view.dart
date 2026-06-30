import 'package:flutter/material.dart';
import '../../shared/utils/app_colors.dart';
import '../../shared/utils/snackbar_utils.dart';
import '../global_widgets/app_text.dart';
import '../global_widgets/custom_text_field.dart';
import '../global_widgets/tipo_interdicao_ui.dart';
import '../../models/entities/tipo_interdicao.dart';
import '../../viewmodels/cadastro_interdicao_viewmodel.dart';
import '../seletor_coordenada/seletor_coordenada_view.dart';

class CadastroInterdicaoView extends StatefulWidget {
  final String token;
  final CadastroInterdicaoViewModel viewModel;

  const CadastroInterdicaoView({
    super.key,
    required this.token,
    required this.viewModel,
  });

  @override
  State<CadastroInterdicaoView> createState() => _CadastroInterdicaoViewState();
}

class _CadastroInterdicaoViewState extends State<CadastroInterdicaoView> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();


  CadastroInterdicaoViewModel get _viewModel => widget.viewModel;

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _handleCadastro() async {
    if (!_formKey.currentState!.validate()) return;

    final result = await _viewModel.cadastrar(
      token: widget.token,
      titulo: _tituloController.text.trim(),
      descricao: _descricaoController.text.trim().isEmpty
          ? null
          : _descricaoController.text.trim(),
      latitude: double.parse(_latitudeController.text.trim()),
      longitude: double.parse(_longitudeController.text.trim()),
    );

    if (!mounted) return;

    if (result != null) {
      SnackbarUtils.showSuccess(context, _viewModel.successMessage!);
      Navigator.of(context).pop(result);
    }
  }

  Future<void> _abrirSeletorMapa() async {
    final resultado = await selecionarCoordenadaNoMapa(
      context,
      posicaoInicial: _viewModel.posicaoSelecionada,
    );
    if (resultado != null) {
      _viewModel.setPosicaoSelecionada(resultado);
      _latitudeController.text = resultado.latitude.toStringAsFixed(6);
      _longitudeController.text = resultado.longitude.toStringAsFixed(6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const AppText.subtitulo(
          'Nova Interdição',
          color: AppColors.textPrimary,
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            return Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionLabel('Informações básicas'),
                  const SizedBox(height: 12),

                  CustomTextField(
                    controller: _tituloController,
                    label: 'Título *',
                    icon: Icons.title_rounded,
                    maxLength: 100,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Informe o título.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  CustomTextField(
                    controller: _descricaoController,
                    label: 'Descrição (opcional)',
                    icon: Icons.description_outlined,
                    maxLines: 3,
                    maxLength: 500,
                  ),
                  const SizedBox(height: 20),

                  _buildSectionLabel('Tipo de interdição'),
                  const SizedBox(height: 12),
                  _buildTipoSelector(),
                  const SizedBox(height: 20),

                  _buildSectionLabel('Localização (coordenadas)'),
                  const SizedBox(height: 12),
                  _buildSeletorCoordenada(),
                  const SizedBox(height: 8),
                  Visibility(
                    visible: false,
                    maintainState: true,
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: _latitudeController,
                          label: 'Latitude',
                          icon: Icons.my_location_rounded,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Selecione a localização no mapa';
                            }
                            final val = double.tryParse(v.trim());
                            if (val == null) return 'Número inválido';
                            return null;
                          },
                        ),
                        CustomTextField(
                          controller: _longitudeController,
                          label: 'Longitude',
                          icon: Icons.explore_outlined,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Selecione a localização no mapa';
                            }
                            final val = double.tryParse(v.trim());
                            if (val == null) return 'Número inválido';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildSectionLabel('Status'),
                  const SizedBox(height: 8),
                  _buildStatusToggle(),
                  const SizedBox(height: 28),

                  if (_viewModel.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.error, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AppText.pequeno(
                              _viewModel.errorMessage!,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _viewModel.isLoading ? null : _handleCadastro,
                      icon: _viewModel.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                    AppColors.textOnAccent),
                              ),
                            )
                          : const Icon(Icons.check_circle_outline_rounded, size: 20),
                      label: AppText(
                        _viewModel.isLoading ? 'Cadastrando...' : 'Cadastrar Interdição',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textOnAccent,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.textOnAccent,
                        disabledBackgroundColor:
                            AppColors.accent.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        AppText.subtitulo(label, color: AppColors.textSecondary),
      ],
    );
  }

  Widget _buildSeletorCoordenada() {
    final pos = _viewModel.posicaoSelecionada;
    return GestureDetector(
      onTap: _abrirSeletorMapa,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: pos != null
              ? AppColors.accent.withValues(alpha: 0.08)
              : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: pos != null ? AppColors.accent : AppColors.divider,
            width: pos != null ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (pos != null ? AppColors.accent : AppColors.textMuted)
                    .withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                pos != null
                    ? Icons.location_on_rounded
                    : Icons.add_location_alt_outlined,
                color: pos != null ? AppColors.accent : AppColors.textMuted,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: pos != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText.pequeno(
                          'Localização selecionada',
                          color: AppColors.accent,
                        ),
                        AppText.corpo(
                          'Lat: ${pos.latitude.toStringAsFixed(6)}',
                          color: AppColors.textPrimary,
                        ),
                        AppText.corpo(
                          'Lng: ${pos.longitude.toStringAsFixed(6)}',
                          color: AppColors.textPrimary,
                        ),
                      ],
                    )
                  : const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.corpo(
                          'Selecionar no mapa',
                          color: AppColors.textPrimary,
                        ),
                        AppText.pequeno(
                          'Toque para abrir o mapa e marcar a posição',
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: pos != null ? AppColors.accent : AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipoSelector() {
    return Row(
      children: TipoInterdicao.selecaoveis.map((tipo) {
        final isSelected = _viewModel.tipoSelecionado == tipo.value;
        final color = tipo.color;
        return Expanded(
          child: GestureDetector(
            onTap: () => _viewModel.setTipoSelecionado(tipo.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.18)
                    : AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color : AppColors.divider,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    tipo.icon,
                    color: isSelected ? color : AppColors.textMuted,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  AppText.pequeno(
                    tipo.label,
                    color: isSelected ? color : AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Icon(
            _viewModel.statusAtivo
                ? Icons.radio_button_checked_rounded
                : Icons.radio_button_unchecked_rounded,
            color: _viewModel.statusAtivo ? AppColors.success : AppColors.textMuted,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AppText.corpo(
              _viewModel.statusAtivo ? 'Interdição Ativa' : 'Interdição Encerrada',
              color: _viewModel.statusAtivo ? AppColors.textPrimary : AppColors.textMuted,
            ),
          ),
          Switch(
            value: _viewModel.statusAtivo,
            onChanged: (v) => _viewModel.setStatusAtivo(v),
            activeTrackColor: AppColors.success,
            inactiveThumbColor: AppColors.textMuted,
            inactiveTrackColor: AppColors.divider,
          ),
        ],
      ),
    );
  }
}
