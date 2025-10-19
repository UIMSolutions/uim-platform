/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
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