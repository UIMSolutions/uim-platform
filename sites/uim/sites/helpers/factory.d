/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.sites.helpers.factory;

import uim.sites;
mixin(Version!("test_uim_sites"));

@safe:

class DSiteFactory : DFactory!ISite {
  mixin(FactoryThis!("Site"));
}

mixin(FactoryCalls!("Site"));

unittest {
  auto factory = new DSiteFactory();
  assert(factory !is null, "SiteFactory is null");

  assert(testFactory(factory, "Site"), "Test SiteFactory failed");
}
