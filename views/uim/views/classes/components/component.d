module uim.views.classes.components.component;

mixin(Version!("test_uim_views"));

import uim.views;
@safe:
class DViewComponent : UIMObject, IViewComponent {
  mixin(ViewThis!());

  string render(string[string] data) {
    return "";
  }
}
