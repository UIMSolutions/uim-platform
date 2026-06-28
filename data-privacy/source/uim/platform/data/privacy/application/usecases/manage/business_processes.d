/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.application.usecases.manage.business_processes;

import uim.platform.data.privacy;

// mixin(ShowModule!());

@safe:
class ManageBusinessProcessesUseCase { // TODO: UIMUseCase {
  private BusinessProcessRepository repo;

  this(BusinessProcessRepository repo) {
    this.repo = repo;
  }

  CommandResult createProcess(CreateBusinessProcessRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.name.length == 0)
      return CommandResult(false, "", "Name is required");

    BusinessProcess p;
    p.initEntity(req.tenantId);

    p.name = req.name;
    p.description = req.description;
    p.controllerId = req.controllerId;
    p.purposes = req.purposes.map!(p => p.toProcessingPurpose).array;
    p.legalBases = req.legalBases.map!(b => b.toLegalBasis).array;
    p.owner = req.owner;
    p.isActive = true;

    repo.save(p);
    return CommandResult(true, p.id.value, "");
  }

  BusinessProcess getProcess(TenantId tenantId, BusinessProcessId id) {
    return repo.find(tenantId, id);
  }

  BusinessProcess[] listProcesses(TenantId tenantId) {
    return repo.find(tenantId);
  }

  CommandResult updateProcess(UpdateBusinessProcessRequest req) {
    auto p = repo.findById(req.tenantId, req.processId);
    if (p.isNull)
      return CommandResult(false, "", "Business process not found");

    if (req.name.length > 0)
      p.name = req.name;
    if (req.description.length > 0)
      p.description = req.description;
    if (req.purposes.length > 0)
      p.purposes = req.purposes.map!(p => p.toProcessingPurpose).array;
    if (req.legalBases.length > 0)
      p.legalBases = req.legalBases.map!(b => b.toLegalBasis).array;
    if (req.owner.length > 0)
      p.owner = req.owner;
    p.updatedAt = currentTimestamp();

    repo.update(p);
    return CommandResult(true, p.id.value, "");
  }

  CommandResult deleteProcess(TenantId tenantId, BusinessProcessId id) {
    auto entity = repo.find(tenantId, id);
    if (entity.isNull)
      return CommandResult(false, "", "Business process not found");

    repo.remove(entity);
    return CommandResult(true, entity.id.value, "");
  }
}
