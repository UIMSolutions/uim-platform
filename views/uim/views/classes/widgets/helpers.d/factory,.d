module uim-platform.views.uim.views.classes.widgets.helpers.d.factory,;

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