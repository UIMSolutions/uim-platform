/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.repositories.business_subprocesses;

import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.business_subprocess;

/// Port for persisting and querying business subprocesses.
interface BusinessSubprocessRepository {
  bool existsByTenant(TenantId tenantId);
  BusinessSubprocess[] findByTenant(TenantId tenantId);

  bool existsById(BusinessSubprocessId id, TenantId tenantId);
  BusinessSubprocess findById(BusinessSubprocessId id, TenantId tenantId);
  BusinessSubprocess[] findByParentProcess(TenantId tenantId, BusinessProcessId parentId);
  
  void save(BusinessSubprocess subprocess);
  void update(BusinessSubprocess subprocess);
  void remove(BusinessSubprocessId id, TenantId tenantId);
}
