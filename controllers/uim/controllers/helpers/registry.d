module uim.controllers.helpers.registry;

mixin(Version!"test_uim_controllers");

import uim.controllers;
@safe:

class DControllerRegistry : DObjectRegistry!IController {
    mixin(RegistryThis!"Controller");
}
mixin(RegistryCalls!"Controller");

unittest {
    auto registry = new DControllerRegistry();
    assert(registry !is null, "Controller registry is null!");

    assert(testController(registry, "Controller"), "Controller test failed!");
}
