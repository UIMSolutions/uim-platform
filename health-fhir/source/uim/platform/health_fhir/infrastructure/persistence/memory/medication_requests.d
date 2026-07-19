/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.infrastructure.persistence.memory.medication_requests;
import uim.platform.health_fhir;

mixin(ShowModule!());

@safe:

class MemoryMedicationRequestRepository : TenantRepository!(MedicationRequest, MedicationRequestId), MedicationRequestRepository {

  bool existsById(TenantId tenantId, MedicationRequestId id) {
    return !findById(tenantId, id).isNull;
  }

  MedicationRequest findById(TenantId tenantId, MedicationRequestId id) {
    foreach (mr; findByTenant(tenantId)) {
      if (mr.id == id) return mr;
    }
    return MedicationRequest.init;
  }

  void removeById(TenantId tenantId, MedicationRequestId id) {
    auto mr = findById(tenantId, id);
    if (!mr.isNull) remove(mr);
  }

  size_t countByTenant(TenantId tenantId) {
    return findByTenant(tenantId).length;
  }

  MedicationRequest[] findByTenantAll(TenantId tenantId) {
    return findByTenant(tenantId);
  }

  MedicationRequest[] findByPatient(TenantId tenantId, string patientRef) {
    MedicationRequest[] results;
    foreach (mr; findByTenant(tenantId)) {
      if (mr.subject_.reference_ == patientRef) results ~= mr;
    }
    return results;
  }
}
