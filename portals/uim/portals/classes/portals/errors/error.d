/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.portals.classes.portals.errors.error;

import uim.portals;

mixin(Version!"test_uim_portals");

@safe:

class DPortalError : DError {
  mixin(ErrorThis!("Portal"));
}

mixin(ErrorCalls!("Portal"));

unittest {
  auto error = new DPortalError();
  assert(testError(error, "Portal"), "DPortalError unittest failed!");
}
