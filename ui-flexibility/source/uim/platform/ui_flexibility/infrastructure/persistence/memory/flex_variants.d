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

  bool existsById(string tenantId, FlexVariantId id) {
    return !findById(tenantId, id).isNull;
  }

  FlexVariant findById(string tenantId, FlexVariantId id) {
    foreach (v; findByTenant(tenantId))
      if (v.id_ == id) return v;
    return FlexVariant.init;
  }

  bool removeById(string tenantId, FlexVariantId id) {
    return remove(tenantId, id);
  }

  long countByTenant(string tenantId) {
    return cast(long) findByTenant(tenantId).length;
  }

  FlexVariant[] findByTenantAll(string tenantId) {
    return findByTenant(tenantId);
  }

  FlexVariant[] findByApp(string tenantId, string appId) {
    FlexVariant[] result;
    foreach (v; findByTenant(tenantId))
      if (v.appId_ == appId) result ~= v;
    return result;
  }

  FlexVariant[] findByType(string tenantId, string appId, VariantType variantType) {
    FlexVariant[] result;
    foreach (v; findByTenant(tenantId))
      if (v.appId_ == appId && v.variantType_ == variantType) result ~= v;
    return result;
  }

  FlexVariant[] findPublicByApp(string tenantId, string appId) {
    FlexVariant[] result;
    foreach (v; findByTenant(tenantId))
      if (v.appId_ == appId && v.isPublic_) result ~= v;
    return result;
  }

  FlexVariant findDefaultByApp(string tenantId, string appId, VariantType variantType) {
    foreach (v; findByTenant(tenantId))
      if (v.appId_ == appId && v.variantType_ == variantType && v.isDefault_) return v;
    return FlexVariant.init;
  }
}
