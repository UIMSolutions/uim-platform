/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.models.mixins.entity;

import uim.models;
mixin(Version!"test_uim_models");

@safe:

// #region EntityThis
string entityThis(string name = null) {
  string fullName = name ~ "Entity";
  return objThis(fullName);
}

template EntityThis(string name = null) {
  const char[] EntityThis = entityThis(name);
}
// #endregion EntityThis

// #region EntityCalls
string entityCalls(string name) {
  string fullName = name ~ "Entity";
  return objCalls(fullName);
}

template EntityCalls(string name) {
  const char[] EntityCalls = entityCalls(name);
}
// #endregion EntityCalls
