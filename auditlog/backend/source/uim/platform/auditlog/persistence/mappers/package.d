/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Converters between persistence records (JSON documents) and domain entities.
module uim.platform.auditlog.persistence.mappers;

public {
  import uim.platform.auditlog.persistence.mappers.audit_config;
  import uim.platform.auditlog.persistence.mappers.audit_log_entry;
  import uim.platform.auditlog.persistence.mappers.config_change_log;
  import uim.platform.auditlog.persistence.mappers.data_access_log;
  import uim.platform.auditlog.persistence.mappers.export_job;
  import uim.platform.auditlog.persistence.mappers.json_fields;
  import uim.platform.auditlog.persistence.mappers.retention_policy;
  import uim.platform.auditlog.persistence.mappers.security_event;
}
