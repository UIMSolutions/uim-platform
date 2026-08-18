/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.application.usecases.manage.data_flows;

// import uim.platform.datasphere.domain.entities.data_flow;
// import uim.platform.datasphere.domain.ports.repositories.data_flows;
// import uim.platform.datasphere.domain.services.task_scheduler;
// import uim.platform.datasphere.application.dto;

import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
class ManageDataFlowsUseCase {
  protected IDataFlowRepository repo;

  this(IDataFlowRepository repo) {
    this.repo = repo;
  }

  CommandResult createDataFlow(CreateDataFlowRequest r) {
    if (r.name.isEmpty)
      return CommandResult(false, "", "Data flow name is required");
    if (r.spaceId.isEmpty)
      return CommandResult(false, "", "Space ID is required");

    import std.uuid : randomUUID;

    DataFlow df = DataFlow(r.tenantId); // r.createdBy);
    df.spaceId = r.spaceId;
    df.name = r.name;
    df.description = r.description;
    df.status = FlowStatus.inactive;
    df.scheduleExpression = r.scheduleExpression;

    repo.save(df);
    return CommandResult(true, df.id.value, "");
  }

  DataFlow getDataFlow(TenantId tenantId, SpaceId spaceId, DataFlowId id) {
    return repo.findById(tenantId, spaceId, id);
  }

  DataFlow[] listDataFlows(TenantId tenantId, SpaceId spaceId) {
    return repo.findBySpace(tenantId, spaceId);
  }

  CommandResult patchDataFlow(PatchDataFlowRequest r) {
    auto flow = repo.findById(r.tenantId, r.spaceId, r.dataFlowId);
    if (flow.isNull)
      return CommandResult(false, "", "Data flow not found");

    
    flow.updatedAt = currentTimestamp;

    repo.update(flow);
    return CommandResult(true, flow.id.value, "");
  }

  CommandResult deleteDataFlow(TenantId tenantId, SpaceId spaceId, DataFlowId id) {
    auto flow = repo.findById(tenantId, spaceId, id);
    if (flow.isNull)
      return CommandResult(false, "", "Data flow not found");

    repo.remove(flow);
    return CommandResult(true, flow.id.value, "");
  }
}
