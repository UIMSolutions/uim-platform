module uim-platform.controllers.uim.controllers.classes.components.commands.component;

import uim.controllers;

mixin(Version!"test_uim_controllers");

@safe:
class DControllerComponentCommand : DCommand {
  mixin(CommandThis!("ControllerComponent"));

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    _commandPath ~= ["controller", "component"];
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

mixin(CommandCalls!("ControllerComponent"));

unittest {
  auto command = new uim.controllers.classes.controllers.commands.component.DControllerComponentCommand();
  assert(testCommand(command, "DControllerComponentCommand initialization failed"));
}
