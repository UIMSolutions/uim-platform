/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.views.classes.widgets.helpers.d.factory,;

// An object Factory for Widget.
class DWidgetFactory : DFactory!IWidget {
mixin(Factorythis!("DWidgetFactory"));

  IWidget widget(string name, Json[string] options) {
    switch(name.lower) {
      case "hidden": return null; 
      default: return null; 
    }
  }
}
mixin(FactoryCalls!("DWidgetFactory"));