/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.domain.types;

import uim.platform.auditlog;

mixin(ShowModule!());
@safe:

/// Unique identifier type aliases for type safety.
struct AuditLogId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct RetentionPolicyId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct AuditConfigId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ExportJobId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct UserId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}

struct ServiceId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
