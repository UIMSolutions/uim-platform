/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.domain.ports.repositories.medications;
import uim.platform.health_fhir;

// mixin(ShowModule!());

@safe:

interface MedicationRepository : ITentRepository!(Medication, MedicationId) {
  bool existsById(TenantId tenantId, MedicationId id);
  Medication findById(TenantId tenantId, MedicationId id);
  void removeById(TenantId tenantId, MedicationId id);
  size_t countByTenant(TenantId tenantId);
  Medication[] findByTenantAll(TenantId tenantId);
}
