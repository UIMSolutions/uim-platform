/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.controllers.classes.controllers.helpers.factory;

import uim.apps;

mixin(Version!"test_uim_apps");
@safe:

class DControllerFactory : DFactory!IController {
  mixin(FactoryThis!("Controller"));
}
mixin(FactoryCalls!("Controller"));

unittest {
  auto factory = new DControllerFactory();
  assert(testFactory(factory, "Controller"), "Test ControllerFactory failed");
}
