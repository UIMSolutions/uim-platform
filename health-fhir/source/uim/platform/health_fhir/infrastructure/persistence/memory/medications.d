/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.infrastructure.persistence.repositories.medications;
import uim.platform.health_fhir;

mixin(ShowModule!());

@safe:

class MemoryMedicationRepository : TenantRepository!(Medication, MedicationId), MedicationRepository {

  bool existsById(TenantId tenantId, MedicationId id) {
    return !findById(tenantId, id).isNull;
  }

  Medication findById(TenantId tenantId, MedicationId id) {
    foreach (m; findByTenant(tenantId)) {
      if (m.id == id) return m;
    }
    return Medication.init;
  }

  void removeById(TenantId tenantId, MedicationId id) {
    auto m = findById(tenantId, id);
    if (!m.isNull) remove(m);
  }

  size_t countByTenant(TenantId tenantId) {
    return findByTenant(tenantId).length;
  }

  Medication[] findByTenantAll(TenantId tenantId) {
    return findByTenant(tenantId);
  }
}
