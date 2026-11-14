/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.ports.usecases.applications;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Driving port: application (service provider / OAuth client) registration.
interface IManageApplicationsUseCase {
  Application[] listApplications(TenantId tenantId);
  Application getApplication(TenantId tenantId, ApplicationId id);
  Application getByClientId(TenantId tenantId, string clientId);

  /// data contains "clientId" and the plain "clientSecret" (shown once).
  UsecaseResult createApplication(ApplicationDTO dto);
  UsecaseResult updateApplication(ApplicationDTO dto);
  /// data contains the new plain "clientSecret" (shown once).
  UsecaseResult rotateClientSecret(TenantId tenantId, ApplicationId id, UserId by);
  UsecaseResult deleteApplication(TenantId tenantId, ApplicationId id);
}
