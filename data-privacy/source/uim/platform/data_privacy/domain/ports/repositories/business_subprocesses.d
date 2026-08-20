/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_privacy.domain.ports.repositories.business_subprocesses;

// import uim.platform.data_privacy.domain.entities.business_subprocess;
import uim.platform.data_privacy;

mixin(ShowModule!());

@safe:
/// Port for persisting and querying business subprocesses.
interface IBusinessSubprocessRepository : ITenantRepository!(BusinessSubprocess, BusinessSubprocessId) {

  bool existsByParentProcess(TenantId tenantId, BusinessProcessId parentId);
  BusinessSubprocess[] findByParentProcess(TenantId tenantId, BusinessProcessId parentId);
  void removeByParentProcess(TenantId tenantId, BusinessProcessId parentId);
  
}
