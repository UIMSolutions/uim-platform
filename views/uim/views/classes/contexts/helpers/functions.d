/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.views.classes.contexts.helpers.functions;

import uim.views;

mixin(Version!("test_uim_views"));

@safe:

bool isFormContext(Object obj) {
  return obj is null ? false : cast(bool)obj !is null;
}

unittest {
  IFormContext formContext = null;
  assert(!isFormContext(formContext), "Test isFormContext with null failed");

  formContext = IFormContext(cast(Object)Object());
  assert(isFormContext(formContext), "Test isFormContext with valid instance failed");
}