import 'package:flutter/material.dart';

import '../../models/entities/user.dart';
import '../../models/repositories/profile_repository.dart';
import '../../models/services/profile_service.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/ui_helpers/snackbar_helper.dart';
import '../shared_widgets/app_text_widget.dart';
import '../shared_widgets/custom_text_field_widget.dart';
import '../../viewmodels/usuarios_viewmodel.dart';
import '../../viewmodels/usuario_form_viewmodel.dart';

class FormUsuarioView extends StatefulWidget {
  final String token;
  final User? usuario;
  final UsuariosViewModel viewModel;

  const FormUsuarioView({
    super.key,
    required this.token,
    required this.viewModel,
    this.usuario,
  });

  @override
  State<FormUsuarioView> createState() => _FormUsuarioViewState();
}

class _FormUsuarioViewState extends State<FormUsuarioView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _emailController;
  late final TextEditingController _senhaController;
  late final TextEditingController _confirmaSenhaController;
  late final UsuarioFormViewModel _formViewModel;

  bool _obscureSenha = true;
  bool _obscureConfirma = true;
  bool _isLoading = false;

  bool get _isEditing => widget.usuario != null;
  UsuariosViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.usuario?.nome ?? '');
    _emailController = TextEditingController(text: widget.usuario?.email ?? '');
    _senhaController = TextEditingController();
    _confirmaSenhaController = TextEditingController();

    _formViewModel = UsuarioFormViewModel(ProfileRepository(ProfileService()));

    if (_isEditing) {
      _formViewModel.initSelectedIds(widget.usuario!.profileIds);
    }
    _formViewModel.carregarPerfis(widget.token);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmaSenhaController.dispose();
    _formViewModel.disposeViewModel();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_formViewModel.selectedProfileIds.isEmpty) {
      SnackbarHelper.showError(context, 'Selecione pelo menos um perfil de acesso.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final message = await _viewModel.saveUsuario(
        token: widget.token,
        usuario: widget.usuario,
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        password: _senhaController.text,
        profileIds: _formViewModel.selectedProfileIds.toList(),
      );

      if (!mounted) return;
      if (message != null) {
        SnackbarHelper.showSuccess(context, message);
      }
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: AppTextWidget(_isEditing ? 'Editar Usuário' : 'Novo Usuário',
            fontSize: 18, fontWeight: FontWeight.bold),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildFormCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildSaveButton(),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextFieldWidget(
              controller: _nomeController,
              label: 'Nome Completo',
              icon: Icons.person_outline_rounded,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe o nome.';
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextFieldWidget(
              controller: _emailController,
              label: 'E-mail Institucional',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe o e-mail.';
                if (!v.contains('@')) return 'E-mail inválido.';
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextFieldWidget(
              controller: _senhaController,
              label: _isEditing ? 'Nova Senha (Opcional)' : 'Senha de Acesso',
              icon: Icons.lock_outline_rounded,
              obscureText: _obscureSenha,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureSenha
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscureSenha = !_obscureSenha),
              ),
              validator: (v) {
                if (!_isEditing && (v == null || v.isEmpty)) return 'Informe a senha.';
                if (v != null && v.isNotEmpty && v.length < 8) {
                  return 'A senha deve ter no mínimo 8 caracteres.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextFieldWidget(
              controller: _confirmaSenhaController,
              label: 'Re-digite a Senha',
              icon: Icons.lock_reset_rounded,
              obscureText: _obscureConfirma,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirma
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirma = !_obscureConfirma),
              ),
              validator: (v) {
                if (_senhaController.text.isNotEmpty && v != _senhaController.text) {
                  return 'As senhas não coincidem.';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: AppTextWidget.subtitulo(
                'Perfis de Acesso',
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildProfilesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilesList() {
    return ListenableBuilder(
      listenable: _formViewModel,
      builder: (context, _) {
        if (_formViewModel.isLoadingProfiles) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          );
        }

        if (_formViewModel.profilesError != null) {
          return Center(
            child: Column(
              children: [
                const Icon(Icons.cloud_off_rounded, color: AppColors.textMuted),
                const SizedBox(height: 8),
                AppTextWidget.pequeno(_formViewModel.profilesError!, color: AppColors.error),
              ],
            ),
          );
        }

        if (_formViewModel.availableProfiles.isEmpty) {
          return const AppTextWidget.pequeno('Nenhum perfil disponível.', color: AppColors.textMuted);
        }

        return Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: _formViewModel.availableProfiles.map((profile) {
            final isSelected = _formViewModel.selectedProfileIds.contains(profile.id);
            return FilterChip(
              label: AppTextWidget(profile.name),
              selected: isSelected,
              onSelected: (_) => _formViewModel.toggleProfile(profile.id),
              selectedColor: AppColors.accent.withValues(alpha: 0.2),
              checkmarkColor: AppColors.accent,
              backgroundColor: AppColors.background,
              side: BorderSide(
                color: isSelected ? AppColors.accent : AppColors.divider,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildSaveButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: SizedBox(
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
                  : (_isEditing ? 'Salvar Alterações' : 'Cadastrar Usuário'),
              color: AppColors.textOnAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
