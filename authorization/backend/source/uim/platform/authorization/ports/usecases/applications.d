/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization.ports.usecases.applications;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

/// Driving port: applications.
interface IManageApplications {
  ManagedApplication createApplication(CreateApplicationRequest request);
  ManagedApplication updateApplication(UpdateApplicationRequest request);
  ManagedApplication getApplication(TenantId tenantId, ManagedApplicationId id);
  /// By id or — if no application has that id — by name; throws notFound.
  ManagedApplication resolveApplication(TenantId tenantId, string idOrName);
  ManagedApplication[] listApplications(TenantId tenantId);
  /// Deletes the application with its APIs, policies and their assignments.
  void deleteApplication(TenantId tenantId, ManagedApplicationId id);
}

/// Driving port: the APIs of applications.
interface IManageApplicationApis {
  ApplicationApi createApi(CreateApplicationApiRequest request);
  ApplicationApi updateApi(UpdateApplicationApiRequest request);
  ApplicationApi getApi(TenantId tenantId, ApplicationApiId id);
  ApplicationApi[] listApis(TenantId tenantId);
  ApplicationApi[] listApis(TenantId tenantId, ManagedApplicationId applicationId);
  void deleteApi(TenantId tenantId, ApplicationApiId id);
}
