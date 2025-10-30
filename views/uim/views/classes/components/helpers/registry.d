/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.views.classes.components.helpers.registry;

import uim.views;

mixin(Version!("test_uim_views"));

@safe:

class DViewComponentRegistry : DRegistry!IViewComponent {
  mixin(RegistryThis!("ViewComponent"));
}
mixin(RegistryCalls!("ViewComponent"));

unittest {
  auto registry = new DViewComponentRegistry;
  assert(testRegistry(registry, "ViewComponent"), "Test ViewComponentRegistry failed");
}