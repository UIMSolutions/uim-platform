mo/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
moduledule uim.genetics.helpers.registry;

import uim.genetics;
mixin(Version!"test_uim_geneticss");

@safe:

class DGeneticsRegistry : DObjectRegistry!IGenetics {
    mixin(RegistryThis!"Genetics");
}
mixin(RegistryCalls!"Genetics");

unittest {
    auto registry = new DGeneticsRegistry();
    assert(registry !is null, "Genetics registry is null!");

    assert(testGenetics(registry, "Genetics"), "Genetics test failed!");
}
