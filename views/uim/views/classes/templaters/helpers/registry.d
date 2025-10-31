/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uuim.views.classes.templaters.helpers.registry;

import uim.views;

mixin(Version!("test_uim_views"));

@safe:

class DTemplaterRegistry : DRegistry!ITemplater {
    mixin(RegistryThis!("Templater"));
}
mixin(RegistryCalls!("Templater"));

unittest {
  auto registry = new DTemplaterRegistry();
  assert(testRegistry(registry, "Templater"), "Test TemplaterRegistry failed");
}

