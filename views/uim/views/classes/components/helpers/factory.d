/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.views.classes.components.helpers.factory;

import uim.views;

mixin(Version!("test_uim_views"));

@safe:

class DViewComponentFactory : DFactory!IViewComponent {
  mixin(FactoryThis!("ViewComponent"));
}
mixin(FactoryCalls!("ViewComponent"));

unittest {
  auto factory = new DViewComponentFactory;
  assert(testFactory(factory, "ViewComponent"), "Test ViewComponentFactory failed");
}