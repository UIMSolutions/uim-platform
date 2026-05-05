/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.infrastructure.persistence.memory.retention_rules;

// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.retention_rule;
// import uim.platform.data.privacy.domain.ports.repositories.retention_rules;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class MemoryRetentionRuleRepository : RetentionRuleRepository {

  // #region ByDefault 
  bool existsDefault(TenantId tenantId) {
    foreach (r; findByTenant(tenantId))
      if (r.isDefault && r.status == RetentionRuleStatus.active)
        return true;
    return false;
  }

  RetentionRule findDefault(TenantId tenantId) {
    foreach (r; findByTenant(tenantId))
      if (r.isDefault && r.status == RetentionRuleStatus.active)
        return r;
    return RetentionRule.init;
  }

  void removeDefault(TenantId tenantId) {
    foreach (r; findByTenant(tenantId))
      if (r.isDefault)
        remove(r.id);
  }
  // #endregion ByDefault 

  // #region ByPurpose
  size_t countByPurpose(TenantId tenantId, ProcessingPurpose purpose) {
    return findByPurpose(tenantId, purpose).length;
  }

  RetentionRule[] filterByPurpose(RetentionRule[] records, ProcessingPurpose purpose) {
    return records.filter!(r => r.purpose == purpose).array;
  }

  RetentionRule[] findByPurpose(TenantId tenantId, ProcessingPurpose purpose) {
    return filterByPurpose(findByTenant(tenantId), purpose);
  }

  void removeByPurpose(TenantId tenantId, ProcessingPurpose purpose) {
    findByPurpose(tenantId, purpose).each!(entity => remove(entity));
  }
  // #endregion ByPurpose

}
