module uim.mails.helpers.registry;

mixin(Version!"test_uim_mails");

import uim.mails;
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
