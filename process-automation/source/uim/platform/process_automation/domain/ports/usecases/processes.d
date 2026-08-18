/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.ports.usecases.processes;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
interface IManageProcessesUseCase { 

    UsecaseResult createProcess(CreateProcessRequest r);
    Process getProcess(TenantId tenantId, ProcessId processId);
    Process[] listProcesses(TenantId tenantId);
    Process[] listProcesses(TenantId tenantId, ProjectId projectId);
    UsecaseResult updateProcess(UpdateProcessRequest r);
    UsecaseResult deployProcess(DeployProcessRequest r);
    UsecaseResult deleteProcess(TenantId tenantId, ProcessId processId);

}
