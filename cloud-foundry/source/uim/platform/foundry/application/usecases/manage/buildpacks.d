module uim.platform.cloud_foundry.application.usecases.manage.buildpacks;

import std.uuid;
import std.datetime.systime : Clock;

import uim.platform.cloud_foundry.domain.types;
import uim.platform.cloud_foundry.domain.entities.buildpack;

// import uim.platform.cloud_foundry.domain.ports.buildpack;
import uim.platform.cloud_foundry.domain.ports;
import uim.platform.cloud_foundry.application.dto;

class ManageBuildpacksUseCase {
  private BuildpackRepository repo;

  this(BuildpackRepository repo) {
    this.repo = repo;
  }

  CommandResult createBuildpack(CreateBuildpackRequest req) {
    if (req.tenantId.length == 0)
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
    if (req.id.length == 0)
      return CommandResult("", "Buildpack ID is required");
    if (req.tenantId.length == 0)
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
