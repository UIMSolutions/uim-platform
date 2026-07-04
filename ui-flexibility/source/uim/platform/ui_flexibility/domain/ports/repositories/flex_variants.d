/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.domain.ports.repositories.flex_variants;
import uim.platform.ui_flexibility;

mixin(ShowModule!());

@safe:

interface FlexVariantRepository : ITenantRepository!(FlexVariant, FlexVariantId) {
  bool existsById(TenantId tenantId, FlexVariantId id);
  FlexVariant findById(TenantId tenantId, FlexVariantId id);
  bool removeById(TenantId tenantId, FlexVariantId id);
  long countByTenant(TenantId tenantId);
  FlexVariant[] findByTenantAll(TenantId tenantId);

  /// All variants for an application
  FlexVariant[] findByApp(TenantId tenantId, string appId);

  /// Variants of a specific type (filterBar, table, chart)
  FlexVariant[] findByType(TenantId tenantId, string appId, VariantType variantType);

  /// Public/shared variants
  FlexVariant[] findPublicByApp(TenantId tenantId, string appId);

  /// Default variant for a given app + type combination
  FlexVariant findDefaultByApp(TenantId tenantId, string appId, VariantType variantType);
}
