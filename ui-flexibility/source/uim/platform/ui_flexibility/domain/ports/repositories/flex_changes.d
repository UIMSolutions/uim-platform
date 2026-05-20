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
  bool existsById(string tenantId, FlexChangeId id);
  FlexChange findById(string tenantId, FlexChangeId id);
  bool removeById(string tenantId, FlexChangeId id);
  long countByTenant(string tenantId);
  FlexChange[] findByTenantAll(string tenantId);

  /// Find all active changes for a specific application
  FlexChange[] findByApp(string tenantId, string appId);

  /// Find changes by layer (customer/user/vendor)
  FlexChange[] findByLayer(string tenantId, string appId, ChangeLayer layer);

  /// Find by change type
  FlexChange[] findByChangeType(string tenantId, string appId, ChangeType changeType);
}
