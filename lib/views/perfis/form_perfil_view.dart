import 'package:flutter/material.dart';
import '../../models/entities/profile.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/ui_helpers/snackbar_helper.dart';
import '../shared_widgets/app_text_widget.dart';
import '../shared_widgets/custom_text_field_widget.dart';
import '../../viewmodels/perfil_viewmodel.dart';

class FormPerfilView extends StatefulWidget {
  final String token;
  final Profile? profile;
  final PerfilViewModel viewModel;

  const FormPerfilView({
    super.key,
    required this.token,
    required this.viewModel,
    this.profile,
  });

  @override
  State<FormPerfilView> createState() => _FormPerfilViewState();
}

class _FormPerfilViewState extends State<FormPerfilView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  bool get _isEditing => widget.profile != null;
  bool _isLoading = false;
  String? _errorMessage;

  PerfilViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile?.name ?? '');
    _descriptionController = TextEditingController(text: widget.profile?.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final message = await _viewModel.saveProfile(
        widget.token,
        profile: widget.profile,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      if (!mounted) return;
      SnackbarHelper.showSuccess(context, message ?? 'Perfil salvo com sucesso.');
      Navigator.of(context).pop();
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textOnAccent, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: AppTextWidget(
          _isEditing ? 'Editar Perfil' : 'Novo Perfil',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textOnAccent,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.divider),
                boxShadow: const [
                  BoxShadow(color: AppColors.shadow, blurRadius: 24, offset: Offset(0, 8)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextFieldWidget(
                    controller: _nameController,
                    label: 'Nome do Perfil',
                    icon: Icons.shield_outlined,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Informe o nome do perfil.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextFieldWidget(
                    controller: _descriptionController,
                    label: 'Descrição (opcional)',
                    icon: Icons.description_outlined,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  if (_errorMessage != null) ...[
                    Container(
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
                            child: AppTextWidget.pequeno(_errorMessage!, color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _salvar,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppColors.surface),
                            )
                          : const Icon(Icons.save_rounded, size: 20),
                      label: AppTextWidget(
                        _isLoading
                            ? (_isEditing ? 'Atualizando...' : 'Cadastrando...')
                            : (_isEditing ? 'Salvar Alterações' : 'Cadastrar Perfil'),
                        color: AppColors.textOnAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
