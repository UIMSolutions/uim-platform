module uim.views.classes.widgets.helpers.d.collection;

import uim.views;
mixin(Version!("test_uim_views"));

@safe:

class DWidgetCollection : DCollection!IWidget {
  mixin(CollectionThis!("Widget"));
}
mixin(CollectionCalls!("Widget"));

unittest {
  auto collection = WidgetCollection;
  assert(testCollection(collection, "Widget"), "Test WidgetCollection failed");
}