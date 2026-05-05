import 'package:flutter/material.dart';
import '../services/interdicao_service.dart';
import '../utils/app_colors.dart';
import '../widgets/app_text.dart';

class CadastroScreen extends StatefulWidget {
  final String token;

  const CadastroScreen({super.key, required this.token});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  final _interdicaoService = InterdicaoService();

  int _tipoSelecionado = 1;
  bool _statusAtivo = true;
  bool _isLoading = false;
  String? _errorMessage;

  static const List<Map<String, dynamic>> _tipos = [
    {'valor': 1, 'label': 'Obra', 'icon': Icons.construction_rounded},
    {'valor': 2, 'label': 'Evento', 'icon': Icons.event_rounded},
    {'valor': 3, 'label': 'Acidente', 'icon': Icons.car_crash_rounded},
  ];

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

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final interdicao = await _interdicaoService.cadastrar(
        token: widget.token,
        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim().isEmpty
            ? null
            : _descricaoController.text.trim(),
        latitude: double.parse(_latitudeController.text.trim()),
        longitude: double.parse(_longitudeController.text.trim()),
        tipo: _tipoSelecionado,
        status: _statusAtivo,
      );

      if (!mounted) return;
      Navigator.of(context).pop(interdicao);
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionLabel('Informações básicas'),
              const SizedBox(height: 12),

              _buildTextField(
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

              _buildTextField(
                controller: _descricaoController,
                label: 'Descrição (opcional)',
                icon: Icons.description_outlined,
                maxLines: 3,
                maxLength: 500,
              ),
              const SizedBox(height: 20),

              // Seção: Tipo
              _buildSectionLabel('Tipo de interdição'),
              const SizedBox(height: 12),
              _buildTipoSelector(),
              const SizedBox(height: 20),

              // Seção: Localização
              _buildSectionLabel('Localização (coordenadas)'),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _latitudeController,
                      label: 'Latitude *',
                      icon: Icons.my_location_rounded,
                      keyboardType: const TextInputType.numberWithOptions(
                          signed: true, decimal: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Obrigatório';
                        }
                        final val = double.tryParse(v.trim());
                        if (val == null) return 'Número inválido';
                        if (val < -90 || val > 90) return 'Entre -90 e 90';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _longitudeController,
                      label: 'Longitude *',
                      icon: Icons.explore_outlined,
                      keyboardType: const TextInputType.numberWithOptions(
                          signed: true, decimal: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Obrigatório';
                        }
                        final val = double.tryParse(v.trim());
                        if (val == null) return 'Número inválido';
                        if (val < -180 || val > 180) return 'Entre -180 e 180';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const AppText.pequeno(
                'Ex: Lagarto/SE → Lat: -10.9167  Lng: -37.6500',
                color: AppColors.textMuted,
              ),
              const SizedBox(height: 20),

              _buildSectionLabel('Status'),
              const SizedBox(height: 8),
              _buildStatusToggle(),
              const SizedBox(height: 28),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.error.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.error, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppText.pequeno(
                          _errorMessage!,
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
                  onPressed: _isLoading ? null : _handleCadastro,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(
                                AppColors.textOnAccent),
                          ),
                        )
                      : const Icon(Icons.check_circle_outline_rounded,
                          size: 20),
                  label: AppText(
                    _isLoading ? 'Cadastrando...' : 'Cadastrar Interdição',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textOnAccent,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.textOnAccent,
                    disabledBackgroundColor:
                        AppColors.accent.withOpacity(0.5),
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

  Widget _buildTipoSelector() {
    return Row(
      children: _tipos.map((tipo) {
        final isSelected = _tipoSelecionado == tipo['valor'] as int;
        Color color;
        switch (tipo['valor'] as int) {
          case 1:
            color = AppColors.tipoObra;
            break;
          case 2:
            color = AppColors.tipoEvento;
            break;
          default:
            color = AppColors.tipoAcidente;
        }
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _tipoSelecionado = tipo['valor'] as int),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withOpacity(0.18)
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
                    tipo['icon'] as IconData,
                    color: isSelected ? color : AppColors.textMuted,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  AppText.pequeno(
                    tipo['label'] as String,
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
            _statusAtivo
                ? Icons.radio_button_checked_rounded
                : Icons.radio_button_unchecked_rounded,
            color:
                _statusAtivo ? AppColors.success : AppColors.textMuted,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AppText.corpo(
              _statusAtivo ? 'Interdição Ativa' : 'Interdição Encerrada',
              color:
                  _statusAtivo ? AppColors.textPrimary : AppColors.textMuted,
            ),
          ),
          Switch(
            value: _statusAtivo,
            onChanged: (v) => setState(() => _statusAtivo = v),
            activeColor: AppColors.success,
            inactiveThumbColor: AppColors.textMuted,
            inactiveTrackColor: AppColors.divider,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(color: AppColors.textMuted, fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.textMuted, size: 18),
        filled: true,
        fillColor: AppColors.primaryDark,
        counterStyle:
            const TextStyle(color: AppColors.textMuted, fontSize: 10),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: AppColors.error.withOpacity(0.6)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        errorStyle: const TextStyle(color: AppColors.error, fontSize: 11),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      validator: validator,
    );
  }
}
