/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.controllers.classes.controllers.helpers.collection;

import uim.controllers;

mixin(Version!"test_uim_controllers");

@safe:

class DControllerCollection : DCollection!IController {
  mixin(CollectionThis!("Controller"));
}

mixin(CollectionCalls!("Controller"));

unittest {
  auto collection = new DControllerCollection();
  assert(testCollection(collection, "Controller"), "Test ControllerCollection failed");
}