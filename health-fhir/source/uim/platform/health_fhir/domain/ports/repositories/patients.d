/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.domain.ports.repositories.patients;
import uim.platform.health_fhir;

// mixin(ShowModule!());

@safe:

interface PatientRepository : ITenantRepository!(Patient, PatientId) {
  bool existsById(TenantId tenantId, PatientId id);
  Patient findById(TenantId tenantId, PatientId id);
  void removeById(TenantId tenantId, PatientId id);
  size_t countByTenant(TenantId tenantId);
  Patient[] findByTenantAll(TenantId tenantId);
  Patient[] searchByName(TenantId tenantId, string namePart);
}
