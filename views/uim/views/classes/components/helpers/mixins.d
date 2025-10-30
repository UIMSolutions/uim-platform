/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.views.classes.components.helpers.mixins;

import uim.views;

mixin(Version!("test_uim_views"));

@safe:

string viewComponentThis(string name = null) {
    string fullName = name ~ "ViewComponent";
    return objThis(fullName);
}

template ViewComponentThis(string name = null) {
    const char[] ViewComponentThis = viewComponentThis(name);
}

string viewComponentCalls(string name) {
    string fullName = name ~ "ViewComponent";
    return objCalls(fullName);
}

template ViewComponentCalls(string name) {
    const char[] ViewComponentCalls = viewComponentCalls(name);
}