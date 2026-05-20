/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.domain.ports.repositories.flex_applications;
import uim.platform.ui_flexibility;

mixin(ShowModule!());

@safe:

interface FlexApplicationRepository : ITenantRepository!(FlexApplication, FlexApplicationId) {
  bool existsById(string tenantId, FlexApplicationId id);
  FlexApplication findById(string tenantId, FlexApplicationId id);
  bool removeById(string tenantId, FlexApplicationId id);
  long countByTenant(string tenantId);
  FlexApplication[] findByTenantAll(string tenantId);

  /// Find by application ID within a tenant
  FlexApplication findByAppId(string tenantId, string appId);

  /// All active applications for a tenant
  FlexApplication[] findActiveByTenant(string tenantId);

  /// Find by namespace
  FlexApplication[] findByNamespace(string tenantId, string namespace_);
}
