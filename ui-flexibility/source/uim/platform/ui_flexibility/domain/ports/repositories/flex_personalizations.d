/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.domain.ports.repositories.flex_personalizations;
import uim.platform.ui_flexibility;

mixin(ShowModule!());

@safe:

interface FlexPersonalizationRepository : ITenantRepository!(FlexPersonalization, FlexPersonalizationId) {
  bool existsById(TenantId tenantId, FlexPersonalizationId id);
  FlexPersonalization findById(TenantId tenantId, FlexPersonalizationId id);
  bool removeById(TenantId tenantId, FlexPersonalizationId id);
  long countByTenant(TenantId tenantId);
  FlexPersonalization[] findByTenantAll(TenantId tenantId);

  /// All personalizations for a specific user in an application
  FlexPersonalization[] findByUser(TenantId tenantId, string appId, string userId);

  /// Personalizations for a specific control and user
  FlexPersonalization findByControl(TenantId tenantId, string appId, string userId, string controlId);

  /// Remove all personalizations for a user in an app (reset user settings)
  bool removeByUser(TenantId tenantId, string appId, string userId);
}
