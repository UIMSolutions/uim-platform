/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.presentation.http.json_utils;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

Json serviceCallToJson(ServiceCall sc) {
    import std.conv : to;
    auto j = Json.emptyObject;
    j["id"] = Json(sc.id);
    j["tenantId"] = Json(sc.tenantId);
    j["customerId"] = Json(sc.customerId);
    j["equipmentId"] = Json(sc.equipmentId);
    j["subject"] = Json(sc.subject);
    j["description"] = Json(sc.description);
    j["status"] = Json(sc.status.to!string);
    j["priority"] = Json(sc.priority.to!string);
    j["origin"] = Json(sc.origin.to!string);
    j["category"] = Json(sc.category.to!string);
    j["serviceType"] = Json(sc.serviceType);
    j["contactPerson"] = Json(sc.contactPerson);
    j["contactPhone"] = Json(sc.contactPhone);
    j["contactEmail"] = Json(sc.contactEmail);
    j["reportedDate"] = Json(sc.reportedDate);
    j["dueDate"] = Json(sc.dueDate);
    j["resolvedDate"] = Json(sc.resolvedDate);
    j["resolution"] = Json(sc.resolution);
    j["address"] = Json(sc.address);
    j["latitude"] = Json(sc.latitude);
    j["longitude"] = Json(sc.longitude);
    j["createdBy"] = Json(sc.createdBy);
    j["modifiedBy"] = Json(sc.modifiedBy);
    j["createdAt"] = Json(sc.createdAt);
    j["modifiedAt"] = Json(sc.modifiedAt);
    return j;
}

Json activityToJson(Activity a) {
    import std.conv : to;
    auto j = Json.emptyObject;
    j["id"] = Json(a.id);
    j["tenantId"] = Json(a.tenantId);
    j["serviceCallId"] = Json(a.serviceCallId);
    j["technicianId"] = Json(a.technicianId);
    j["subject"] = Json(a.subject);
    j["description"] = Json(a.description);
    j["activityType"] = Json(a.activityType.to!string);
    j["status"] = Json(a.status.to!string);
    j["plannedStart"] = Json(a.plannedStart);
    j["plannedEnd"] = Json(a.plannedEnd);
    j["actualStart"] = Json(a.actualStart);
    j["actualEnd"] = Json(a.actualEnd);
    j["travelTime"] = Json(a.travelTime);
    j["workTime"] = Json(a.workTime);
    j["address"] = Json(a.address);
    j["latitude"] = Json(a.latitude);
    j["longitude"] = Json(a.longitude);
    j["notes"] = Json(a.notes);
    j["feedbackCode"] = Json(a.feedbackCode);
    j["createdBy"] = Json(a.createdBy);
    j["modifiedBy"] = Json(a.modifiedBy);
    j["createdAt"] = Json(a.createdAt);
    j["modifiedAt"] = Json(a.modifiedAt);
    return j;
}

Json assignmentToJson(Assignment a) {
    import std.conv : to;
    auto j = Json.emptyObject;
    j["id"] = Json(a.id);
    j["tenantId"] = Json(a.tenantId);
    j["activityId"] = Json(a.activityId);
    j["technicianId"] = Json(a.technicianId);
    j["status"] = Json(a.status.to!string);
    j["assignedDate"] = Json(a.assignedDate);
    j["acceptedDate"] = Json(a.acceptedDate);
    j["startedDate"] = Json(a.startedDate);
    j["completedDate"] = Json(a.completedDate);
    j["travelDistance"] = Json(a.travelDistance);
    j["schedulingPolicy"] = Json(a.schedulingPolicy);
    j["matchScore"] = Json(a.matchScore);
    j["notes"] = Json(a.notes);
    j["createdBy"] = Json(a.createdBy);
    j["modifiedBy"] = Json(a.modifiedBy);
    j["createdAt"] = Json(a.createdAt);
    j["modifiedAt"] = Json(a.modifiedAt);
    return j;
}

Json equipmentToJson(Equipment e) {
    import std.conv : to;
    auto j = Json.emptyObject;
    j["id"] = Json(e.id);
    j["tenantId"] = Json(e.tenantId);
    j["customerId"] = Json(e.customerId);
    j["serialNumber"] = Json(e.serialNumber);
    j["name"] = Json(e.name);
    j["description"] = Json(e.description);
    j["equipmentType"] = Json(e.equipmentType.to!string);
    j["status"] = Json(e.status.to!string);
    j["manufacturer"] = Json(e.manufacturer);
    j["model"] = Json(e.model);
    j["installationDate"] = Json(e.installationDate);
    j["warrantyEndDate"] = Json(e.warrantyEndDate);
    j["locationAddress"] = Json(e.locationAddress);
    j["latitude"] = Json(e.latitude);
    j["longitude"] = Json(e.longitude);
    j["lastServiceDate"] = Json(e.lastServiceDate);
    j["nextServiceDate"] = Json(e.nextServiceDate);
    j["measuringPoint"] = Json(e.measuringPoint);
    j["createdBy"] = Json(e.createdBy);
    j["modifiedBy"] = Json(e.modifiedBy);
    j["createdAt"] = Json(e.createdAt);
    j["modifiedAt"] = Json(e.modifiedAt);
    return j;
}

Json technicianToJson(Technician t) {
    import std.conv : to;
    auto j = Json.emptyObject;
    j["id"] = Json(t.id);
    j["tenantId"] = Json(t.tenantId);
    j["firstName"] = Json(t.firstName);
    j["lastName"] = Json(t.lastName);
    j["email"] = Json(t.email);
    j["phone"] = Json(t.phone);
    j["status"] = Json(t.status.to!string);
    j["region"] = Json(t.region);
    j["address"] = Json(t.address);
    j["latitude"] = Json(t.latitude);
    j["longitude"] = Json(t.longitude);
    j["availabilityStart"] = Json(t.availabilityStart);
    j["availabilityEnd"] = Json(t.availabilityEnd);
    j["maxWorkload"] = Json(t.maxWorkload);
    j["currentWorkload"] = Json(t.currentWorkload);
    j["travelRadius"] = Json(t.travelRadius);
    j["createdBy"] = Json(t.createdBy);
    j["modifiedBy"] = Json(t.modifiedBy);
    j["createdAt"] = Json(t.createdAt);
    j["modifiedAt"] = Json(t.modifiedAt);
    return j;
}

Json customerToJson(Customer c) {
    import std.conv : to;
    auto j = Json.emptyObject;
    j["id"] = Json(c.id);
    j["tenantId"] = Json(c.tenantId);
    j["name"] = Json(c.name);
    j["description"] = Json(c.description);
    j["customerType"] = Json(c.customerType.to!string);
    j["status"] = Json(c.status.to!string);
    j["contactPerson"] = Json(c.contactPerson);
    j["email"] = Json(c.email);
    j["phone"] = Json(c.phone);
    j["address"] = Json(c.address);
    j["latitude"] = Json(c.latitude);
    j["longitude"] = Json(c.longitude);
    j["website"] = Json(c.website);
    j["industry"] = Json(c.industry);
    j["accountNumber"] = Json(c.accountNumber);
    j["createdBy"] = Json(c.createdBy);
    j["modifiedBy"] = Json(c.modifiedBy);
    j["createdAt"] = Json(c.createdAt);
    j["modifiedAt"] = Json(c.modifiedAt);
    return j;
}

Json skillToJson(Skill s) {
    import std.conv : to;
    auto j = Json.emptyObject;
    j["id"] = Json(s.id);
    j["tenantId"] = Json(s.tenantId);
    j["technicianId"] = Json(s.technicianId);
    j["name"] = Json(s.name);
    j["description"] = Json(s.description);
    j["category"] = Json(s.category.to!string);
    j["proficiencyLevel"] = Json(s.proficiencyLevel.to!string);
    j["certificationDate"] = Json(s.certificationDate);
    j["expirationDate"] = Json(s.expirationDate);
    j["certificationNumber"] = Json(s.certificationNumber);
    j["issuingAuthority"] = Json(s.issuingAuthority);
    j["createdBy"] = Json(s.createdBy);
    j["modifiedBy"] = Json(s.modifiedBy);
    j["createdAt"] = Json(s.createdAt);
    j["modifiedAt"] = Json(s.modifiedAt);
    return j;
}

Json smartformToJson(Smartform sf) {
    import std.conv : to;
    auto j = Json.emptyObject;
    j["id"] = Json(sf.id);
    j["tenantId"] = Json(sf.tenantId);
    j["serviceCallId"] = Json(sf.serviceCallId);
    j["activityId"] = Json(sf.activityId);
    j["name"] = Json(sf.name);
    j["description"] = Json(sf.description);
    j["formType"] = Json(sf.formType.to!string);
    j["status"] = Json(sf.status.to!string);
    j["templateId"] = Json(sf.templateId);
    j["submittedBy"] = Json(sf.submittedBy);
    j["submittedDate"] = Json(sf.submittedDate);
    j["approvedBy"] = Json(sf.approvedBy);
    j["approvedDate"] = Json(sf.approvedDate);
    j["formData"] = Json(sf.formData);
    j["safetyLabel"] = Json(sf.safetyLabel);
    j["signatureData"] = Json(sf.signatureData);
    j["createdBy"] = Json(sf.createdBy);
    j["modifiedBy"] = Json(sf.modifiedBy);
    j["createdAt"] = Json(sf.createdAt);
    j["modifiedAt"] = Json(sf.modifiedAt);
    return j;
}
