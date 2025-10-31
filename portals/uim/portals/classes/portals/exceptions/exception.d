/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.portals.classes.portals.exceptions.exception;

import uim.portals;

mixin(Version!"test_uim_portals");

@safe:

class DPortalException : DException {
  mixin(ExceptionThis!("Portal"));
}

mixin(ExceptionCalls!("Portal"));

unittest {
  auto exception = new DPortalException("Test portal exception");
  assert(exception.getMessage() == "Test portal exception");
  assert(testException(exception, "Portal"), "Exception type should be Portal");
}
