/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.domain.ports.repositories.flex_versions;
import uim.platform.ui_flexibility;

mixin(ShowModule!());

@safe:

interface FlexVersionRepository : ITenantRepository!(FlexVersion, FlexVersionId) {
  bool existsById(string tenantId, FlexVersionId id);
  FlexVersion findById(string tenantId, FlexVersionId id);
  bool removeById(string tenantId, FlexVersionId id);
  long countByTenant(string tenantId);
  FlexVersion[] findByTenantAll(string tenantId);

  /// All versions for an application, ordered by versionNumber desc
  FlexVersion[] findByApp(string tenantId, string appId);

  /// The currently active version for an application
  FlexVersion findActiveByApp(string tenantId, string appId);

  /// Specific version by number
  FlexVersion findByNumber(string tenantId, string appId, long versionNumber);
}
