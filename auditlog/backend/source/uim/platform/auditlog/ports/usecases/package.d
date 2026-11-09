/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.ports.usecases;

public {
  import uim.platform.auditlog.ports.usecases.browse_audit_records;
  import uim.platform.auditlog.ports.usecases.enforce_retention;
  import uim.platform.auditlog.ports.usecases.manage_audit_config;
  import uim.platform.auditlog.ports.usecases.manage_exports;
  import uim.platform.auditlog.ports.usecases.manage_retention;
  import uim.platform.auditlog.ports.usecases.retrieve_audit_logs;
  import uim.platform.auditlog.ports.usecases.write_audit_log;
  import uim.platform.auditlog.ports.usecases.write_config_change;
  import uim.platform.auditlog.ports.usecases.write_data_access_log;
  import uim.platform.auditlog.ports.usecases.write_security_event;
}
