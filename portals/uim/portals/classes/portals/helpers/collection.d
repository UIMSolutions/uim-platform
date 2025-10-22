/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.portals.classes.portals.helpers.collection;

import uim.portals;

mixin(Version!"test_uim_portals");

@safe:

class DPortalCollection : DCollection!IPortal {
  mixin(CollectionThis!("Portal"));
}
mixin(CollectionCalls!("Portal"));

unittest {
  auto collection = new DPortalCollection;
  assert(testCollection(collection, "Portal"), "Test PortalCollection failed");
}