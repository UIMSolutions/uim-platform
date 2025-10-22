module uim.services.classes.services.commands.command;

import uim.services;

mixin(Version!("test_uim_services"));

@safe:

class DServiceCommand : DCommand {
  mixin(CommandThis!("Service"));
}
mixin(CommandClass!("Service"));

unittest {
  auto command = ServiceCommand;
  assert(testCommand(command, "Service"), "Test ServiceCommand failed");
}
