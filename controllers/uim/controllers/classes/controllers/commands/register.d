/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.controllers.classes.controllers.commands.register;

import uim.controllers;

mixin(Version!"test_uim_controllers");

@safe:
class DRegisterControllerCommand : DControllerCommand {
  mixin(CommandThis!("RegisterController"));

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    _commandPath ~= ["register"];
    return true;
  }

  // Unregisters a controller by name
  override bool execute(Json[string] arguments) {
    if (!arguments.hasKey("name")) {
      return ControllerRegistry.register(ControllerFactory.create(arguments.getString("name")));
    }

    return false;
  }
}

mixin(CommandCalls!("RegisterController"));

unittest {
  auto command = new uim.controllers.classes.controllers.commands.unregister.DRegisterControllerCommand();
  assert(testCommand(command, "DRegisterControllerCommand initialization failed"));
}
