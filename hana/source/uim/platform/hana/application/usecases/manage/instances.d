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

import uim.platform.hana;
mixin(ShowModule!());

@safe:
class ManageInstancesUseCase { // TODO: UIMUseCase {
  private InstanceRepository repo;

  this(InstanceRepository repo) {
    this.repo = repo;
  }

  CommandResult createDatabaseInstance(CreateInstanceRequest r) {
    auto err = InstanceValidator.validate(r.id, r.name);
    if (err.length > 0)
      return CommandResult(false, "", err);

    if (repo.existsById(r.tenantId, r.id))
      return CommandResult(false, "", "Instance already exists");

    auto i = DatabaseInstance(r.tenantId, r.  instanceId.isNull ? DatabaseInstanceId(createId()) : r.instanceId, r.createdBy);
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

    repo.save(i);
    return CommandResult(true, i.id.value, "");
  }

  DatabaseInstance getDatabaseInstance(TenantId tenantId, DatabaseInstanceId id) {
    return repo.findById(tenantId, id);
  }

  DatabaseInstance[] listDatabaseInstances(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult updateDatabaseInstance(UpdateInstanceRequest r) {
    auto existing = repo.findById(r.tenantId, r.id);
    if (existing.isNull)
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

    
    existing.updatedAt = currentTimestamp;

    repo.update(existing);
    return CommandResult(true, existing.id.value, "");
  }

  CommandResult performInstanceAction(InstanceActionRequest r) {
    auto existing = repo.findById(r.tenantId, r.id);
    if (existing.isNull)
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

    
    existing.updatedAt = currentTimestamp;

    repo.update(existing);
    return CommandResult(true, existing.id.value, "");
  }

  CommandResult deleteDatabaseInstance(TenantId tenantId, DatabaseInstanceId id) {
    auto entity = repo.findById(tenantId, id);
    if (entity.isNull)
      return CommandResult(false, "", "Instance not found");

    repo.remove(entity);
    return CommandResult(true, entity.id.value, "");
  }

  size_t countDatabaseInstances(TenantId tenantId) {
    return repo.countByTenant(tenantId);
  }
}
