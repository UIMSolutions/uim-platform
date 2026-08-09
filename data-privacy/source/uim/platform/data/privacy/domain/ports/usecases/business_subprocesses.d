/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.usescases.business_subprocesses;

import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
interface IManageBusinessSubprocessesUseCase { 

  CommandResult createSubprocess(CreateBusinessSubprocessRequest req);
  BusinessSubprocess getSubprocess(TenantId tenantId, BusinessSubprocessId id);
  BusinessSubprocess[] listSubprocesses(TenantId tenantId);
  BusinessSubprocess[] listByParentProcess(TenantId tenantId, BusinessProcessId parentId);
  CommandResult updateSubprocess(UpdateBusinessSubprocessRequest req);
  CommandResult deleteSubprocess(TenantId tenantId, BusinessSubprocessId id);
  
}
