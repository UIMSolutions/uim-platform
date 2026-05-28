/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.infrastructure.persistence.memory.flex_variants;
import uim.platform.ui_flexibility;

mixin(ShowModule!());

@safe:

class MemoryFlexVariantRepository : TenantRepository!(FlexVariant, FlexVariantId), FlexVariantRepository {

  bool existsById(TenantId tenantId, FlexVariantId id) {
    return !findById(tenantId, id).isNull;
  }

  FlexVariant findById(TenantId tenantId, FlexVariantId id) {
    foreach (v; findByTenant(tenantId))
      if (v.id_ == id) return v;
    return FlexVariant.init;
  }

  bool removeById(TenantId tenantId, FlexVariantId id) {
    return remove(tenantId, id);
  }

  long countByTenant(TenantId tenantId) {
    return cast(long) findByTenant(tenantId).length;
  }

  FlexVariant[] findByTenantAll(TenantId tenantId) {
    return findByTenant(tenantId);
  }

  FlexVariant[] findByApp(TenantId tenantId, string appId) {
    FlexVariant[] result;
    foreach (v; findByTenant(tenantId))
      if (v.appId_ == appId) result ~= v;
    return result;
  }

  FlexVariant[] findByType(TenantId tenantId, string appId, VariantType variantType) {
    FlexVariant[] result;
    foreach (v; findByTenant(tenantId))
      if (v.appId_ == appId && v.variantType_ == variantType) result ~= v;
    return result;
  }

  FlexVariant[] findPublicByApp(TenantId tenantId, string appId) {
    FlexVariant[] result;
    foreach (v; findByTenant(tenantId))
      if (v.appId_ == appId && v.isPublic_) result ~= v;
    return result;
  }

  FlexVariant findDefaultByApp(TenantId tenantId, string appId, VariantType variantType) {
    foreach (v; findByTenant(tenantId))
      if (v.appId_ == appId && v.variantType_ == variantType && v.isDefault_) return v;
    return FlexVariant.init;
  }
}
