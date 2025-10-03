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

// Attribute factories are not needed, as attributes are not instantiated like models.
// Thus, the files related to attribute factories have been removed.
// If needed in the future, they can be reintroduced with similar structure as model factories.
// Note: Attribute factories are not used anywhere currently, hence no registry is implemented for them.