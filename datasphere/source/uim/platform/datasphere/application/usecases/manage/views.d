/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.application.usecases.manage.views;

import uim.platform.datasphere.domain.types;
import uim.platform.datasphere.domain.entities.view_;
import uim.platform.datasphere.domain.ports.repositories.views;
import uim.platform.datasphere.application.dto;

import uim.platform.service;
import std.conv : to;

class ManageViewsUseCase : UIMUseCase {
  private ViewRepository repo;

  this(ViewRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateViewRequest r) {
    if (r.name.length == 0)
      return CommandResult(false, "", "View name is required");
    if (r.spaceId.isEmpty)
      return CommandResult(false, "", "Space ID is required");

    import std.uuid : randomUUID;
    auto id = randomUUID();

    View v;
    v.id = randomUUID();
    v.tenantId = r.tenantId;
    v.spaceId = r.spaceId;
    v.name = r.name;
    v.description = r.description;
    v.businessName = r.businessName;
    v.sqlExpression = r.sqlExpression;
    v.isExposed = r.isExposed;

    import core.time : MonoTime;
    auto now = MonoTime.currTime.ticks;
    v.createdAt = now;
    v.modifiedAt = now;

    repo.save(v);
    return CommandResult(true, v.id, "");
  }

  View getById(ViewId id, SpaceId spaceId) {
    return repo.findById(id, spaceId);
  }

  View[] list(SpaceId spaceId) {
    return repo.findBySpace(spaceId);
  }

  View[] listExposed(SpaceId spaceId) {
    return repo.findExposed(spaceId);
  }

  CommandResult update(UpdateViewRequest r) {
    auto existing = repo.findById(r.viewId, r.spaceId);
    if (existing.id.isEmpty)
      return CommandResult(false, "", "View not found");

    existing.name = r.name;
    existing.description = r.description;
    existing.businessName = r.businessName;
    existing.sqlExpression = r.sqlExpression;
    existing.isExposed = r.isExposed;
    existing.isPersisted = r.isPersisted;

    import core.time : MonoTime;
    existing.modifiedAt = MonoTime.currTime.ticks;

    repo.update(existing);
    return CommandResult(true, existing.id, "");
  }

  CommandResult remove(ViewId id, SpaceId spaceId) {
    auto existing = repo.findById(id, spaceId);
    if (existing.id.isEmpty)
      return CommandResult(false, "", "View not found");

    repo.remove(id, spaceId);
    return CommandResult(true, id.toString, "");
  }
}
