/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.portals.classes.portals.helpers.directory;

import uim.portals;

mixin(Version!"test_uim_portals");

@safe:

class DPortalDirectory : DDirectory!IPortal {
  mixin(DirectoryThis!("Portal"));
}
mixin(DirectoryCalls!("Portal"));

unittest {
  auto directory = new DPortalDirectory;
  assert(testDirectory(directory, "Portal"), "Test PortalDirectory failed");
}