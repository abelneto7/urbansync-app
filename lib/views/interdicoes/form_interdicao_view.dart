import 'package:flutter/material.dart';
import '../../models/entities/interdicao.dart';
import '../../models/repositories/interdicao_repository.dart';
import '../../models/services/interdicao_service.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/ui_helpers/snackbar_helper.dart';
import '../../viewmodels/interdicao_form_viewmodel.dart';
import '../shared_widgets/app_text_widget.dart';
import '../shared_widgets/custom_text_field_widget.dart';
import 'components/date_time_tile.dart';
import 'components/form_section_label.dart';
import 'components/interdicao_locale_seletor.dart';
import 'components/interdicao_tipo_seletor.dart';
import 'components/seletor_coordenada_view.dart';

class FormInterdicaoView extends StatefulWidget {
  final String token;
  final Interdicao? interdicao;

  const FormInterdicaoView({
    super.key,
    required this.token,
    this.interdicao,
  });

  @override
  State<FormInterdicaoView> createState() => _FormInterdicaoViewState();
}

class _FormInterdicaoViewState extends State<FormInterdicaoView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tituloController;
  late final TextEditingController _descricaoController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  late final InterdicaoFormViewModel _viewModel;

  bool get _isEditing => widget.interdicao != null;

  @override
  void initState() {
    super.initState();
    final Interdicao? i = widget.interdicao;
    _tituloController = TextEditingController(text: i?.titulo ?? '');
    _descricaoController = TextEditingController(text: i?.descricao ?? '');
    _latitudeController = TextEditingController(
      text: i != null ? i.latitude.toStringAsFixed(6) : '',
    );
    _longitudeController = TextEditingController(
      text: i != null ? i.longitude.toStringAsFixed(6) : '',
    );
    _viewModel = InterdicaoFormViewModel(
      InterdicaoRepository(InterdicaoService()),
      interdicaoInicial: widget.interdicao,
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final DateTime? dataFim = _viewModel.dataFim;
    if (dataFim != null && !dataFim.isAfter(_viewModel.dataInicio)) {
      SnackbarHelper.showError(
        context,
        'A data/hora de fim deve ser posterior à data/hora de início.',
      );
      return;
    }

    final String descricao = _descricaoController.text.trim();
    final Interdicao? result = await _viewModel.salvar(
      token: widget.token,
      titulo: _tituloController.text.trim(),
      descricao: descricao.isEmpty ? null : descricao,
      latitude: double.parse(_latitudeController.text.trim()),
      longitude: double.parse(_longitudeController.text.trim()),
    );

    if (!mounted) return;

    if (result != null) {
      SnackbarHelper.showSuccess(context, _viewModel.successMessage!);
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

  Future<void> _selecionarDataHora({
    required DateTime initialDate,
    required void Function(DateTime) onConfirm,
  }) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    if (time == null || !mounted) return;

    onConfirm(DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 18,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: AppTextWidget.subtitulo(
          _isEditing ? 'Editar Interdição' : 'Nova Interdição',
          color: AppColors.textPrimary,
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildFormCard(),
                    const SizedBox(height: 20),
                    if (_viewModel.errorMessage != null) ...[
                      _ApiErrorBanner(message: _viewModel.errorMessage!),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) => _buildSaveButton(),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const FormSectionLabel('Informações básicas'),
          const SizedBox(height: 12),
          CustomTextFieldWidget(
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
          CustomTextFieldWidget(
            controller: _descricaoController,
            label: 'Descrição (opcional)',
            icon: Icons.description_outlined,
            maxLines: 3,
            maxLength: 500,
          ),
          const SizedBox(height: 20),

          const FormSectionLabel('Tipo de interdição'),
          const SizedBox(height: 12),
          InterdicaoTipoSeletor(
            tipoSelecionado: _viewModel.tipoSelecionado,
            onChanged: _viewModel.setTipoSelecionado,
          ),
          const SizedBox(height: 20),

          const FormSectionLabel('Localização (coordenadas)'),
          const SizedBox(height: 12),
          InterdicaoLocaleSeletor(
            posicaoSelecionada: _viewModel.posicaoSelecionada,
            onTap: _abrirSeletorMapa,
          ),
          const SizedBox(height: 8),
          _buildCoordenadaHiddenFields(),
          const SizedBox(height: 20),

          const FormSectionLabel('Período de vigência'),
          const SizedBox(height: 12),
          _buildSeletorDataInicio(),
          const SizedBox(height: 10),
          _buildSeletorDataFim(),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildCoordenadaHiddenFields() {
    return Visibility(
      visible: false,
      maintainState: true,
      child: Column(
        children: [
          CustomTextFieldWidget(
            controller: _latitudeController,
            label: 'Latitude',
            icon: Icons.my_location_rounded,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Selecione a localização no mapa';
              }
              if (double.tryParse(v.trim()) == null) return 'Número inválido';
              return null;
            },
          ),
          CustomTextFieldWidget(
            controller: _longitudeController,
            label: 'Longitude',
            icon: Icons.explore_outlined,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Selecione a localização no mapa';
              }
              if (double.tryParse(v.trim()) == null) return 'Número inválido';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSeletorDataInicio() {
    return DateTimeTile(
      id: 'data_inicio_tile',
      label: 'Data/Hora de Início *',
      icon: Icons.calendar_today_rounded,
      value: _viewModel.dataInicio,
      onTap: () => _selecionarDataHora(
        initialDate: _viewModel.dataInicio,
        onConfirm: _viewModel.setDataInicio,
      ),
    );
  }

  Widget _buildSeletorDataFim() {
    final DateTime? dataFim = _viewModel.dataFim;
    final bool dataFimInvalida =
        dataFim != null && !dataFim.isAfter(_viewModel.dataInicio);

    return DateTimeTile(
      id: 'data_fim_tile',
      label: 'Data/Hora de Fim',
      icon: Icons.event_busy_rounded,
      value: dataFim,
      hint: 'Prazo indeterminado',
      hasError: dataFimInvalida,
      errorText: 'A data/hora de fim deve ser posterior à de início.',
      trailing: dataFim != null
          ? IconButton(
              tooltip: 'Remover data de fim',
              icon: const Icon(
                Icons.close_rounded,
                size: 18,
                color: AppColors.textMuted,
              ),
              onPressed: () => _viewModel.setDataFim(null),
            )
          : null,
      onTap: () => _selecionarDataHora(
        initialDate: dataFim ?? DateTime.now(),
        onConfirm: (escolhida) {
          if (!escolhida.isAfter(_viewModel.dataInicio)) {
            SnackbarHelper.showError(
              context,
              'A data/hora de fim deve ser posterior à data/hora de início.',
            );
            return;
          }
          _viewModel.setDataFim(escolhida);
        },
      ),
    );
  }

  Widget _buildSaveButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _viewModel.isLoading ? null : _salvar,
            icon: _viewModel.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation(AppColors.textOnAccent),
                    ),
                  )
                : const Icon(Icons.save_rounded, size: 20),
            label: AppTextWidget(
              _viewModel.isLoading
                  ? (_isEditing ? 'Atualizando...' : 'Cadastrando...')
                  : (_isEditing ? 'Salvar Alterações' : 'Cadastrar Interdição'),
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textOnAccent,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.textOnAccent,
              disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }
}

class _ApiErrorBanner extends StatelessWidget {
  final String message;

  const _ApiErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: AppTextWidget.pequeno(message, color: AppColors.error),
          ),
        ],
      ),
    );
  }
}
