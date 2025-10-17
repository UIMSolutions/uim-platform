module uim.views.classes.widgets.helpers.d.collection;

import uim.views;
mixin(Version!("test_uim_views"));

@safe:

// An object Collection for Widget.
class DWidgetCollection : DCollection!DWidget {
}

auto WidgetCollection() {
  return new DWidgetCollection;
}

unittest {
  assert(WidgetCollection);

  auto widgets = WidgetCollection;
}