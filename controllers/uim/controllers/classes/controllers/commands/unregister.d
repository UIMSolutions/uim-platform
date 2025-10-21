module uim.controllers.classes.controllers.commands.unregister;

import uim.controllers;

mixin(Version!"test_uim_controllers");

@safe:
class DUnregisterControllerCommand : DControllerCommand {
  mixin(CommandThis!("UnregisterController"));

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    _commandPath ~= ["unregister"];
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

mixin(CommandCalls!("UnregisterController"));

unittest {
  auto command = new uim.controllers.classes.controllers.commands.unregister.DUnregisterControllerCommand();
  assert(testCommand(command, "DUnregisterControllerCommand initialization failed"));
}
