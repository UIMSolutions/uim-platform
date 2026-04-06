/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.domain.entities.service_call;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

struct ServiceCall {
    ServiceCallId id;
    TenantId tenantId;
    CustomerId customerId;
    EquipmentId equipmentId;
    string subject;
    string description;
    ServiceCallStatus status = ServiceCallStatus.new_;
    ServiceCallPriority priority = ServiceCallPriority.medium;
    ServiceCallOrigin origin = ServiceCallOrigin.manual;
    ServiceCallCategory category = ServiceCallCategory.repair;
    string serviceType;
    string contactPerson;
    string contactPhone;
    string contactEmail;
    string reportedDate;
    string dueDate;
    string resolvedDate;
    string resolution;
    string address;
    string latitude;
    string longitude;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}
