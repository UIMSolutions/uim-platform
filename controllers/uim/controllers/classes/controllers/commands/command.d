/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim-platform.controllers.uim.controllers.classes.controllers.commands.command;

import uim.controllers;

mixin(Version!"test_uim_controllers");

@safe:

class DControllerCommand : DCommand {
  mixin(CommandThis!("Controller"));

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    _commandPath ~= ["controllers"];
    return true;
  }
}

mixin(CommandCalls!("Controller"));

unittest {
  auto command = new uim.controllers.classes.controllers.commands.controller.DControllerCommand();
  assert(testCommand(command, "DControllerCommand initialization failed"));
}
