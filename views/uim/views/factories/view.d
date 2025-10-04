module uim.views.factories.view;

import uim.views;
mixin(Version!("test_uim_views"));

@safe:

class DViewFactory : DFactory!DView {
    static DViewFactory factory;
}

auto ViewFactory() {
    return DViewFactory.factory is null
        ? DViewFactory.factory = new DViewFactory() : DViewFactory.factory;
}

unittest {

}
