/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.application.usecases.manage.business_subprocesses;

import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class ManageBusinessSubprocessesUseCase : UIMUseCase {
  private BusinessSubprocessRepository repo;

  this(BusinessSubprocessRepository repo) {
    this.repo = repo;
  }

  CommandResult createSubprocess(CreateBusinessSubprocessRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult("", "Tenant ID is required");
    if (req.parentProcessid.isEmpty)
      return CommandResult("", "Parent process ID is required");
    if (req.name.length == 0)
      return CommandResult("", "Name is required");

    auto now = Clock.currStdTime();
    auto sp = BusinessSubprocess();
    sp.id = randomUUID();
    sp.tenantId = req.tenantId;
    sp.parentProcessId = req.parentProcessId;
    sp.name = req.name;
    sp.description = req.description;
    sp.purposes = req.purposes;
    sp.dataCategories = req.dataCategories;
    sp.owner = req.owner;
    sp.isActive = true;
    sp.createdAt = now;
    sp.updatedAt = now;

    repo.save(sp);
    return CommandResult(sp.id, "");
  }

  BusinessSubprocess* getSubprocess(BusinessSubprocessId id, TenantId tenantId) {
    return repo.findById(id, tenantId);
  }

  BusinessSubprocess[] listSubprocesses(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  BusinessSubprocess[] listByParentProcess(TenantId tenantId, BusinessProcessId parentId) {
    return repo.findByParentProcess(tenantId, parentId);
  }

  CommandResult updateSubprocess(UpdateBusinessSubprocessRequest req) {
    auto sp = repo.findById(req.id, req.tenantId);
    if (sp is null)
      return CommandResult("", "Business subprocess not found");

    if (req.name.length > 0) sp.name = req.name;
    if (req.description.length > 0) sp.description = req.description;
    if (req.purposes.length > 0) sp.purposes = req.purposes;
    if (req.dataCategories.length > 0) sp.dataCategories = req.dataCategories;
    if (req.owner.length > 0) sp.owner = req.owner;
    sp.updatedAt = Clock.currStdTime();

    repo.update(*sp);
    return CommandResult(sp.id, "");
  }

  void deleteSubprocess(BusinessSubprocessId id, TenantId tenantId) {
    repo.remove(id, tenantId);
  }
}
