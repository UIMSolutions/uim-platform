/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.domain.services.audit_policy;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

/// Pure domain service — decides whether an audit event may be recorded
/// under a tenant's AuditConfig. Throws a domain exception if not.
struct AuditPolicy {
  /// Validate an event against the configuration. A null config (no config
  /// stored for the tenant) means "log everything".
  static void ensureAllowed(const AuditConfig cfg, AuditCategory category, AuditSeverity severity) {
    if (cfg.isNull)
      return;

    if (cfg.status == ConfigStatus.disabled)
      throw new AuditLoggingDisabledException();

    final switch (category) {
    case AuditCategory.dataAccess:
      if (!cfg.logDataAccess)
        throw new AuditCategoryDisabledException(category, "Data access logging is disabled");
      break;
    case AuditCategory.dataModification:
      if (!cfg.logDataModification)
        throw new AuditCategoryDisabledException(category, "Data modification logging is disabled");
      break;
    case AuditCategory.securityEvents:
      if (!cfg.logSecurityEvents)
        throw new AuditCategoryDisabledException(category, "Security event logging is disabled");
      break;
    case AuditCategory.configuration:
      if (!cfg.logConfigurationChanges)
        throw new AuditCategoryDisabledException(category, "Configuration change logging is disabled");
      break;
    }

    if (severity < cfg.minimumSeverity)
      throw new AuditSeverityFilteredException();
  }

  /// Replace the values of masked attributes with "***" if masking is enabled.
  static AuditAttribute[] mask(const AuditConfig cfg, AuditAttribute[] attributes) {
    if (cfg.isNull || !cfg.enableDataMasking || cfg.maskedFields.length == 0)
      return attributes;

    AuditAttribute[] result;
    foreach (a; attributes) {
      if (cfg.maskedFields.canFind(a.name))
        result ~= AuditAttribute(a.name, a.oldValue.length ? "***" : "", a.newValue.length ? "***" : "");
      else
        result ~= a;
    }
    return result;
  }
}
///
unittest {
  mixin(ShowTest!("AuditPolicy"));

  AuditConfig none;
  AuditPolicy.ensureAllowed(none, AuditCategory.dataAccess, AuditSeverity.info); // no config => allowed

  auto cfg = AuditConfig.createDefault(TenantId("t1"));
  AuditPolicy.ensureAllowed(cfg, AuditCategory.dataAccess, AuditSeverity.info);

  cfg.logDataAccess = false;
  bool thrown;
  try AuditPolicy.ensureAllowed(cfg, AuditCategory.dataAccess, AuditSeverity.info);
  catch (AuditCategoryDisabledException) thrown = true;
  assert(thrown);

  cfg.logDataAccess = true;
  cfg.minimumSeverity = AuditSeverity.error;
  thrown = false;
  try AuditPolicy.ensureAllowed(cfg, AuditCategory.dataAccess, AuditSeverity.warning);
  catch (AuditSeverityFilteredException) thrown = true;
  assert(thrown);

  cfg.status = ConfigStatus.disabled;
  thrown = false;
  try AuditPolicy.ensureAllowed(cfg, AuditCategory.dataAccess, AuditSeverity.critical);
  catch (AuditLoggingDisabledException) thrown = true;
  assert(thrown);

  cfg.enableDataMasking = true;
  cfg.maskedFields = ["password"];
  auto masked = AuditPolicy.mask(cfg, [AuditAttribute("password", "a", "b"), AuditAttribute("name", "x", "y")]);
  assert(masked[0].oldValue == "***" && masked[0].newValue == "***");
  assert(masked[1].newValue == "y");
}
