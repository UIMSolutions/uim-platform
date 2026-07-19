/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.enumerations.domain;

import uim.platform.foundry;

mixin(ShowModule!());

@safe:
enum MappingStatus {
    active,
    inactive,
    pending,
    error,
}
MappingStatus toMappingStatus(string value) {
    mixin(EnumSwitch("MappingStatus", "active"));
}
MappingStatus[] toMappingStatuses(string[] statuses) {
    return statuses.map!(s => toMappingStatus(s)).array;
}
string toString(MappingStatus status) {
    return status.to!string;
}
string[] toStrings(MappingStatus[] statuses) {
    return statuses.map!toString.array;
}
/// 
unittest {
    mixin(ShowTest!("MappingStatus"));

    assert(MappingStatus.active.toString == "active");
    assert(MappingStatus.inactive.toString == "inactive");
    assert(MappingStatus.pending.toString == "pending");
    assert(MappingStatus.error.toString == "error");

    assert("active".toMappingStatus == MappingStatus.active);
    assert("inactive".toMappingStatus == MappingStatus.inactive);
    assert("pending".toMappingStatus == MappingStatus.pending);
    assert("error".toMappingStatus == MappingStatus.error);

    assert(toStrings([MappingStatus.active, MappingStatus.error]) == ["active", "error"]);
    assert(toMappingStatuses(["active", "error"]) == [MappingStatus.active, MappingStatus.error]);
}

enum MappingType {
    applicationRoute,
    saasRoute,
    staticRoute,
}
MappingType toMappingType(string value) {
    mixin(EnumSwitch("MappingType", "applicationRoute"));
}
MappingType[] toMappingTypes(string[] types) {
    return types.map!(s => toMappingType(s)).array;
}
string toString(MappingType type) {
    return type.to!string;
}
string[] toStrings(MappingType[] types) {
    return types.map!toString.array;
}
/// 
unittest {
    mixin(ShowTest!("MappingType"));

    assert(MappingType.applicationRoute.toString == "applicationRoute");
    assert(MappingType.saasRoute.toString == "saasRoute");
    assert(MappingType.staticRoute.toString == "staticRoute");

    assert("applicationRoute".toMappingType == MappingType.applicationRoute);
    assert("saasRoute".toMappingType == MappingType.saasRoute);
    assert("staticRoute".toMappingType == MappingType.staticRoute);

    assert(toStrings([MappingType.applicationRoute, MappingType.staticRoute]) == ["applicationRoute", "staticRoute"]);
    assert(toMappingTypes(["applicationRoute", "staticRoute"]) == [MappingType.applicationRoute, MappingType.staticRoute]);
}