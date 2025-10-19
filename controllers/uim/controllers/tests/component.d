/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.controllers.tests.component;

import uim.controllers;
mixin(Version!"test_uim_controllers");

@safe:

bool testControllerComponent(IControllerComponent component) {
    assert(component !is null, "component is null");

    return true;
}
