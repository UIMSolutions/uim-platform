/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.domain.ports.repositories.medication_requests;
import uim.platform.health_fhir;

// mixin(ShowModule!());

@safe:

interface MedicationRequestRepository : ITenantRepository!(MedicationRequest, MedicationRequestId) {
  bool existsById(TenantId tenantId, MedicationRequestId id);
  MedicationRequest findById(TenantId tenantId, MedicationRequestId id);
  void removeById(TenantId tenantId, MedicationRequestId id);
  size_t countByTenant(TenantId tenantId);
  MedicationRequest[] findByTenantAll(TenantId tenantId);
  MedicationRequest[] findByPatient(TenantId tenantId, string patientRef);
}
