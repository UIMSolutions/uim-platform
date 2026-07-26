module uim.platform.authorization.presentation.gui.model;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

class AuthorizationGuiModel {
  string windowTitle() const {
    return "Authorization Management GUI";
  }
}
