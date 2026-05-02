/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.application.usecases.manage.system_instances;

// import uim.platform.abap_environment.application.dto;
// import uim.platform.abap_environment.domain.entities.system_instance;
// import uim.platform.abap_environment.domain.ports.repositories.system_instances;
// import uim.platform.abap_environment.domain.services.system_lifecycle_validator;
// import uim.platform.abap_environment.domain.types;

// import std.conv : to;
// import std.uuid : randomUUID;
import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:
/// Application service for ABAP system instance lifecycle management.
class ManageSystemInstancesUseCase { // TODO: UIMUseCase {
  private SystemInstanceRepository repo;

  this(SystemInstanceRepository repo) {
    this.repo = repo;
  }

  CommandResult createInstance(CreateSystemInstanceRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "System instance name is required");
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.adminEmail.length == 0)
      return CommandResult(false, "", "Admin email is required");

    // Validate SID
    if (req.sapSystemId.length > 0) {
      auto sidResult = SystemLifecycleValidator.validateSid(req.sapSystemId);
      if (!sidResult.valid)
        return CommandResult(false, "", sidResult.error);
    }

    // Unique name per tenant
    auto existing = repo.findByName(req.tenantId, req.name);
    if (!existing.isNull)
      return CommandResult(false, "", "System instance '" ~ req.name ~ "' already exists");

    SystemInstance inst;
    inst.id = randomUUID();
    inst.tenantId = req.tenantId;
    inst.subaccountId = req.subaccountId;
    inst.name = req.name;
    inst.description = req.description;
    inst.plan = parsePlan(req.plan);
    inst.status = SystemStatus.provisioning;
    inst.region = req.region;
    inst.sapSystemId = req.sapSystemId;
    inst.adminEmail = req.adminEmail;
    inst.abapRuntimeSize = req.abapRuntimeSize > 0 ? req.abapRuntimeSize : cast(ushort)4;
    inst.hanaMemorySize = req.hanaMemorySize > 0 ? req.hanaMemorySize : cast(ushort)16;
    inst.softwareVersion = req.softwareVersion;
    inst.stackVersion = req.stackVersion;

    // import std.datetime.systime : Clock;
    inst.createdAt = Clock.currStdTime();
    inst.updatedAt = inst.createdAt;

    repo.save(inst);
    return CommandResult(true, inst.id.value, "");
  }

  CommandResult updateInstance(SystemInstanceId id, UpdateSystemInstanceRequest req) {
    if (!repo.existsById(id))
      return CommandResult(false, "", "System instance not found");

    auto inst = repo.findById(id);
    if (req.description.length > 0)
      inst.description = req.description;
    if (req.abapRuntimeSize > 0)
      inst.abapRuntimeSize = req.abapRuntimeSize;
    if (req.hanaMemorySize > 0)
      inst.hanaMemorySize = req.hanaMemorySize;
    if (req.softwareVersion.length > 0)
      inst.softwareVersion = req.softwareVersion;

    // Status transition
    if (req.status.length > 0) {
      auto newStatus = req.status.to!SystemStatus;
      auto validation = SystemLifecycleValidator.validateTransition(inst.status, newStatus);
      if (!validation.valid)
        return CommandResult(false, "", validation.error);
      inst.status = newStatus;
    }

    // import std.datetime.systime : Clock;
    inst.updatedAt = Clock.currStdTime();

    repo.update(inst);
    return CommandResult(true, inst.id.value, "");
  }

  SystemInstance getInstance(SystemInstanceId id) {
    return repo.findById(id);
  }

  SystemInstance[] listInstances(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult deleteInstance(SystemInstanceId id) {
    if (!repo.existsById(id))
      return CommandResult(false, "", "System instance not found");

    auto inst = repo.findById(id);
    if (inst.status != SystemStatus.active && inst.status != SystemStatus.error
      && inst.status != SystemStatus.suspended)
      return CommandResult(false, "", "System must be in active, suspended, or error status to delete");

    inst.status = SystemStatus.deleting;
    repo.update(inst);
    return CommandResult(true, inst.id.value, "");
  }
}
