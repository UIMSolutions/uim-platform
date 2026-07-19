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
MappingStatus toMappingStatus(string s) {
    const map = [
        "active": MappingStatus.active,
        "inactive": MappingStatus.inactive,
        "pending": MappingStatus.pending,
        "error": MappingStatus.error
    ];
    return map.get(s.toLower, MappingStatus.inactive);
}

enum MappingType {
    applicationRoute,
    saasRoute,
    staticRoute,
}
MappingType toMappingType(string s) {
    const map = [
        "applicationroute": MappingType.applicationRoute,
        "saasroute": MappingType.saasRoute,
        "staticroute": MappingType.staticRoute
    ];
    return map.get(s.toLower, MappingType.applicationRoute);
}