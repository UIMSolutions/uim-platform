/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.controllers.classes.controllers.tests.test;

import uim.controllers;

mixin(Version!"test_uim_controllers");

@safe:

bool testController(IController controller, string instanceName) {
  assert(controller !is null, "In testController: controller is null");
  assert(controller.name == instanceName, "In testController: controller.name != instanceName (" ~ instanceName ~ ")");

  return true;
}
