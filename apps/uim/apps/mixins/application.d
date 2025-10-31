/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.apps.mixins.application;

import uim.apps;

@safe:
string applicationThis(string name = null) {
    string fullName = name ~ "Application";
    return objThis(fullName);
}

template ApplicationThis(string name = null) {
    const char[] ApplicationThis = applicationThis(name);
}

string applicationCalls(string name) {
    string fullName = name ~ "Application";
    return objCalls(fullName);
}

template ApplicationCalls(string name) {
    const char[] ApplicationCalls = applicationCalls(name);
}
