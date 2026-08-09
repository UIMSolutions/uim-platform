/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.usescases.business_processes;

import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
interface IManageBusinessProcessesUseCase { 

  CommandResult createProcess(CreateBusinessProcessRequest req);
  BusinessProcess getProcess(TenantId tenantId, BusinessProcessId id);
  BusinessProcess[] listProcesses(TenantId tenantId);
  CommandResult updateProcess(UpdateBusinessProcessRequest req);
  CommandResult deleteProcess(TenantId tenantId, BusinessProcessId id);
  
}
