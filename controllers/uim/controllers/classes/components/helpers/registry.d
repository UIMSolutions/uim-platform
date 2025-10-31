/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.controllers.classes.components.helpers.registry;

import uim.controllers;

mixin(Version!("test_uim_controllers"));

@safe:

class DControllerComponentRegistry : DRegistry!IControllerComponent {
  mixin(RegistryThis!("ControllerComponent"));
}
mixin(RegistryCalls!("ControllerComponent"));

unittest {
  auto registry = new DControllerComponentRegistry();
  assert(testRegistry(registry, "ControllerComponent"), "Test ControllerComponentRegistry failed");
}