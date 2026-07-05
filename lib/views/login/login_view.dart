import 'package:flutter/material.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/ui_helpers/snackbar_helper.dart';
import '../shared_widgets/app_text_widget.dart';
import '../shared_widgets/custom_text_field_widget.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../base/base_view.dart';
import '../../models/repositories/auth_repository.dart';
import '../../models/repositories/interdicao_repository.dart';
import '../../models/repositories/user_repository.dart';
import '../../models/services/auth_service.dart';
import '../../models/services/interdicao_service.dart';
import '../../models/services/user_service.dart';
import '../../viewmodels/base_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/mapa_viewmodel.dart';
import '../../viewmodels/interdicoes_viewmodel.dart';
import '../../viewmodels/usuarios_viewmodel.dart';

class LoginView extends StatefulWidget {
  final LoginViewModel viewModel;

  const LoginView({super.key, required this.viewModel});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  LoginViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await _viewModel.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      SnackbarHelper.showSuccess(context, _viewModel.successMessage!);

      final authRepo = AuthRepository(AuthService());
      final interdicaoRepo = InterdicaoRepository(InterdicaoService());
      final userRepo = UserRepository(UserService());

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, a1, a2) => BaseView(
            token: _viewModel.token!,
            usuario: _viewModel.usuario!,
            viewModel: BaseViewModel(authRepo),
            homeViewModel: HomeViewModel(interdicaoRepo),
            mapaViewModel: MapaViewModel(interdicaoRepo),
            interdicoesViewModel: InterdicoesViewModel(interdicaoRepo),
            usuariosViewModel: UsuariosViewModel(userRepo),
          ),
          transitionsBuilder: (context, anim, a2, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildLogo(),
                    const SizedBox(height: 48),
                    _buildFormCard(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryLight, AppColors.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('assets/images/lagarto_logo.png'),
          ),
        ),
        const SizedBox(height: 20),
        const AppTextWidget.titulo(
          'UrbanSync',
          color: AppColors.textPrimary,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        const AppTextWidget.corpo(
          'Mapeamento de interdições viárias\nLagarto · Sergipe',
          color: AppColors.textSecondary,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppTextWidget.subtitulo('Entrar na conta'),
            const SizedBox(height: 4),
            const AppTextWidget.pequeno('Use suas credenciais de acesso'),
            const SizedBox(height: 24),

            CustomTextFieldWidget(
              controller: _emailController,
              label: 'E-mail',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe o e-mail.';
                if (!v.contains('@')) return 'E-mail inválido.';
                return null;
              },
            ),
            const SizedBox(height: 14),

            CustomTextFieldWidget(
              controller: _passwordController,
              label: 'Senha',
              icon: Icons.lock_outline_rounded,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Informe a senha.';
                if (v.length < 6) return 'Mínimo 6 caracteres.';
                return null;
              },
            ),
            const SizedBox(height: 20),

            ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                              child: AppTextWidget.pequeno(
                                _viewModel.errorMessage!,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _viewModel.isLoading ? null : _handleLogin,
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
                        child: _viewModel.isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation(
                                      AppColors.textOnAccent),
                                ),
                              )
                            : const AppTextWidget(
                                'Entrar',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textOnAccent,
                              ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
