/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.application.usecases.manage.business_subprocesses;

import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class ManageBusinessSubprocessesUseCase { // TODO: UIMUseCase {
  private BusinessSubprocessRepository repo;

  this(BusinessSubprocessRepository repo) {
    this.repo = repo;
  }

  CommandResult createSubprocess(CreateBusinessSubprocessRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");

    if (req.parentProcessId.isEmpty)
      return CommandResult(false, "", "Parent process ID is required");

    if (req.name.length == 0)
      return CommandResult(false, "", "Name is required");

    BusinessSubprocess sp;
    sp.initEntity(req.tenantId);

    sp.parentProcessId = req.parentProcessId;
    sp.name = req.name;
    sp.description = req.description;
    sp.purposes = req.purposes.map!(p => p.toProcessingPurpose).array;
    sp.dataCategories = req.dataCategories.map!(c => c.toPersonalDataCategory).array;
    sp.owner = req.owner;
    sp.isActive = true;

    repo.save(sp);
    return CommandResult(true, sp.id.value, "");
  }

  BusinessSubprocess getSubprocess(TenantId tenantId, BusinessSubprocessId id) {
    return repo.findById(tenantId, id);
  }

  BusinessSubprocess[] listSubprocesses(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  BusinessSubprocess[] listByParentProcess(TenantId tenantId, BusinessProcessId parentId) {
    return repo.findByParentProcess(tenantId, parentId);
  }

  CommandResult updateSubprocess(UpdateBusinessSubprocessRequest req) {
    auto sp = repo.findById(req.tenantId, req.subprocessId);
    if (sp.isNull)
      return CommandResult(false, "", "Business subprocess not found");

    if (req.name.length > 0)
      sp.name = req.name;
    if (req.description.length > 0)
      sp.description = req.description;
    if (req.purposes.length > 0)
      sp.purposes = req.purposes.map!(p => p.toProcessingPurpose).array;
    if (req.dataCategories.length > 0)
      sp.dataCategories = req.dataCategories.map!(c => c.toPersonalDataCategory).array;
    if (req.owner.length > 0)
      sp.owner = req.owner;
    sp.updatedAt = currentTimestamp();

    repo.update(sp);
    return CommandResult(true, sp.id.value, "");
  }

  CommandResult deleteSubprocess(TenantId tenantId, BusinessSubprocessId id) {
    auto entity = repo.findById(tenantId, id);
    if (entity.isNull)
      return CommandResult(false, "", "Business subprocess not found");

    repo.remove(entity);
    return CommandResult(true, entity.id.value, "");
  }
}
