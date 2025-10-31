/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.forms.helpers.registry;

import uim.forms;
mixin(Version!"test_uim_forms");

@safe:

class DFormRegistry : DObjectRegistry!IForm {
    mixin(RegistryThis!"Form");
}
mixin(RegistryCalls!"Form");

unittest {
    auto registry = new DFormRegistry();
    assert(registry !is null, "Form registry is null!");

    assert(testForm(registry, "Form"), "Form test failed!");
}
