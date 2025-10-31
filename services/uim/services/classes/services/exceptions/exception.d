/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.services.classes.services.exceptions.exception;    

import uim.services;

mixin(Version!("test_uim_services"));

@safe:

// Service exception.
class DServiceException : DException {
  mixin(ExceptionThis!("Service"));

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) { return false; }

    this
      .messageTemplate("default", "Exception in libary uim-services");

    return true;
  }
}
mixin(ExceptionCalls!("Service"));

unittest {
  auto exception = new DServiceException();
  assert(testException(exception, "Service"), "Test DServiceException failed");
}
