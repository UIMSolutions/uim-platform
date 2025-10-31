/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.mails.helpers.registry;

import uim.mails;
mixin(Version!"test_uim_mails");

@safe:

class DMailRegistry : DObjectRegistry!IMail {
    mixin(RegistryThis!"Mail");
}
mixin(RegistryCalls!"Mail");

unittest {
    auto registry = new DMailRegistry();
    assert(registry !is null, "Mail registry is null!");

    assert(testMail(registry, "Mail"), "Mail test failed!");
}
