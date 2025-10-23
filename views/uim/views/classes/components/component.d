module uim.views.classes.components.component;

import uim.views;

mixin(Version!("test_uim_views"));

@safe:

class DViewComponent : UIMObject, IViewComponent {
  mixin(ViewThis!());

  string render(string[string] data) {
    return "";
  }
}
