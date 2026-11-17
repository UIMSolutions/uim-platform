/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.ports.usecases.housekeeping;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// Apply all time driven transitions of a tenant: overdue tasks, event status,
/// expired surveys and notifications, scheduled syncs of content providers.
interface IHousekeepingUseCase {
  HousekeepingReport run(TenantId tenantId);
}
