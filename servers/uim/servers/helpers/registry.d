/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.servers.helpers.registry;

import uim.servers;
mixin(Version!"test_uim_servers");

@safe:

class DServerRegistry : DRegistry!IServer {
  mixin(RegistryThis!("Server"));
}
mixin(RegistryCalls!("Server"));

unittest {
  auto registry = ServerRegistry;
  assert(testRegistry(registry, "Server"), "Test ServerRegistry failed");
}