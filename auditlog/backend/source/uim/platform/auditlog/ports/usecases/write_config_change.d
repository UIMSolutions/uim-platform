/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.ports.usecases.write_config_change;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

/// Driving port: record a configuration change (+ parent audit entry).
interface IWriteConfigChangeUseCase {
  UsecaseResult writeChange(WriteConfigChangeLogRequest req);
}
