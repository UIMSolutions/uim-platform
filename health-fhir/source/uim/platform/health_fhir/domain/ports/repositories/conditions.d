/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.domain.ports.repositories.conditions;
import uim.platform.health_fhir;

// mixin(ShowModule!());

@safe:

interface ConditionRepository : ITenantRepository!(Condition, ConditionId) {
  bool existsById(TenantId tenantId, ConditionId id);
  Condition findById(TenantId tenantId, ConditionId id);
  void removeById(TenantId tenantId, ConditionId id);
  size_t countByTenant(TenantId tenantId);
  Condition[] findByTenantAll(TenantId tenantId);
  Condition[] findByPatient(TenantId tenantId, string patientRef);
}
