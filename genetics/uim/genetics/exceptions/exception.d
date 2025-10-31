/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.genetics.exceptions.exception;

import uim.genetics;

@safe:

class DGeneticsException : DException {
  mixin(ExceptionThis!("Genetics"));

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    this
      .messageTemplate("Error in libary uim-genetics");

    return true;
  }
}
mixin(ExceptionCalls!("Genetics"));
