/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.application.usecases.manage.business_subprocesses;

import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class ManageBusinessSubprocessesUseCase {
  protected IBusinessSubprocessRepository repo;

  this(IBusinessSubprocessRepository repo) {
    this.repo = repo;
  }

  UsecaseResult createSubprocess(CreateBusinessSubprocessRequest req) {
    if (req.tenantId.isEmpty)
      return UsecaseResult(false, "", "Tenant ID is required");

    if (req.parentProcessId.isEmpty)
      return UsecaseResult(false, "", "Parent process ID is required");

    if (req.name.isEmpty)
      return UsecaseResult(false, "", "Name is required");

    auto sp = BusinessSubprocess(req.tenantId);
    sp.parentProcessId = req.parentProcessId;
    sp.name = req.name;
    sp.description = req.description;
    sp.purposes = req.purposes.map!(p => p.toProcessingPurpose).array;
    sp.dataCategories = req.dataCategories.map!(c => c.toPersonalDataCategory).array;
    sp.owner = req.owner;
    sp.isActive = true;

    repo.save(sp);
    return UsecaseResult(true, sp.id.value, "");
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

  UsecaseResult updateSubprocess(UpdateBusinessSubprocessRequest req) {
    auto sp = repo.findById(req.tenantId, req.subprocessId);
    if (sp.isNull)
      return UsecaseResult(false, "", "Business subprocess not found");

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
    return UsecaseResult(true, sp.id.value, "");
  }

  UsecaseResult deleteSubprocess(TenantId tenantId, BusinessSubprocessId id) {
    auto entity = repo.findById(tenantId, id);
    if (entity.isNull)
      return UsecaseResult(false, "", "Business subprocess not found");

    repo.remove(entity);
    return UsecaseResult(true, entity.id.value, "");
  }
}
