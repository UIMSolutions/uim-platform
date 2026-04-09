/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.application.usecases.manage.instances;

// import uim.platform.hana.domain.types;
// import uim.platform.hana.domain.entities.instance;
// import uim.platform.hana.domain.ports.repositories.instances;
// import uim.platform.hana.domain.services.instance_validator;
// import uim.platform.hana.application.dto;

// import uim.platform.service;
// import std.conv : to;
import uim.platform.hana;

mixin(ShowModule!());

@safe:
class ManageInstancesUseCase : UIMUseCase {
  private InstanceRepository repo;

  this(InstanceRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateInstanceRequest r) {
    auto err = InstanceValidator.validate(r.id, r.name);
    if (err.length > 0)
      return CommandResult(false, "", err);

    auto existing = repo.findById(r.id);
    if (existing.id.length > 0)
      return CommandResult(false, "", "Instance already exists");

    DatabaseInstance i;
    i.id = r.id;
    i.tenantId = r.tenantId;
    i.name = r.name;
    i.description = r.description;
    i.status = InstanceStatus.creating;
    i.version_ = r.version_;
    i.region = r.region;
    i.availabilityZone = r.availabilityZone;
    i.enableScriptServer = r.enableScriptServer;
    i.enableDocStore = r.enableDocStore;
    i.enableDataLake = r.enableDataLake;
    i.allowAllIpAccess = r.allowAllIpAccess;
    i.whitelistedIps = r.whitelistedIps;

    i.resources.memoryGB = r.memoryGB;
    i.resources.vcpus = r.vcpus;
    i.resources.storageGB = r.storageGB;

    import core.time : MonoTime;
    auto now = MonoTime.currTime.ticks;
    i.createdAt = now;
    i.modifiedAt = now;

    repo.save(i);
    return CommandResult(true, i.id, "");
  }

  DatabaseInstance get_(InstanceId id) {
    return repo.findById(id);
  }

  DatabaseInstance[] list(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult update(UpdateInstanceRequest r) {
    auto existing = repo.findById(r.id);
    if (existing.id.isEmpty)
      return CommandResult(false, "", "Instance not found");

    existing.name = r.name;
    existing.description = r.description;
    existing.resources.memoryGB = r.memoryGB;
    existing.resources.vcpus = r.vcpus;
    existing.resources.storageGB = r.storageGB;
    existing.enableScriptServer = r.enableScriptServer;
    existing.enableDocStore = r.enableDocStore;
    existing.allowAllIpAccess = r.allowAllIpAccess;
    existing.whitelistedIps = r.whitelistedIps;

    import core.time : MonoTime;
    existing.modifiedAt = MonoTime.currTime.ticks;

    repo.update(existing);
    return CommandResult(true, existing.id, "");
  }

  CommandResult performAction(InstanceActionRequest r) {
    auto existing = repo.findById(r.id);
    if (existing.id.isEmpty)
      return CommandResult(false, "", "Instance not found");

    switch (r.action) {
      case "start":
        existing.status = InstanceStatus.starting;
        break;
      case "stop":
        existing.status = InstanceStatus.stopping;
        break;
      case "restart":
        existing.status = InstanceStatus.starting;
        break;
      default:
        return CommandResult(false, "", "Unknown action: " ~ r.action);
    }

    import core.time : MonoTime;
    existing.modifiedAt = MonoTime.currTime.ticks;

    repo.update(existing);
    return CommandResult(true, existing.id, "");
  }

  CommandResult remove(InstanceId id) {
    auto existing = repo.findById(id);
    if (existing.id.isEmpty)
      return CommandResult(false, "", "Instance not found");

    repo.remove(id);
    return CommandResult(true, id.toString, "");
  }

  size_t count(TenantId tenantId) {
    return repo.countByTenant(tenantId);
  }
}
