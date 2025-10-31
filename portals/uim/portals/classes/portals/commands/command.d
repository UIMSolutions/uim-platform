/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.portals.classes.portals.commands.command;

import uim.portals;

mixin(Version!"test_uim_portals");

@safe:

class DPortalCommand : DCommand {
  mixin(CommandThis!("Portal"));
}

mixin(CommandCalls!("Portal"));

unittest {
  auto command = new DPortalCommand();
  assert(testCommand(command, "Portal"), "DPortalCommand unittest failed!");
}
