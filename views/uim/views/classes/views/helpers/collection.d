module uim.views.classes.views.helpers.collection;

import uim.views;
mixin(Version!("test_uim_views"));

@safe:

class DViewCollection : DCollection!IView {
  mixin(CollectionThis!("View"));
}
mixin(CollectionCalls!("View"));

unittest {
  auto collection = ViewCollection;
  assert(testCollection(collection, "View"), "Test ViewCollection failed");
}