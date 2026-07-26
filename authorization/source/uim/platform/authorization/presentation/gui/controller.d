module uim.platform.authorization.presentation.gui.controller;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

class AuthorizationGuiController {
  private AuthorizationGuiModel model;
  private AuthorizationGuiView view;

  this(AuthorizationGuiModel model, AuthorizationGuiView view) {
    this.model = model;
    this.view = view;
  }

  string render() {
    return view.renderWindow(model.windowTitle());
  }
}
