/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.sites.helpers.directory;

import uim.sites;

mixin(Version!("test_uim_sites"));

@safe:

class DSiteCollection : DCollection!ISite {
  mixin(CollectionThis!("Site"));
}
mixin(CollectionCalls!("Site"));

unittest {
  auto collection = SiteCollection;
  assert(testCollection(collection, "Site"), "Test SiteCollection failed");
}