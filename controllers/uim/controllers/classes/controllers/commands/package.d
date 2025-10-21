/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.controllers.classes.controllers.commands;

public {
  import uim.controllers.classes.controllers.commands.controller;
}

static this() {
  import uim.controllers;

  ControllerFactory.setPath(["controller", "register"], (Json[string] options = null) @safe {
    import uim.controllers.classes.controllers.commands.register;

    return RegisterControllerCommand(options);
  });

  ControllerFactory.setPath(["controller", "unregister"], (Json[string] options = null) @safe {
    import uim.controllers.classes.controllers.commands.unregister;

    return UnregisterControllerCommand(options);
  });

  ControllerRegistry.register(ControllerFactory.create("controller.register"));
  ControllerRegistry.register(ControllerFactory.create("controller.unregister"));
}
