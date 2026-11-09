/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.domain.exceptions.audit;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

/// Base class of all business exceptions raised by the audit log domain.
class AuditLogException : Exception {
  this(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, file, line);
  }
}

/// A business rule on the input was violated (missing tenant, empty message, ...).
class AuditValidationException : AuditLogException {
  this(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, file, line);
  }
}

/// Audit logging is switched off for the whole tenant.
class AuditLoggingDisabledException : AuditLogException {
  this(string msg = "Audit logging is disabled for this tenant",
      string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, file, line);
  }
}

/// Audit logging is switched off for the requested category.
class AuditCategoryDisabledException : AuditLogException {
  AuditCategory category;

  this(AuditCategory category, string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, file, line);
    this.category = category;
  }
}

/// The entry's severity is below the tenant's minimum severity threshold.
class AuditSeverityFilteredException : AuditLogException {
  this(string msg = "Severity is below the configured minimum severity",
      string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, file, line);
  }
}
