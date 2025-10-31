/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.views.classes.contexts.helpers.factory;

import uim.views;

mixin(Version!("test_uim_views"));

@safe:

class DFormContextFactory : DFactory!IFormContext {
  mixin(FactoryThis!("FormContext"));
}
mixin(FactoryCalls!("FormContext"));

unittest {
  auto factory = DFormContextFactory();
  assert(testFactory(factory, "FormContext"), "Test DFormContextFactory failed");
}