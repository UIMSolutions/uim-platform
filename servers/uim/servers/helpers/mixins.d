/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.servers.helpers.mixins;

import uim.servers;

mixin(Version!"test_uim_servers");

@safe:

// #region ServerThis
string serverThis(string name = null) {
  string fullName = name ~ "Server";
  return objThis(fullName);
}

template ServerThis(string name = null) {
  const char[] ServerThis = serverThis(name);
}
// #endregion ServerThis

// #region ServerCalls
string serverCalls(string name) {
  string fullName = name ~ "Server";
  return objCalls(fullName);
}

template ServerCalls(string name) {
  const char[] ServerCalls = serverCalls(name);
}
// #endregion ServerCalls
