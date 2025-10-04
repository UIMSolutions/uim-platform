/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.models.classes.models.helpers.factory;

import uim.models;
mixin(Version!"test_uim_models");

@safe:

class DModelFactory : DObjectFactory!IModel {
    mixin(FactoryThis!"Model");
}
mixin(FactoryCalls!"Model");

unittest {
    auto factory = new DModelFactory();
    assert(factory !is null, "ModelFactory is null!");

    assert(testFactory(factory, "ModelFactory"), "Model test failed!");
}
