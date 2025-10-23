/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.views.classes.components.helpers.registry;

import uim.views;

mixin(Version!("test_uim_views"));

@safe:

class DViewRegistry : DRegistry!IView {
  mixin(RegistryThis!("View"));
}
mixin(RegistryCalls!("View"));

unittest {
  auto registry = new DViewRegistry;
  assert(testRegistry(registry, "View"), "Test ViewRegistry failed");
}