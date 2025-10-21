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
