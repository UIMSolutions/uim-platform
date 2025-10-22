/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.portals.classes.portals.helpers.factory;

import uim.portals;

mixin(Version!"test_uim_portals");

@safe:

class DPortalFactory : DFactory!IPortal {
  mixin(FactoryThis!("Portal"));
}

mixin(FactoryCalls!("Portal"));

unittest {
  auto factory = new DPortalFactory();
  assert(testFactory(factory, "Portal"), "Test PortalFactory failed");
}
