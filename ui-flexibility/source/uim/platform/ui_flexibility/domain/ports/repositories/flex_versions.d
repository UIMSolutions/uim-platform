/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.domain.ports.repositories.flex_versions;
import uim.platform.ui_flexibility;

// mixin(ShowModule!());

@safe:

interface FlexVersionRepository : ITentRepository!(FlexVersion, FlexVersionId) {
  bool existsById(TenantId tenantId, FlexVersionId id);
  FlexVersion findById(TenantId tenantId, FlexVersionId id);
  bool removeById(TenantId tenantId, FlexVersionId id);
  long countByTenant(TenantId tenantId);
  FlexVersion[] findByTenantAll(TenantId tenantId);

  /// All versions for an application, ordered by versionNumber desc
  FlexVersion[] findByApp(TenantId tenantId, string appId);

  /// The currently active version for an application
  FlexVersion findActiveByApp(TenantId tenantId, string appId);

  /// Specific version by number
  FlexVersion findByNumber(TenantId tenantId, string appId, long versionNumber);
}
