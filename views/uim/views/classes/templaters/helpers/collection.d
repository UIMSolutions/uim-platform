/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.views.classes.templaters.helpers.collection;

import uim.views;

mixin(Version!("test_uim_views"));

@safe:

class DTemplaterCollection : DCollection!ITemplater {
  mixin(CollectionThis!("Templater"));
}
mixin(CollectionCalls!("Templater"));

unittest {
  auto collection = TemplaterCollection;
  assert(testCollection(collection, "Templater"), "Test TemplaterCollection failed");
}