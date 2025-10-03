/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.models.classes.models.helpers.registry;

mixin(Version!"test_uim_models");

import uim.models;
@safe:

class DModelRegistry : DObjectRegistry!IModel {
    mixin(RegistryThis!"Model");
}
mixin(RegistryCalls!"Model");

unittest {
    auto registry = new DModelRegistry();
    assert(registry !is null, "Model registry is null!");

    assert(testModel(registry, "Model"), "Model test failed!");
}
