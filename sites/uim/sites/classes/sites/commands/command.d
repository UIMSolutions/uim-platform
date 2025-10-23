module uim.sites.commands.command;

import uim.sites;

mixin(Version!("test_uim_sites"));

@safe:

class DSiteCommand : DCommand {
  mixin(CommandThis!("Site"));

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    _commandPath ~= ["site"];
    return true;
  }
}

mixin(CommandCalls!("Site"));

unittest {
  auto command = new uim.controllers.classes.controllers.commands.component.DSiteCommand();
  assert(testCommand(command, "DSiteCommand initialization failed"));
}
