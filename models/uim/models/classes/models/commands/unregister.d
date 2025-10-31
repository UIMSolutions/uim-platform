/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.models.classes.models.commands.unregister;

import uim.models;

mixin(Version!"test_uim_models");

@safe:

class DUnregisterModelCommand : DModelCommand {
  mixin(CommandThis!("UnregisterModel"));
}
mixin(CommandCalls!("UnregisterModel"));

unittest {
  auto command = UnregisterModelCommand;
  assert(testCollection(command, "UnregisterModel"), "Test UnregisterModelCommand failed");
}