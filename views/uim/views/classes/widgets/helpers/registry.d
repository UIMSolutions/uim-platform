/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.views.classes.widgets.helpers.registry;

import uim.views;
mixin(Version!("test_uim_views"));

@safe:

class DWidgetRegistry : DRegistry!IWidget {
  mixin(RegistryThis!("Widget"));
}
mixin(RegistryCalls!("Widget"));

unittest {
  auto registry = WidgetRegistry;
  assert(testRegistry(registry, "Widget"), "Test WidgetRegistry failed");
}