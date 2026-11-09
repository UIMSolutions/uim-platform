/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.domain.enumerations.category;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

// #region AuditCategory
/// Predefined SAP audit event categories.
enum AuditCategory {
  securityEvents, // audit.security-events
  configuration, // audit.configuration
  dataAccess, // audit.data-access
  dataModification, // audit.data-modification
}

AuditCategory toAuditCategory(string value) {
  switch (value.lower) {
  case "audit.security-events", "securityevents", "security-events":
    return AuditCategory.securityEvents;
  case "audit.configuration", "configuration":
    return AuditCategory.configuration;
  case "audit.data-access", "dataaccess", "data-access":
    return AuditCategory.dataAccess;
  case "audit.data-modification", "datamodification", "data-modification":
    return AuditCategory.dataModification;
  default:
    return AuditCategory.securityEvents;
  }
}

AuditCategory[] toAuditCategory(string[] values) {
  return values.map!toAuditCategory.array;
}

string toString(AuditCategory c) {
  final switch (c) {
  case AuditCategory.securityEvents:
    return "audit.security-events";
  case AuditCategory.configuration:
    return "audit.configuration";
  case AuditCategory.dataAccess:
    return "audit.data-access";
  case AuditCategory.dataModification:
    return "audit.data-modification";
  }
}

string[] toString(AuditCategory[] categories) {
  return categories.map!toString.array;
}
/// 
unittest {
  mixin(ShowTest!("AuditCategory"));

  assert("audit.security-events".toAuditCategory == AuditCategory.securityEvents);
  assert("audit.configuration".toAuditCategory == AuditCategory.configuration);
  assert("audit.data-access".toAuditCategory == AuditCategory.dataAccess);
  assert("audit.data-modification".toAuditCategory == AuditCategory.dataModification);
  // enum member names (as used in JSON / OData payloads) are accepted as well
  assert("dataAccess".toAuditCategory == AuditCategory.dataAccess);
  assert("configuration".toAuditCategory == AuditCategory.configuration);

  assert(AuditCategory.securityEvents.toString == "audit.security-events");
  assert(AuditCategory.configuration.toString == "audit.configuration");
  assert(AuditCategory.dataAccess.toString == "audit.data-access");
  assert(AuditCategory.dataModification.toString == "audit.data-modification");

  assert(["audit.security-events", "audit.data-access"].toAuditCategory == [AuditCategory.securityEvents, AuditCategory.dataAccess
    ]);
  assert([AuditCategory.securityEvents, AuditCategory.dataAccess].toString == ["audit.security-events", "audit.data-access"
    ]);
}
// #endregion AuditCategory

