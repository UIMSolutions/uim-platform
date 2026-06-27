/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.infrastructure.persistence.memory.observations;
import uim.platform.health_fhir;

// mixin(ShowModule!());

@safe:

class MemoryObservationRepository : TentRepository!(Observation, ObservationId), ObservationRepository {

  bool existsById(TenantId tenantId, ObservationId id) {
    return !findById(tenantId, id).isNull;
  }

  Observation findById(TenantId tenantId, ObservationId id) {
    foreach (o; findByTenant(tenantId)) {
      if (o.id == id) return o;
    }
    return Observation.init;
  }

  void removeById(TenantId tenantId, ObservationId id) {
    auto o = findById(tenantId, id);
    if (!o.isNull) remove(o);
  }

  size_t countByTenant(TenantId tenantId) {
    return findByTenant(tenantId).length;
  }

  Observation[] findByTenantAll(TenantId tenantId) {
    return findByTenant(tenantId);
  }

  Observation[] findByPatient(TenantId tenantId, string patientRef) {
    Observation[] results;
    foreach (o; findByTenant(tenantId)) {
      if (o.subject_.reference_ == patientRef) results ~= o;
    }
    return results;
  }
}
