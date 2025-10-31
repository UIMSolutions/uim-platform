/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.views.classes.templaters.errors.error;

import uim.views;

mixin(Version!("test_uim_views"));

@safe:

class DTemplaterError : DError {
  mixin(ErrorThis!("Templater"));
}
mixin(ErrorCalls!("Templater"));

unittest {
  auto error = new DTemplaterError("Test error");
  assert(testError(error), "In DTemplaterError: Test failed");
}
