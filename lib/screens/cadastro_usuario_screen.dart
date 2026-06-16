import 'package:flutter/material.dart';

import '../services/user_service.dart';
import '../utils/app_colors.dart';
import '../utils/snackbar_utils.dart';
import '../widgets/app_text.dart';
import '../widgets/custom_text_field.dart';
import '../viewmodels/cadastro_usuario_viewmodel.dart';

class CadastroUsuarioScreen extends StatefulWidget {
  final String token;

  const CadastroUsuarioScreen({super.key, required this.token});

  @override
  State<CadastroUsuarioScreen> createState() => _CadastroUsuarioScreenState();
}

class _CadastroUsuarioScreenState extends State<CadastroUsuarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmaSenhaController = TextEditingController();
  late final CadastroUsuarioViewModel _viewModel;

  bool _obscureSenha = true;
  bool _obscureConfirma = true;

  @override
  void initState() {
    super.initState();
    _viewModel = CadastroUsuarioViewModel(UserService());
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmaSenhaController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final result = await _viewModel.cadastrar(
      token: widget.token,
      nome: _nomeController.text.trim(),
      email: _emailController.text.trim(),
      password: _senhaController.text,
      passwordConfirmation: _confirmaSenhaController.text,
    );

    if (!mounted) return;

    if (result != null) {
      SnackbarUtils.showSuccess(context, _viewModel.successMessage!);
      Navigator.of(context).pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const AppText('Novo Usuário', fontSize: 18, fontWeight: FontWeight.bold),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              return Column(
                children: [
                  _buildFormCard(),
                ],
              );
            }
          ),
        ),
      ),
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
            CustomTextField(
              controller: _nomeController,
              label: 'Nome Completo',
              icon: Icons.person_outline_rounded,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe o nome.';
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
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
            CustomTextField(
              controller: _senhaController,
              label: 'Senha de Acesso',
              icon: Icons.lock_outline_rounded,
              obscureText: _obscureSenha,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureSenha ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscureSenha = !_obscureSenha),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Informe a senha.';
                if (v.length < 8) return 'A senha deve ter no mínimo 8 caracteres.';
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _confirmaSenhaController,
              label: 'Re-digite a Senha',
              icon: Icons.lock_reset_rounded,
              obscureText: _obscureConfirma,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirma ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscureConfirma = !_obscureConfirma),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Confirme a senha.';
                return null;
              },
            ),
            const SizedBox(height: 24),
            if (_viewModel.errorMessage != null) ...[
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
                onPressed: _viewModel.isLoading ? null : _salvar,
                icon: _viewModel.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.surface),
                      )
                    : const Icon(Icons.save_rounded, size: 20),
                label: AppText(
                  _viewModel.isLoading ? 'Cadastrando...' : 'Salvar Usuário',
                  color: AppColors.textOnAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
