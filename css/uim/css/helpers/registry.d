/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
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
