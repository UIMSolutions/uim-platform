/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.views.classes.contexts.helpers.collection;

import uim.views;

mixin(Version!("test_uim_views"));

@safe:

class DFormContextCollection : DCollection!IFormContext {
  mixin(CollectionThis!("FormContext"));
}
mixin(CollectionCalls!("FormContext"));

unittest {
  auto collection = DFormContextCollection();
  assert(testCollection(collection, "FormContext"), "Test DFormContextCollection failed");
}