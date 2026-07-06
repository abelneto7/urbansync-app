class PermissionHelper {
  static String translateAction(String permissionName) {
    final action = permissionName.split('@').last.toLowerCase();
    
    const translations = {
      'index': 'Listar',
      'show': 'Visualizar',
      'store': 'Cadastrar',
      'update': 'Editar',
      'destroy': 'Excluir',
      'updatecoordinates': 'Atualizar Coordenadas',
    };
    
    return translations[action] ?? action;
  }
}
