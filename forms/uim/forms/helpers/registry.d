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
