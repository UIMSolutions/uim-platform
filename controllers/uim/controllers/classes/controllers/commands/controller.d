/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.controllers.classes.controllers.commands.controller;

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

  // Unregisters a controller by name
  override bool execute(Json[string] arguments) {
    if (!arguments.hasKey("name")) {
      return ControllerRegistry.unregister(arguments.getString("name"));
    }

    return false;
  }
}

mixin(CommandCalls!("Controller"));

unittest {
  auto command = new uim.controllers.classes.controllers.commands.controller.DControllerCommand();
  assert(testCommand(command, "DControllerCommand initialization failed"));
}
