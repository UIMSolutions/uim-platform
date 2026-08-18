/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.application.usecases.manage.buildpacks;



// import uim.platform.foundry.domain.ports.repositories.buildpack;

// import uim.platform.foundry.application.dto;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:
class ManageBuildpacksUseCase {
  protected IBuildpackRepository buildpacks;

  this(IBuildpackRepository buildpacks) {
    this.buildpacks = buildpacks;
  }

  UsecaseResult createBuildpack(CreateBuildpackRequest req) {
    if (req.tenantId.isEmpty)
      return UsecaseResult(false, "", "Tenant ID is required");

    if (req.name.isEmpty)
      return UsecaseResult(false, "", "Buildpack name is required");

    if (buildpacks.existsByName(req.tenantId, req.name))
      return UsecaseResult(false, "", "Buildpack with this name already exists");

    auto buildpack = Buildpack(req.tenantId, req.packId.isNull ? BuildpackId(createId()) : req.packId, req.createdBy);
    buildpack.name = req.name;
    buildpack.type_ = req.type_.toBuildpackType;
    buildpack.position = req.position;
    buildpack.stack = req.stack.length > 0 ? req.stack : "cflinuxfs4";
    buildpack.filename = req.filename;
    buildpack.enabled = true;
    buildpack.locked = false;

    buildpacks.save(buildpack);
    return UsecaseResult(true, buildpack.id.value, "");
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

  UsecaseResult updateBuildpack(UpdateBuildpackRequest req) {
    if (req.packId.isNull)
      return UsecaseResult(false, "", "Buildpack ID is required");
    if (req.tenantId.isEmpty)
      return UsecaseResult(false, "", "Tenant ID is required");

    auto buildpack = buildpacks.findById(req.tenantId, req.packId);
    if (buildpack.isNull)
      return UsecaseResult(false, "", "Buildpack not found");

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
    updated.updatedAt = currentTimestamp();

    buildpacks.update(updated);
    return UsecaseResult(true, updated.id.value, "");
  }

  UsecaseResult deleteBuildpack(TenantId tenantId, BuildpackId buildpackId) {
    auto buildpack = buildpacks.findById(tenantId, buildpackId);
    if (buildpack.isNull)
      return UsecaseResult(false, "", "Buildpack not found");

    if (buildpack.locked)
      return UsecaseResult(false, "", "Cannot delete a locked buildpack");

    buildpacks.remove(buildpack);
    return UsecaseResult(true, buildpack.id.value, "");
  }
}

///
unittest {
//     auto iBuildpackRepository = new BuildpackRepository();
//     auto usecase = new ManageBuildpacksUseCase(iBuildpackRepository);
//     auto tenantId = TenantId("test-tenant");
// 
//     // Test list
//     auto items = usecase.listBuildpacks(tenantId);
//     assert(items !is null);

}
