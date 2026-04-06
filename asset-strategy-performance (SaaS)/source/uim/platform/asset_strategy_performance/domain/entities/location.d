/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.asset_strategy_performance.domain.entities.location;

import uim.platform.asset_strategy_performance;

mixin(ShowModule!());

@safe:

struct Location {
    LocationId id;
    TenantId tenantId;
    string name;
    string description;
    LocationType locationType = LocationType.functional;
    LocationStatus status = LocationStatus.active;
    string parentLocationId;
    string latitude;
    string longitude;
    string address;
    string building;
    string floor;
    string room;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}
