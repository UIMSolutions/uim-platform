/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.persistence.mappers.environment_event;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// Converts between EnvironmentEvent and its snapshot record.
struct EnvironmentEventMapper {
  static Json toRecord(const EnvironmentEvent e) {
    auto r = baseRecord(e);
    r["globalAccountId"] = e.globalAccountId.value;
    r["subaccountId"] = e.subaccountId.value;
    r["directoryId"] = e.directoryId.value;
    r["category"] = enumName(e.category);
    r["severity"] = enumName(e.severity);
    r["eventType"] = e.eventType;
    r["description"] = e.description;
    r["resourceId"] = e.resourceId;
    r["resourceType"] = e.resourceType;
    r["initiatedBy"] = e.initiatedBy.value;
    r["sourceService"] = e.sourceService;
    r["timestamp"] = e.timestamp;
    r["details"] = propertiesToJson(e.details);
    return r;
  }

  static EnvironmentEvent fromRecord(Json r) {
    EnvironmentEvent e;
    readBase(e, r);
    e.globalAccountId = GlobalAccountId(fieldString(r, "globalAccountId"));
    e.subaccountId = SubaccountId(fieldString(r, "subaccountId"));
    e.directoryId = DirectoryId(fieldString(r, "directoryId"));
    e.category = fieldEnum!EnvironmentEventCategory(r, "category", EnvironmentEventCategory.subaccountLifecycle);
    e.severity = fieldEnum!EnvironmentEventSeverity(r, "severity", EnvironmentEventSeverity.info);
    e.eventType = fieldString(r, "eventType");
    e.description = fieldString(r, "description");
    e.resourceId = fieldString(r, "resourceId");
    e.resourceType = fieldString(r, "resourceType");
    e.initiatedBy = UserId(fieldString(r, "initiatedBy"));
    e.sourceService = fieldString(r, "sourceService");
    e.timestamp = fieldLong(r, "timestamp");
    e.details = fieldMap(r, "details");
    return e;
  }
}
