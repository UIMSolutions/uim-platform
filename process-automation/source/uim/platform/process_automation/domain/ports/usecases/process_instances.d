/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.ports.usecases.process_instances;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
interface IManageProcessInstancesUseCase { 

    UsecaseResult startProcessInstance(StartProcessInstanceRequest r);
    ProcessInstance getProcessInstance(TenantId tenantId, ProcessInstanceId id);
    ProcessInstance[] listProcessInstances(TenantId tenantId);
    ProcessInstance[] listProcessInstances(TenantId tenantId, ProcessId processId);
    ProcessInstance[] listProcessInstances(TenantId tenantId, InstanceStatus status);
    UsecaseResult performProcessInstanceAction(ProcessInstanceActionRequest r);
    UsecaseResult deleteProcessInstance(TenantId tenantId, ProcessInstanceId id);

}
