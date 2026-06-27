/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.infrastructure.persistence.memory.practitioners;
import uim.platform.health_fhir;

// mixin(ShowModule!());

@safe:

class MemoryPractitionerRepository : TentRepository!(Practitioner, PractitionerId), PractitionerRepository {

  bool existsById(TenantId tenantId, PractitionerId id) {
    return !findById(tenantId, id).isNull;
  }

  Practitioner findById(TenantId tenantId, PractitionerId id) {
    foreach (p; findByTenant(tenantId)) {
      if (p.id == id) return p;
    }
    return Practitioner.init;
  }

  void removeById(TenantId tenantId, PractitionerId id) {
    auto p = findById(tenantId, id);
    if (!p.isNull) remove(p);
  }

  size_t countByTenant(TenantId tenantId) {
    return findByTenant(tenantId).length;
  }

  Practitioner[] findByTenantAll(TenantId tenantId) {
    return findByTenant(tenantId);
  }
}
