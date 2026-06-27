/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.infrastructure.persistence.memory.organizations;
import uim.platform.health_fhir;

// mixin(ShowModule!());

@safe:

class MemoryOrganizationRepository : TentRepository!(Organization, OrganizationId), OrganizationRepository {

  bool existsById(TenantId tenantId, OrganizationId id) {
    return !findById(tenantId, id).isNull;
  }

  Organization findById(TenantId tenantId, OrganizationId id) {
    foreach (o; findByTenant(tenantId)) {
      if (o.id == id) return o;
    }
    return Organization.init;
  }

  void removeById(TenantId tenantId, OrganizationId id) {
    auto o = findById(tenantId, id);
    if (!o.isNull) remove(o);
  }

  size_t countByTenant(TenantId tenantId) {
    return findByTenant(tenantId).length;
  }

  Organization[] findByTenantAll(TenantId tenantId) {
    return findByTenant(tenantId);
  }
}
