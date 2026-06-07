/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.marketrates.domain.entities.audit_log;
import uim.platform.marketrates;

// mixin(ShowModule!());

@safe:

// Business logging entry for upload, download, and delete operations
struct AuditLog {
  mixin TenantEntity!(AuditLogId);

  AuditOperation operation;
  string         requestedBy;
  string         providerCode;
  MarketDataCategory category;
  OperationStatus status;
  string         message;
  int            recordCount;
  string         fromDate;
  string         toDate;

  Json toJson() const {
    return entityToJson
      .set("operation",    operation.to!string)
      .set("requestedBy",  requestedBy)
      .set("providerCode", providerCode)
      .set("category",     category)
      .set("status",       status.to!string)
      .set("message",      message)
      .set("recordCount",  recordCount)
      .set("fromDate",     fromDate)
      .set("toDate",       toDate);
  }
}
