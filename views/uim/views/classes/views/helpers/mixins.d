/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.views.classes.views.helpers.mixins;

import uim.views;

mixin(Version!("test_uim_views"));

@safe:

string viewThis(string name = null) {
    string fullName = name ~ "View";
    return objThis(fullName);
}

template ViewThis(string name = null) {
    const char[] ViewThis = viewThis(name);
}

string viewCalls(string name) {
    string fullName = name ~ "View";
    return objCalls(fullName);
}

template ViewCalls(string name) {
    const char[] ViewCalls = viewCalls(name);
}