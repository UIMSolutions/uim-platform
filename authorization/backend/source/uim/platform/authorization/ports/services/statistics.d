/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization.ports.services.statistics;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

/// Driving port: figures of a tenant (dashboard, Fiori KPI header, CLI stats).
interface IAuthorizationStatistics {
  AuthorizationStatistics compute(TenantId tenantId);
}

/// Driving port: demo landscape for development, tests and showcases.
interface IDemoDataService {
  bool isEmpty(TenantId tenantId);
  /// Throws conflict if the tenant already has applications.
  DemoDataResult seed(TenantId tenantId, UserId actor);
}
