/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.ports.usecases.enforce_retention;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

/// Driving port: purge audit data that is older than the retention policy allows.
interface IEnforceRetentionUseCase {
  /// Enforce for one tenant. The result data holds "cutoff" and "removed".
  UsecaseResult enforce(TenantId tenantId);
}
