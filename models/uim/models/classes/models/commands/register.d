/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.models.classes.models.commands.register;

import uim.models;

mixin(Version!"test_uim_models");

@safe:

class DRegisterModelCommand : DModelCommand {
  mixin(CommandThis!("RegisterModel"));
}
mixin(CommandCalls!("RegisterModel"));

unittest {
  auto command = RegisterModelCommand;
  assert(testCollection(command, "RegisterModel"), "Test RegisterModelCommand failed");
}
