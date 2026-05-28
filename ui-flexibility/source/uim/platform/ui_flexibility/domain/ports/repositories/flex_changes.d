/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.domain.ports.repositories.flex_changes;
import uim.platform.ui_flexibility;

mixin(ShowModule!());

@safe:

interface FlexChangeRepository : ITenantRepository!(FlexChange, FlexChangeId) {
  bool existsById(TenantId tenantId, FlexChangeId id);
  FlexChange findById(TenantId tenantId, FlexChangeId id);
  bool removeById(TenantId tenantId, FlexChangeId id);
  long countByTenant(TenantId tenantId);
  FlexChange[] findByTenantAll(TenantId tenantId);

  /// Find all active changes for a specific application
  FlexChange[] findByApp(TenantId tenantId, string appId);

  /// Find changes by layer (customer/user/vendor)
  FlexChange[] findByLayer(TenantId tenantId, string appId, ChangeLayer layer);

  /// Find by change type
  FlexChange[] findByChangeType(TenantId tenantId, string appId, ChangeType changeType);
}
