module uim.platform.authorization.presentation.gui.view;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

class AuthorizationGuiView {
  string renderWindow(string title) {
    return "[GUI] " ~ title ~ " - widgets can be bound to the GUI model.";
  }
}
