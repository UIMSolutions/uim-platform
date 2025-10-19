/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.controllers.helpers.registry;

mixin(Version!"test_uim_controllers");

import uim.controllers;

@safe:

class DControllerRegistry : DObjectRegistry!IController {
  mixin(RegistryThis!"Controller");
}

mixin(RegistryCalls!"Controller");

unittest {
  auto registry = new DControllerRegistry();
  assert(registry !is null, "Controller registry is null!");

  assert(testController(registry, "Controller"), "Controller test failed!");
}
