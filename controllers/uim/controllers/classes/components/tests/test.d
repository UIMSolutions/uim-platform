/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.controllers.classes.components.tests.test;

import uim.controllers;

mixin(Version!"test_uim_controllers");

@safe:

bool testControllerComponent(IControllerComponent component, string expectedName) {
  assert(component !is null, "In testController: component is null");
  assert(component.name == expectedName, "In testController: component.name != expectedName");

  return true;
}
