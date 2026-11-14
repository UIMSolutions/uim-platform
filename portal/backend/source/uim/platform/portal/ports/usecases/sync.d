/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.ports.usecases.sync;

import uim.platform.portal;

mixin(ShowModule!());

@safe:

/// Synchronise all active remote / federated content providers of a tenant
/// (called by the background worker, the CLI and the UIs).
interface ISyncProvidersUseCase {
  SyncReport syncAll(TenantId tenantId);
}
