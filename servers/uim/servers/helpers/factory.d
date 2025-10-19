/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.servers.helpers.factory;

mixin(Version!"test_uim_servers");

import uim.servers;
@safe:

class DServersFactory : DFactory!IServer {
    mixin(FactoryThis!("Server"));
}
mixin(FactoryCalls!("Server"));

unittest {
  auto factory = new DServersFactory();
  assert(testFactory(factory, "Server"), "Test ServersFactory failed");
}
