/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.ports.services.demo_data;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// Driving port: fills a tenant with a realistic sample landscape
/// (service catalog, global account, directories, subaccounts, environments …).
interface IDemoDataService {
  /// True if the tenant has no global accounts and no service plans yet.
  bool isEmpty(TenantId tenantId);

  /// Seed the tenant. Does nothing (and returns success) if it is not empty, unless force is set.
  UsecaseResult seed(TenantId tenantId, bool force = false);
}
