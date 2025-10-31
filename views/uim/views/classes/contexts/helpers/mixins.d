/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.views.classes.contexts.helpers.mixins;

import uim.views;

mixin(Version!("test_uim_views"));

@safe:

string formContextThis(string name = null) {
    string fullName = name ~ "FormContext";
    return objThis(fullName);
}

template FormContextThis(string name = null) {
    const char[] FormContextThis = formContextThis(name);
}

string formContextCalls(string name) {
    string fullName = name ~ "FormContext";
    return objCalls(fullName);
}

template FormContextCalls(string name) {
    const char[] FormContextCalls = formContextCalls(name);
}