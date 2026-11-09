/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.persistence.mappers.audit_config;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

struct AuditConfigMapper {
  static Json toRecord(const AuditConfig e) {
    auto r = baseRecord(e);
    r["name"] = e.name;
    r["status"] = e.status.to!string;
    r["logDataAccess"] = e.logDataAccess;
    r["logDataModification"] = e.logDataModification;
    r["logSecurityEvents"] = e.logSecurityEvents;
    r["logConfigurationChanges"] = e.logConfigurationChanges;
    r["enableDataMasking"] = e.enableDataMasking;
    r["maskedFields"] = stringsToJson(e.maskedFields);
    r["excludedServices"] = stringsToJson(e.excludedServices);
    r["minimumSeverity"] = e.minimumSeverity.to!string;
    r["rateLimitPerSecond"] = e.rateLimitPerSecond;
    return r;
  }

  static AuditConfig fromRecord(Json r) {
    AuditConfig e;
    readBase(e, r);
    e.name = fieldString(r, "name");
    e.status = fieldEnum!ConfigStatus(r, "status", ConfigStatus.enabled);
    e.logDataAccess = fieldBool(r, "logDataAccess", true);
    e.logDataModification = fieldBool(r, "logDataModification", true);
    e.logSecurityEvents = fieldBool(r, "logSecurityEvents", true);
    e.logConfigurationChanges = fieldBool(r, "logConfigurationChanges", true);
    e.enableDataMasking = fieldBool(r, "enableDataMasking");
    e.maskedFields = fieldStrings(r, "maskedFields");
    e.excludedServices = fieldStrings(r, "excludedServices");
    e.minimumSeverity = fieldEnum!AuditSeverity(r, "minimumSeverity", AuditSeverity.info);
    e.rateLimitPerSecond = fieldInt(r, "rateLimitPerSecond", 8);
    return e;
  }
}
