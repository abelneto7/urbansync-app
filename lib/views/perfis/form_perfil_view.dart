import 'package:flutter/material.dart';
import '../../models/entities/profile.dart';
import '../../models/repositories/profile_repository.dart';
import '../../models/services/profile_service.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/ui_helpers/snackbar_helper.dart';
import '../../shared/ui_helpers/permission_helper.dart';
import '../shared_widgets/app_text_widget.dart';
import '../shared_widgets/custom_text_field_widget.dart';
import '../../viewmodels/perfil_viewmodel.dart';
import '../../viewmodels/perfil_form_viewmodel.dart';

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
  late final PerfilFormViewModel _formViewModel;

  bool get _isEditing => widget.profile != null;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.profile?.description ?? '');

    _formViewModel = PerfilFormViewModel(ProfileRepository(ProfileService()));

    if (_isEditing) {
      _formViewModel.initSelectedIds(widget.profile!.permissionIds);
      _formViewModel.carregarPermissoes(widget.token);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _formViewModel.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final message = await widget.viewModel.saveProfile(
        widget.token,
        profile: widget.profile,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        permissionIds:
            _isEditing ? _formViewModel.selectedIds.toList() : null,
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
    return ListenableBuilder(
      listenable: _formViewModel,
      builder: (context, child) {
        final modules = _formViewModel.permissoesAgrupadas.keys.toList();

        return DefaultTabController(
          length: _isEditing ? modules.length : 0,
          child: Scaffold(
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
              bottom: _isEditing && modules.isNotEmpty
                  ? TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      indicatorColor: AppColors.textOnAccent,
                      labelColor: AppColors.textOnAccent,
                      unselectedLabelColor:
                          AppColors.textOnAccent.withValues(alpha: 0.6),
                      tabs: modules.map((m) => Tab(text: m)).toList(),
                    )
                  : null,
            ),
            body: _isEditing ? _buildEditBody(modules) : _buildCreateBody(),
            bottomNavigationBar: _buildSaveButton(),
          ),
        );
      },
    );
  }

  Widget _buildCreateBody() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _buildFormCard(),
      ),
    );
  }

  Widget _buildEditBody(List<String> modules) {
    if (_formViewModel.isLoadingPermissoes) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (_formViewModel.permissoesError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded,
                color: AppColors.textMuted, size: 48),
            const SizedBox(height: 12),
            AppTextWidget.corpo(_formViewModel.permissoesError!),
          ],
        ),
      );
    }

    if (modules.isEmpty) {
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _buildFormCard(),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: _buildFormCard(),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AppTextWidget.subtitulo(
              'Permissões',
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: TabBarView(
            children: modules.map((module) {
              final perms = _formViewModel.permissoesAgrupadas[module]!;
              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                itemCount: perms.length,
                separatorBuilder: (context, i) =>
                    const Divider(height: 1, color: AppColors.divider),
                itemBuilder: (context, index) {
                  final perm = perms[index];
                  final isSelected =
                      _formViewModel.selectedIds.contains(perm.id);
                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (_) =>
                        _formViewModel.togglePermissao(perm.id),
                    title: AppTextWidget(
                      PermissionHelper.translateAction(perm.name),
                      color: AppColors.textPrimary,
                    ),
                    activeColor: AppColors.accent,
                    checkColor: AppColors.textOnAccent,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
          boxShadow: const [
            BoxShadow(
                color: AppColors.shadow,
                blurRadius: 12,
                offset: Offset(0, 4)),
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
                if (v == null || v.trim().isEmpty) {
                  return 'Informe o nome do perfil.';
                }
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
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                      child: AppTextWidget.pequeno(_errorMessage!,
                          color: AppColors.error),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
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
                  : (_isEditing ? 'Salvar Alterações' : 'Cadastrar Perfil'),
              color: AppColors.textOnAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
