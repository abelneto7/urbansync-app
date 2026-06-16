import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import '../widgets/app_text.dart';
import 'home_screen.dart';
import 'interdicoes_screen.dart';
import 'login_screen.dart';
import 'mapa_screen.dart';
import 'usuarios_screen.dart';
import '../utils/snackbar_utils.dart';
import '../viewmodels/base_viewmodel.dart';

class BaseScreen extends StatefulWidget {
  final String token;
  final User? usuario;

  const BaseScreen({super.key, required this.token, required this.usuario});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  late final BaseViewModel _viewModel;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _viewModel = BaseViewModel(AuthService());
    _screens = [
      HomeScreen(token: widget.token, usuario: widget.usuario),
      MapaScreen(token: widget.token),
      InterdicoesScreen(token: widget.token),
      UsuariosScreen(token: widget.token),
    ];
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    _viewModel.setCurrentIndex(index);
    Navigator.of(context).pop();
  }

  Future<void> _handleLogout() async {
    final message = await _viewModel.logout(widget.token);
    if (!mounted) return;
    
    SnackbarUtils.showSuccess(context, message);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final currentIndex = _viewModel.currentIndex;
        return Scaffold(
          appBar: AppBar(
            title: const AppText('UrbanSync', fontSize: 18, fontWeight: FontWeight.bold),
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
                      const AppText.subtitulo('Menu', color: AppColors.textPrimary),
                      AppText.pequeno(widget.usuario?.email ?? 'Administrador', color: AppColors.textSecondary),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.dashboard_rounded, 
                      color: currentIndex == 0 ? AppColors.accent : AppColors.textMuted),
                  title: AppText('Dashboard', 
                      color: currentIndex == 0 ? AppColors.accent : AppColors.textPrimary,
                      fontWeight: currentIndex == 0 ? FontWeight.bold : FontWeight.normal),
                  selected: currentIndex == 0,
                  onTap: () => _onItemTapped(0),
                ),
                ListTile(
                  leading: Icon(Icons.map_rounded, 
                      color: currentIndex == 1 ? AppColors.accent : AppColors.textMuted),
                  title: AppText('Mapa', 
                      color: currentIndex == 1 ? AppColors.accent : AppColors.textPrimary,
                      fontWeight: currentIndex == 1 ? FontWeight.bold : FontWeight.normal),
                  selected: currentIndex == 1,
                  onTap: () => _onItemTapped(1),
                ),
                ListTile(
                  leading: Icon(Icons.list_alt_rounded, 
                      color: currentIndex == 2 ? AppColors.accent : AppColors.textMuted),
                  title: AppText('Interdições', 
                      color: currentIndex == 2 ? AppColors.accent : AppColors.textPrimary,
                      fontWeight: currentIndex == 2 ? FontWeight.bold : FontWeight.normal),
                  selected: currentIndex == 2,
                  onTap: () => _onItemTapped(2),
                ),
                ListTile(
                  leading: Icon(Icons.people_alt_rounded, 
                      color: currentIndex == 3 ? AppColors.accent : AppColors.textMuted),
                  title: AppText('Usuários', 
                      color: currentIndex == 3 ? AppColors.accent : AppColors.textPrimary,
                      fontWeight: currentIndex == 3 ? FontWeight.bold : FontWeight.normal),
                  selected: currentIndex == 3,
                  onTap: () => _onItemTapped(3),
                ),
              ],
            ),
          ),
          body: _screens[currentIndex],
        );
      }
    );
  }
}
