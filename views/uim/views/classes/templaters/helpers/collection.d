/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
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