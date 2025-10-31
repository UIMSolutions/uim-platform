/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.views.classes.widgets.commands.command;

import uim.views;

mixin(Version!("test_uim_views"));

@safe:

class DWidgetCommand : DCommand!IWidget {
  mixin(CommandThis!("Widget"));
}
mixin(CommandCalls!("Widget"));

unittest {
  auto command = WidgetCommand;
  assert(testCommand(command, "Widget"), "Test WidgetCommand failed");
}