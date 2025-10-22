/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.controllers.errors.error;

mixin(Version!"test_uim_controllers");

import uim.controllers;

@safe:

class DControllerError : DError {
  mixin(ErrorThis!("Controller"));
}
mixin(ErrorClass!("Controller"));

unittest {
  auto error = new DControllerError("Test error message");
  assert(err.msg == "Test error message");

  assert(testError(error, "Controller"), "Test ControllerError failed");
}