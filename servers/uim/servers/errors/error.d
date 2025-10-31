/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.servers.errors.error;

import uim.servers;

mixin(Version!"test_uim_servers");

@safe:

class DServerError : ServerError {
  mixin(ErrorThis!"Server");
}

mixin(ErrorThis!"Server");

unittest {
  auto error = new DServerError();
  assert(testError(error, "Server"), "In "~__MODULE__~": test of ServerError failed");
}
