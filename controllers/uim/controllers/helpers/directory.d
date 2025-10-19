/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.controllers.helpers.directory;

import uim.controllers;
mixin(Version!"test_uim_controllers");

@safe:

class DControllerDirectory : DDirectory!IController {
  mixin(DirectoryThis!("Controller"));
}
mixin(DirectoryCalls!("Controller"));

unittest {
  auto directory = ControllerDirectory;
  assert(testDirectory(directory, "Controller"), "Test ControllerDirectory failed");
}