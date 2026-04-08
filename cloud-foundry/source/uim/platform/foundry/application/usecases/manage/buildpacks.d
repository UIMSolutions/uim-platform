/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.application.usecases.manage.buildpacks;

// import std.uuid;
// import std.datetime.systime : Clock;

import uim.platform.foundry.domain.types;
import uim.platform.foundry.domain.entities.buildpack;

// import uim.platform.foundry.domain.ports.repositories.buildpack;
import uim.platform.foundry.domain.ports;
import uim.platform.foundry.application.dto;

class ManageBuildpacksUseCase : UIMUseCase {
  private BuildpackRepository repo;

  this(BuildpackRepository repo) {
    this.repo = repo;
  }

  CommandResult createBuildpack(CreateBuildpackRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult("", "Tenant ID is required");
    if (req.name.length == 0)
      return CommandResult("", "Buildpack name is required");

    auto existing = repo.findByName(req.tenantId, req.name);
    if (existing !is null)
      return CommandResult("", "Buildpack with this name already exists");

    auto now = Clock.currStdTime();
    auto bp = Buildpack();
    bp.id = randomUUID().toString();
    bp.tenantId = req.tenantId;
    bp.name = req.name;
    bp.type_ = req.type_;
    bp.position = req.position;
    bp.stack = req.stack.length > 0 ? req.stack : "cflinuxfs4";
    bp.filename = req.filename;
    bp.enabled = true;
    bp.locked = false;
    bp.createdBy = req.createdBy;
    bp.createdAt = now;
    bp.updatedAt = now;

    repo.save(bp);
    return CommandResult(bp.id, "");
  }

  Buildpack* getBuildpack(BuildpackId id, TenantId tenantId) {
    return repo.findById(id, tenantId);
  }

  Buildpack[] listBuildpacks(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  Buildpack[] listEnabled(TenantId tenantId) {
    return repo.findEnabled(tenantId);
  }

  CommandResult updateBuildpack(UpdateBuildpackRequest req) {
    if (req.id.isEmpty)
      return CommandResult("", "Buildpack ID is required");
    if (req.tenantId.isEmpty)
      return CommandResult("", "Tenant ID is required");

    auto existing = repo.findById(req.id, req.tenantId);
    if (existing is null)
      return CommandResult("", "Buildpack not found");

    auto updated = *existing;
    if (req.name.length > 0)
      updated.name = req.name;
    if (req.position > 0)
      updated.position = req.position;
    if (req.stack.length > 0)
      updated.stack = req.stack;
    if (req.filename.length > 0)
      updated.filename = req.filename;
    updated.enabled = req.enabled;
    updated.locked = req.locked;
    updated.updatedAt = Clock.currStdTime();

    repo.update(updated);
    return CommandResult(updated.id, "");
  }

  CommandResult deleteBuildpack(BuildpackId id, TenantId tenantId) {
    auto existing = repo.findById(id, tenantId);
    if (existing is null)
      return CommandResult("", "Buildpack not found");

    if (existing.locked)
      return CommandResult("", "Cannot delete a locked buildpack");

    repo.remove(id, tenantId);
    return CommandResult(id, "");
  }
}
