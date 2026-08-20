/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_privacy.domain.ports.usecases.business_processes;

import uim.platform.data_privacy;

mixin(ShowModule!());

@safe:
interface IManageBusinessProcessesUseCase { 

  UsecaseResult createProcess(CreateBusinessProcessRequest req);
  BusinessProcess getProcess(TenantId tenantId, BusinessProcessId id);
  BusinessProcess[] listProcesses(TenantId tenantId);
  UsecaseResult updateProcess(UpdateBusinessProcessRequest req);
  UsecaseResult deleteProcess(TenantId tenantId, BusinessProcessId id);
  
}
