/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.servers.commands.command;

import uim.servers;

mixin(Version!"test_uim_servers");

@safe:

class DServerCommand : ServerCommand {
  mixin(CommandThis!"Server");
}

mixin(CommandThis!"Server");

unittest {
  auto command = new DServerCommand();
  assert(testCommand(command, "Server"), "In "~__MODULE__~": test of ServerCommand failed");
}
