/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.domain.ports.repositories.flex_applications;
import uim.platform.ui_flexibility;

// mixin(ShowModule!());

@safe:

interface FlexApplicationRepository : ITenantRepository!(FlexApplication, FlexApplicationId) {
  bool existsById(TenantId tenantId, FlexApplicationId id);
  FlexApplication findById(TenantId tenantId, FlexApplicationId id);
  bool removeById(TenantId tenantId, FlexApplicationId id);
  long countByTenant(TenantId tenantId);
  FlexApplication[] findByTenantAll(TenantId tenantId);

  /// Find by application ID within a tenant
  FlexApplication findByApp(TenantId tenantId, string appId);

  /// All active applications for a tenant
  FlexApplication[] findActiveByTenant(TenantId tenantId);

  /// Find by namespace
  FlexApplication[] findByNamespace(TenantId tenantId, string namespace_);
}
