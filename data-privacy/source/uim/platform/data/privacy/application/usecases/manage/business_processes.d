/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.application.usecases.manage.business_processes;

import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class ManageBusinessProcessesUseCase : UIMUseCase {
  private BusinessProcessRepository repo;

  this(BusinessProcessRepository repo) {
    this.repo = repo;
  }

  CommandResult createProcess(CreateBusinessProcessRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult("", "Tenant ID is required");
    if (req.name.length == 0)
      return CommandResult("", "Name is required");

    auto now = Clock.currStdTime();
    auto p = BusinessProcess();
    p.id = randomUUID();
    p.tenantId = req.tenantId;
    p.name = req.name;
    p.description = req.description;
    p.controllerId = req.controllerId;
    p.purposes = req.purposes;
    p.legalBases = req.legalBases;
    p.owner = req.owner;
    p.isActive = true;
    p.createdAt = now;
    p.updatedAt = now;

    repo.save(p);
    return CommandResult(p.id, "");
  }

  BusinessProcess* getProcess(BusinessProcessId id, TenantId tenantId) {
    return repo.findById(id, tenantId);
  }

  BusinessProcess[] listProcesses(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult updateProcess(UpdateBusinessProcessRequest req) {
    auto p = repo.findById(req.id, req.tenantId);
    if (p is null)
      return CommandResult("", "Business process not found");

    if (req.name.length > 0) p.name = req.name;
    if (req.description.length > 0) p.description = req.description;
    if (req.purposes.length > 0) p.purposes = req.purposes;
    if (req.legalBases.length > 0) p.legalBases = req.legalBases;
    if (req.owner.length > 0) p.owner = req.owner;
    p.updatedAt = Clock.currStdTime();

    repo.update(*p);
    return CommandResult(p.id, "");
  }

  void deleteProcess(BusinessProcessId id, TenantId tenantId) {
    repo.remove(id, tenantId);
  }
}
