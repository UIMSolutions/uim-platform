module uim.portals.classes.portals.helpers.collection;

import uim.neural;
mixin(Version!"test_uim_neural");

@safe:

class DPortalCollection : DCollection!IPortal {
  mixin(CollectionThis!("Portal"));
}
mixin(CollectionCalls!("Portal"));

unittest {
  auto collection = PortalCollection;
  assert(testCollection(collection, "Portal"), "Test PortalCollection failed");
}