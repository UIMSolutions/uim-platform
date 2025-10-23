module uim.views.classes.widgets.errors.error;

import uim.views;

mixin(Version!("test_uim_views"));

@safe:

class DWidgetError : DError!IWidget {
  mixin(ErrorThis!("Widget"));
}