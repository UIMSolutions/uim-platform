/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
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
