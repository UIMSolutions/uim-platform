/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UIManufaktur)
*****************************************************************************************************************/
module uim.portals.classes.portals.helpers.mixins;

import uim.portals;

mixin(Version!"test_uim_portals");

@safe:

string portalThis(string name = null) {
    string fullName = name ~ "Portal";
    return objThis(fullName);
}

template PortalThis(string name = null) {
    const char[] PortalThis = portalThis(name);
}

string portalCalls(string name) {
    string fullName = name ~ "Portal";
    return objCalls(fullName);
}

template PortalCalls(string name) {
    const char[] PortalCalls = portalCalls(name);
}
