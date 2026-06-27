/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.domain.ports.repositories.encounters;
import uim.platform.health_fhir;

// mixin(ShowModule!());

@safe:

interface EncounterRepository : ITenantRepository!(Encounter, EncounterId) {
  bool existsById(TenantId tenantId, EncounterId id);
  Encounter findById(TenantId tenantId, EncounterId id);
  void removeById(TenantId tenantId, EncounterId id);
  size_t countByTenant(TenantId tenantId);
  Encounter[] findByTenantAll(TenantId tenantId);
  Encounter[] findByPatient(TenantId tenantId, string patientRef);
}
