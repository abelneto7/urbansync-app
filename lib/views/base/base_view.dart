import 'package:flutter/material.dart';
import '../../models/entities/user.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/ui_helpers/snackbar_helper.dart';
import '../shared_widgets/app_text_widget.dart';
import '../home/home_view.dart';
import '../mapa/mapa_view.dart';
import '../interdicoes/interdicoes_view.dart';
import '../usuarios/usuarios_view.dart';
import '../perfis/perfis_view.dart';
import '../login/login_view.dart';
import '../../viewmodels/base_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/mapa_viewmodel.dart';
import '../../viewmodels/interdicoes_viewmodel.dart';
import '../../viewmodels/usuarios_viewmodel.dart';
import '../../viewmodels/perfil_viewmodel.dart';
import '../../models/repositories/auth_repository.dart';
import '../../models/services/auth_service.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../../shared/ui_helpers/can_access_widget.dart';

class BaseView extends StatefulWidget {
  final String token;
  final User? usuario;
  final BaseViewModel viewModel;
  final HomeViewModel homeViewModel;
  final MapaViewModel mapaViewModel;
  final InterdicoesViewModel interdicoesViewModel;
  final UsuariosViewModel usuariosViewModel;
  final PerfilViewModel perfilViewModel;

  const BaseView({
    super.key,
    required this.token,
    required this.usuario,
    required this.viewModel,
    required this.homeViewModel,
    required this.mapaViewModel,
    required this.interdicoesViewModel,
    required this.usuariosViewModel,
    required this.perfilViewModel,
  });

  @override
  State<BaseView> createState() => _BaseViewState();
}

class _BaseViewState extends State<BaseView> {
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeView(token: widget.token, usuario: widget.usuario, viewModel: widget.homeViewModel),
      MapaView(token: widget.token, viewModel: widget.mapaViewModel),
      InterdicoesView(token: widget.token, viewModel: widget.interdicoesViewModel),
      UsuariosView(token: widget.token, viewModel: widget.usuariosViewModel),
      PerfisView(token: widget.token, viewModel: widget.perfilViewModel),
    ];
  }

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    widget.viewModel.setCurrentIndex(index);
    Navigator.of(context).pop();
  }

  Future<void> _handleLogout() async {
    final message = await widget.viewModel.logout(widget.token);
    if (!mounted) return;

    SnackbarHelper.showSuccess(context, message);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => LoginView(
          viewModel: LoginViewModel(AuthRepository(AuthService())),
        ),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final currentIndex = widget.viewModel.currentIndex;
        return Scaffold(
          appBar: AppBar(
            title: const AppTextWidget('UrbanSync', fontSize: 18, fontWeight: FontWeight.bold),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary, size: 20),
                tooltip: 'Sair',
                onPressed: _handleLogout,
              ),
            ],
          ),
          drawer: Drawer(
            backgroundColor: AppColors.surface,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Image.asset(
                        'assets/images/lagarto_logo.png',
                        width: 48,
                        height: 48,
                      ),
                      const SizedBox(height: 12),
                      const AppTextWidget.subtitulo('Menu', color: AppColors.textPrimary),
                      AppTextWidget.pequeno(widget.usuario?.email ?? 'Administrador', color: AppColors.textSecondary),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.dashboard_rounded,
                      color: currentIndex == 0 ? AppColors.accent : AppColors.textMuted),
                  title: AppTextWidget('Dashboard',
                      color: currentIndex == 0 ? AppColors.accent : AppColors.textPrimary,
                      fontWeight: currentIndex == 0 ? FontWeight.bold : FontWeight.normal),
                  selected: currentIndex == 0,
                  onTap: () => _onItemTapped(0),
                ),
                CanAccessWidget(
                  permission: 'InterdicaoController@index',
                  child: ListTile(
                    leading: Icon(Icons.map_rounded,
                        color: currentIndex == 1 ? AppColors.accent : AppColors.textMuted),
                    title: AppTextWidget('Mapa',
                        color: currentIndex == 1 ? AppColors.accent : AppColors.textPrimary,
                        fontWeight: currentIndex == 1 ? FontWeight.bold : FontWeight.normal),
                    selected: currentIndex == 1,
                    onTap: () => _onItemTapped(1),
                  ),
                ),
                CanAccessWidget(
                  permission: 'InterdicaoController@index',
                  child: ListTile(
                    leading: Icon(Icons.list_alt_rounded,
                        color: currentIndex == 2 ? AppColors.accent : AppColors.textMuted),
                    title: AppTextWidget('Interdições',
                        color: currentIndex == 2 ? AppColors.accent : AppColors.textPrimary,
                        fontWeight: currentIndex == 2 ? FontWeight.bold : FontWeight.normal),
                    selected: currentIndex == 2,
                    onTap: () => _onItemTapped(2),
                  ),
                ),
                CanAccessWidget(
                  permission: 'UserController@index',
                  child: ListTile(
                    leading: Icon(Icons.people_alt_rounded,
                        color: currentIndex == 3 ? AppColors.accent : AppColors.textMuted),
                    title: AppTextWidget('Usuários',
                        color: currentIndex == 3 ? AppColors.accent : AppColors.textPrimary,
                        fontWeight: currentIndex == 3 ? FontWeight.bold : FontWeight.normal),
                    selected: currentIndex == 3,
                    onTap: () => _onItemTapped(3),
                  ),
                ),
                CanAccessWidget(
                  permission: 'ProfileController@index',
                  child: ListTile(
                    leading: Icon(Icons.shield_outlined,
                        color: currentIndex == 4 ? AppColors.accent : AppColors.textMuted),
                    title: AppTextWidget('Perfis',
                        color: currentIndex == 4 ? AppColors.accent : AppColors.textPrimary,
                        fontWeight: currentIndex == 4 ? FontWeight.bold : FontWeight.normal),
                    selected: currentIndex == 4,
                    onTap: () => _onItemTapped(4),
                  ),
                ),
              ],
            ),
          ),
          body: _screens[currentIndex],
        );
      },
    );
  }
}
