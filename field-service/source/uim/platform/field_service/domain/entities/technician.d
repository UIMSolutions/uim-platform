/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.domain.entities.technician;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

struct Technician {
    TechnicianId id;
    TenantId tenantId;
    string firstName;
    string lastName;
    string email;
    string phone;
    TechnicianStatus status = TechnicianStatus.available;
    string region;
    string address;
    string latitude;
    string longitude;
    string availabilityStart;
    string availabilityEnd;
    string maxWorkload;
    string currentWorkload;
    string travelRadius;
    UserId createdBy;
    UserId updatedBy;
    long createdAt;
    long updatedAt;

    Json technicianToJson() {
        return Json.emptyObject
        .set("id", id)
        .set("tenantId", tenantId)
        .set("firstName", firstName)
        .set("lastName", lastName)
        .set("email", email)
        .set("phone", phone)
        .set("status", status.to!string)
        .set("region", region)
        .set("address", address)
        .set("latitude", latitude)
        .set("longitude", longitude)
        .set("availabilityStart", availabilityStart)
        .set("availabilityEnd", availabilityEnd)
        .set("maxWorkload", maxWorkload)
        .set("currentWorkload", currentWorkload)
        .set("travelRadius", travelRadius)
        .set("createdBy", createdBy)
        .set("updatedBy", updatedBy)
        .set("createdAt", createdAt)
        .set("updatedAt", updatedAt);
    }
}
