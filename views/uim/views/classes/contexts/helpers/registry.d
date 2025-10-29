/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.views.classes.contexts.helpers.registry;

import uim.views;

mixin(Version!("test_uim_views"));

@safe:

class DFormContextRegistry : DRegistry!IFormContext {
  mixin(RegistryThis!("FormContext"));
}
mixin(RegistryCalls!("FormContext"));

unittest {
  auto registry = DFormContextRegistry();
  assert(testRegistry(registry, "FormContext"), "Test DFormContextRegistry failed");
}