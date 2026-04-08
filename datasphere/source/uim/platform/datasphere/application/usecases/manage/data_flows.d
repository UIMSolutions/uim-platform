/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.application.usecases.manage.data_flows;

import uim.platform.datasphere.domain.types;
import uim.platform.datasphere.domain.entities.data_flow;
import uim.platform.datasphere.domain.ports.repositories.data_flows;
import uim.platform.datasphere.domain.services.task_scheduler;
import uim.platform.datasphere.application.dto;

import uim.platform.service;
import std.conv : to;

class ManageDataFlowsUseCase : UIMUseCase {
  private DataFlowRepository repo;

  this(DataFlowRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateDataFlowRequest r) {
    if (r.name.length == 0)
      return CommandResult(false, "", "Data flow name is required");
    if (r.spaceid.isEmpty)
      return CommandResult(false, "", "Space ID is required");

    import std.uuid : randomUUID;
    auto id = randomUUID().to!string;

    DataFlow df;
    df.id = id;
    df.tenantId = r.tenantId;
    df.spaceId = r.spaceId;
    df.name = r.name;
    df.description = r.description;
    df.status = FlowStatus.inactive;
    df.scheduleExpression = r.scheduleExpression;

    import core.time : MonoTime;
    auto now = MonoTime.currTime.ticks;
    df.createdAt = now;
    df.modifiedAt = now;

    repo.save(df);
    return CommandResult(true, df.id, "");
  }

  DataFlow get_(DataFlowId id, SpaceId spaceId) {
    return repo.findById(id, spaceId);
  }

  DataFlow[] list(SpaceId spaceId) {
    return repo.findBySpace(spaceId);
  }

  CommandResult patch(PatchDataFlowRequest r) {
    auto existing = repo.findById(r.dataFlowId, r.spaceId);
    if (existing.id.isEmpty)
      return CommandResult(false, "", "Data flow not found");

    import core.time : MonoTime;
    existing.modifiedAt = MonoTime.currTime.ticks;

    repo.update(existing);
    return CommandResult(true, existing.id, "");
  }

  CommandResult remove(DataFlowId id, SpaceId spaceId) {
    auto existing = repo.findById(id, spaceId);
    if (existing.id.isEmpty)
      return CommandResult(false, "", "Data flow not found");

    repo.remove(id, spaceId);
    return CommandResult(true, id, "");
  }
}
