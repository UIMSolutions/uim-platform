/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.controllers.classes.components.helpers.collection;

import uim.controllers;

mixin(Version!"test_uim_controllers");

@safe:

class DControllerComponentCollection : DCollection!IControllerComponent {
  mixin(CollectionThis!("ControllerComponent"));
}

mixin(CollectionCalls!("ControllerComponent"));

unittest {
  auto collection = new DControllerComponentCollection();
  assert(testCollection(collection, "ControllerComponent"), "Test ControllerComponentCollection failed");
}