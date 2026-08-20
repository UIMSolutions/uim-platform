/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_privacy.application.usecases.manage.business_processes;

import uim.platform.data_privacy;

mixin(ShowModule!());

@safe:
class ManageBusinessProcessesUseCase {
  protected IBusinessProcessRepository repo;

  this(IBusinessProcessRepository repo) {
    this.repo = repo;
  }

  UsecaseResult createProcess(CreateBusinessProcessRequest req) {
    if (req.tenantId.isEmpty)
      return UsecaseResult(false, "", "Tenant ID is required");
    if (req.name.isEmpty)
      return UsecaseResult(false, "", "Name is required");

    auto p = BusinessProcess(req.tenantId);
    p.name = req.name;
    p.description = req.description;
    p.controllerId = req.controllerId;
    p.purposes = req.purposes.map!(p => p.toProcessingPurpose).array;
    p.legalBases = req.legalBases.map!(b => b.toLegalBasis).array;
    p.owner = req.owner;
    p.isActive = true;

    repo.save(p);
    return UsecaseResult(true, p.id.value, "");
  }

  BusinessProcess getProcess(TenantId tenantId, BusinessProcessId id) {
    return repo.findById(tenantId, id);
  }

  BusinessProcess[] listProcesses(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  UsecaseResult updateProcess(UpdateBusinessProcessRequest req) {
    auto p = repo.findById(req.tenantId, req.processId);
    if (p.isNull)
      return UsecaseResult(false, "", "Business process not found");

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
    return UsecaseResult(true, p.id.value, "");
  }

  UsecaseResult deleteProcess(TenantId tenantId, BusinessProcessId id) {
    auto entity = repo.findById(tenantId, id);
    if (entity.isNull)
      return UsecaseResult(false, "", "Business process not found");

    repo.remove(entity);
    return UsecaseResult(true, entity.id.value, "");
  }
}
