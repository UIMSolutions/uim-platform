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
  mixin TenantEntity!ServiceCallId;

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

  Json toJson() const {
    return entityToJson
      .set("customerId", customerId)
      .set("equipmentId", equipmentId)
      .set("subject", subject)
      .set("description", description)
      .set("status", status.to!string)
      .set("priority", priority.to!string)
      .set("origin", origin.to!string)
      .set("category", category.to!string)
      .set("serviceType", serviceType)
      .set("contactPerson", contactPerson)
      .set("contactPhone", contactPhone)
      .set("contactEmail", contactEmail)
      .set("reportedDate", reportedDate)
      .set("dueDate", dueDate)
      .set("resolvedDate", resolvedDate)
      .set("resolution", resolution)
      .set("address", address)
      .set("latitude", latitude)
      .set("longitude", longitude);
  }
}
