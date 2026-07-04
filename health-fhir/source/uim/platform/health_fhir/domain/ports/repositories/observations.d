/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.domain.ports.repositories.observations;
import uim.platform.health_fhir;

mixin(ShowModule!());

@safe:

interface ObservationRepository : ITenantRepository!(Observation, ObservationId) {
  bool existsById(TenantId tenantId, ObservationId id);
  Observation findById(TenantId tenantId, ObservationId id);
  void removeById(TenantId tenantId, ObservationId id);
  size_t countByTenant(TenantId tenantId);
  Observation[] findByTenantAll(TenantId tenantId);
  Observation[] findByPatient(TenantId tenantId, string patientRef);
}
