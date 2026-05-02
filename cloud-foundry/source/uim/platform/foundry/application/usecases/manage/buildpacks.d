/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.application.usecases.manage.buildpacks;

// import std.uuid;
// import std.datetime.systime : Clock;

// import uim.platform.foundry.domain.types;
// import uim.platform.foundry.domain.entities.buildpack;

// // import uim.platform.foundry.domain.ports.repositories.buildpack;
// import uim.platform.foundry.domain.ports;
// import uim.platform.foundry.application.dto;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:
class ManageBuildpacksUseCase { // TODO: UIMUseCase {
  private IBuildpackRepository buildpacks;

  this(IBuildpackRepository buildpacks) {
    this.buildpacks = buildpacks;
  }

  CommandResult createBuildpack(CreateBuildpackRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.name.length == 0)
      return CommandResult(false, "", "Buildpack name is required");

    auto existing = buildpacks.findByName(req.tenantId, req.name);
    if (!existing.isNull)
      return CommandResult(false, "", "Buildpack with this name already exists");

    auto now = Clock.currStdTime();
    auto buildpack = Buildpack();
    buildpack.initEntity(req.tenantId, req.createdBy);

    buildpack.name = req.name;
    buildpack.type_ = req.type_;
    buildpack.position = req.position;
    buildpack.stack = req.stack.length > 0 ? req.stack : "cflinuxfs4";
    buildpack.filename = req.filename;
    buildpack.enabled = true;
    buildpack.locked = false;

    buildpacks.save(buildpack);
    return CommandResult(true, buildpack.id.value, "");
  }

  Buildpack getBuildpack(TenantId tenantId, BuildpackId buildpackId) {
    return buildpacks.findById(tenantId, buildpackId);
  }

  Buildpack[] listBuildpacks(TenantId tenantId) {
    return buildpacks.findByTenant(tenantId);
  }

  Buildpack[] listEnabled(TenantId tenantId) {
    return buildpacks.findEnabled(tenantId);
  }

  CommandResult updateBuildpack(UpdateBuildpackRequest req) {
    if (req.isNull)
      return CommandResult(false, "", "Buildpack ID is required");
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");

    auto buildpack = buildpacks.findById(req.tenantId, req.id);
    if (buildpack.isNull)
      return CommandResult(false, "", "Buildpack not found");

    auto updated = buildpack;
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

    buildpacks.update(updated);
    return CommandResult(true, updated.id.value, "");
  }

  CommandResult deleteBuildpack(TenantId tenantId, BuildpackId buildpackId) {
    auto buildpack = buildpacks.findById(tenantId, buildpackId);
    if (buildpack.isNull)
      return CommandResult(false, "", "Buildpack not found");

    if (buildpack.locked)
      return CommandResult(false, "", "Cannot delete a locked buildpack");

    buildpacks.remove(buildpack);
    return CommandResult(true, buildpack.id.value, "");
  }
}
