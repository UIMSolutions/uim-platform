module uim.css.helpers.registry;

mixin(Version!"test_uim_css");

import uim.css;
@safe:

class DCssRegistry : DObjectRegistry!ICss {
    mixin(RegistryThis!"Css");
}
mixin(RegistryCalls!"Css");

unittest {
    auto registry = new DCssRegistry();
    assert(registry !is null, "Css registry is null!");

    assert(testCss(registry, "Css"), "Css test failed!");
}
