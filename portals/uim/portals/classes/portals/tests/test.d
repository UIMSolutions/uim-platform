/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.portals.classes.portals.tests.test;

import uim.portals;

mixin(Version!"test_uim_portals");

@safe:

bool testPortal(IPortal portal, string instanceName) {
  assert(portal !is null, "Portal instance is null!");
  assert(portal.name == instanceName, "Portal instance name does not match! Expected: " ~ instanceName ~ ", Found: " ~ portal
      .name);

  return true;
}
