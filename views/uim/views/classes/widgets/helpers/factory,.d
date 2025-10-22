/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.views.classes.widgets.helpers.factory;

import uim.views;

mixin(Version!("test_uim_views"));

@safe:

class DWidgetFactory : DFactory!IWidget {
  mixin(FactoryThis!("Widget"));
}
mixin(FactoryCalls!("Widget"));

unittest {
  auto factory = WidgetFactory;
  assert(testFactory(factory, "Widget"), "Test WidgetFactory failed");
}