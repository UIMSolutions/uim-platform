/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.portals.classes.portals.helpers.registry;

import uim.portals;

mixin(Version!"test_uim_portals");

@safe:

class DPortalRegistry : DRegistry!IPortal {
  mixin(RegistryThis!("Portal"));
}
mixin(RegistryCalls!("Portal"));

unittest {
  auto registry = new DPortalRegistry;
  assert(testRegistry(registry, "Portal"), "Test PortalRegistry failed");
}
