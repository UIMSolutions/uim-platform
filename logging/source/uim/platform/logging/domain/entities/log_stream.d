/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.domain.entities.log_stream;

import uim.platform.logging.domain.types;

struct LogStream {
  LogStreamId id;
  TenantId tenantId;
  string name;
  string description;
  LogSourceType sourceType = LogSourceType.application;
  RetentionPolicyId retentionPolicyId;
  bool isActive = true;
  string createdBy;
  long createdAt;
  long updatedAt;
}
