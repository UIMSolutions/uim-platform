/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.infrastructure.persistence.memory.encounters;
import uim.platform.health_fhir;

// mixin(ShowModule!());

@safe:

class MemoryEncounterRepository : TenantRepository!(Encounter, EncounterId), EncounterRepository {

  bool existsById(TenantId tenantId, EncounterId id) {
    return !findById(tenantId, id).isNull;
  }

  Encounter findById(TenantId tenantId, EncounterId id) {
    foreach (e; find(tenantId)) {
      if (e.id == id) return e;
    }
    return Encounter.init;
  }

  void removeById(TenantId tenantId, EncounterId id) {
    auto e = findById(tenantId, id);
    if (!e.isNull) remove(e);
  }

  size_t countByTenant(TenantId tenantId) {
    return find(tenantId).length;
  }

  Encounter[] findByTenantAll(TenantId tenantId) {
    return find(tenantId);
  }

  Encounter[] findByPatient(TenantId tenantId, string patientRef) {
    Encounter[] results;
    foreach (e; find(tenantId)) {
      if (e.subject_.reference_ == patientRef) results ~= e;
    }
    return results;
  }
}
