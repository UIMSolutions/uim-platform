module uim-platform.views.uim.views.classes.views.helpers.factory;

import uim.views;
mixin(Version!("test_uim_views"));

@safe:

class DViewFactory : DFactory!IView {
    mixin(FactoryThis!("View"));
}
mixin(FactoryCalls!("View"));

unittest {
  auto factory = new DViewFactory();
  assert(testFactory(factory, "View"), "Test ViewFactory failed");
}

