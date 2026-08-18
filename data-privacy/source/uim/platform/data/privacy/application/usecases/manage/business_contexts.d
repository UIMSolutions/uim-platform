/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.application.usecases.manage.business_contexts;

import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class ManageBusinessContextsUseCase {
  protected BusinessContextRepository businessContexts;

  this(BusinessContextRepository businessContexts) {
    this.businessContexts = businessContexts;
  }

  UsecaseResult createContext(CreateBusinessContextRequest req) {
    if (req.tenantId.isEmpty)
      return UsecaseResult(false, "", "Tenant ID is required");
    if (req.name.isEmpty)
      return UsecaseResult(false, "", "Name is required");

    auto ctx = BusinessContext(req.tenantId);
    ctx.name = req.name;
    ctx.description = req.description;
    ctx.controllerGroupId = req.controllerGroupId;
    ctx.status = BusinessContextStatus.draft;
    ctx.version_ = 1;
    ctx.dataCategories = req.dataCategories.map!(c => c.toPersonalDataCategory).array;
    ctx.purposes = req.purposes.map!(p => p.toProcessingPurpose).array;
    ctx.dataCategoryAttributes = req.dataCategoryAttributes;
    ctx.isCrossRoleEnabled = req.isCrossRoleEnabled;

    businessContexts.save(ctx);
    return UsecaseResult(true, ctx.id.value, "");
  }

  BusinessContext getContext(TenantId tenantId, BusinessContextId id) {
    return businessContexts.findById(tenantId, id);
  }

  BusinessContext[] listContexts(TenantId tenantId) {
    return businessContexts.findByTenant(tenantId);
  }

  BusinessContext[] listByStatus(TenantId tenantId, BusinessContextStatus status) {
    return businessContexts.findByStatus(tenantId, status);
  }

  UsecaseResult updateContext(UpdateBusinessContextRequest req) {
    auto ctx = businessContexts.findById(req.tenantId, req.contextId);
    if (ctx.isNull)
      return UsecaseResult(false, "", "Business context not found");

    if (req.name.length > 0) ctx.name = req.name;
    if (req.description.length > 0) ctx.description = req.description;
    if (req.dataCategories.length > 0) ctx.dataCategories = req.dataCategories.map!(c => c.toPersonalDataCategory).array;
    if (req.purposes.length > 0) ctx.purposes = req.purposes.map!(p => p.toProcessingPurpose).array;
    if (req.dataCategoryAttributes.length > 0) ctx.dataCategoryAttributes = req.dataCategoryAttributes;
    ctx.isCrossRoleEnabled = req.isCrossRoleEnabled;
    ctx.updatedAt = currentTimestamp();

    businessContexts.update(ctx);
    return UsecaseResult(true, ctx.id.value, "");
  }

  UsecaseResult activateContext(ActivateBusinessContextRequest req) {
    auto ctx = businessContexts.findById(req.tenantId, req.contextId);
    if (ctx.isNull)
      return UsecaseResult(false, "", "Business context not found");

    if (ctx.status == BusinessContextStatus.active)
      return UsecaseResult(false, "", "Business context already active");

    ctx.status = BusinessContextStatus.active;
    ctx.activatedAt = currentTimestamp();
    ctx.updatedAt = ctx.activatedAt;

    businessContexts.update(ctx);
    return UsecaseResult(true, ctx.id.value, "");
  }

  UsecaseResult deleteContext(TenantId tenantId, BusinessContextId id) {
    auto ctx = businessContexts.findById(tenantId, id);
    if (ctx.isNull)
      return UsecaseResult(false, "", "Business context not found");

    businessContexts.remove(ctx);
    return UsecaseResult(true, ctx.id.value, "");
  }
}
