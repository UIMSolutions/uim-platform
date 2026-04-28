/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.application.usecases.manage.business_contexts;

import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class ManageBusinessContextsUseCase { // TODO: UIMUseCase {
  private BusinessContextRepository repo;

  this(BusinessContextRepository repo) {
    this.repo = repo;
  }

  CommandResult createContext(CreateBusinessContextRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.name.length == 0)
      return CommandResult(false, "", "Name is required");

    auto now = Clock.currStdTime();
    auto ctx = BusinessContext();
    ctx.id = randomUUID();
    ctx.tenantId = req.tenantId;
    ctx.name = req.name;
    ctx.description = req.description;
    ctx.controllerGroupId = req.controllerGroupId;
    ctx.status = BusinessContextStatus.draft;
    ctx.version_ = 1;
    ctx.dataCategories = req.dataCategories;
    ctx.purposes = req.purposes;
    ctx.dataCategoryAttributes = req.dataCategoryAttributes;
    ctx.isCrossRoleEnabled = req.isCrossRoleEnabled;
    ctx.createdAt = now;
    ctx.updatedAt = now;

    repo.save(ctx);
    return CommandResult(ctx.id, "");
  }

  BusinessContext* getContext(BusinessContextId tenantId, id tenantId) {
    return repo.findById(tenantId, id);
  }

  BusinessContext[] listContexts(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  BusinessContext[] listByStatus(TenantId tenantId, BusinessContextStatus status) {
    return repo.findByStatus(tenantId, status);
  }

  CommandResult updateContext(UpdateBusinessContextRequest req) {
    auto ctx = repo.findById(req.id, req.tenantId);
    if (ctx.isNull)
      return CommandResult(false, "", "Business context not found");

    if (req.name.length > 0) ctx.name = req.name;
    if (req.description.length > 0) ctx.description = req.description;
    if (req.dataCategories.length > 0) ctx.dataCategories = req.dataCategories;
    if (req.purposes.length > 0) ctx.purposes = req.purposes;
    if (req.dataCategoryAttributes.length > 0) ctx.dataCategoryAttributes = req.dataCategoryAttributes;
    ctx.isCrossRoleEnabled = req.isCrossRoleEnabled;
    ctx.updatedAt = Clock.currStdTime();

    repo.update(*ctx);
    return CommandResult(ctx.id, "");
  }

  CommandResult activateContext(ActivateBusinessContextRequest req) {
    auto ctx = repo.findById(req.id, req.tenantId);
    if (ctx.isNull)
      return CommandResult(false, "", "Business context not found");
    if (ctx.status == BusinessContextStatus.active)
      return CommandResult(false, "", "Business context already active");

    ctx.status = BusinessContextStatus.active;
    ctx.activatedAt = Clock.currStdTime();
    ctx.updatedAt = ctx.activatedAt;

    repo.update(*ctx);
    return CommandResult(ctx.id, "");
  }

  void deleteContext(BusinessContextId tenantId, id tenantId) {
    repo.removeById(tenantId, id);
  }
}
