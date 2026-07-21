/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.infrastructure.persistence.repositories.conditions;
import uim.platform.health_fhir;

mixin(ShowModule!());

@safe:

class MemoryConditionRepository : TenantRepository!(Condition, ConditionId), ConditionRepository {

  bool existsById(TenantId tenantId, ConditionId id) {
    return !findById(tenantId, id).isNull;
  }

  Condition findById(TenantId tenantId, ConditionId id) {
    foreach (c; findByTenant(tenantId)) {
      if (c.id == id) return c;
    }
    return Condition.init;
  }

  void removeById(TenantId tenantId, ConditionId id) {
    auto c = findById(tenantId, id);
    if (!c.isNull) remove(c);
  }

  size_t countByTenant(TenantId tenantId) {
    return findByTenant(tenantId).length;
  }

  Condition[] findByTenantAll(TenantId tenantId) {
    return findByTenant(tenantId);
  }

  Condition[] findByPatient(TenantId tenantId, string patientRef) {
    Condition[] results;
    foreach (c; findByTenant(tenantId)) {
      if (c.subject_.reference_ == patientRef) results ~= c;
    }
    return results;
  }
}
