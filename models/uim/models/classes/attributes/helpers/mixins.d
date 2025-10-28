/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.models.classes.attributes.helpers.mixins;

import uim.models;

mixin(Version!"test_uim_models");

@safe:

string attributeThis(string name = null) {
  string fullName = name ~ "Attribute";
  return objThis(fullName);
}

template AttributeThis(string name = null) {
  const char[] AttributeThis = attributeThis(name);
}

string attributeCalls(string name) {
  string fullName = name ~ "Attribute";
  return objCalls(fullName);
}

template AttributeCalls(string name) {
  const char[] AttributeCalls = attributeCalls(name);
}
