/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.application.usecases.manage.flex_personalizations;
import uim.platform.ui_flexibility;

// mixin(ShowModule!());

@safe:

class ManageFlexPersonalizationsUseCase {
  private FlexPersonalizationRepository repo;

  this(FlexPersonalizationRepository repo) {
    this.repo = repo;
  }

  CommandResult createPersonalization(CreateFlexPersonalizationRequest r) {
    auto p = FlexPersonalization();
    p.id_         = r.personalizationId;
    p.tenant_     = r.tenantId;
    p.appId_      = r.appId;
    p.userId_     = r.userId_;
    p.controlId_  = r.controlId_;
    p.scope_      = r.scope_;
    p.changeType_ = r.changeType_;
    p.content_    = r.content_;
    p.updatedAt_  = "";
    p.isSynced_   = false;

    auto err = FlexValidator.validateFlexPersonalization(p);
    if (err !is null) return CommandResult(false, null, err);

    repo.save(r.tenantId, p);
    return CommandResult(true, p.id_.value);
  }

  CommandResult updatePersonalization(UpdateFlexPersonalizationRequest r) {
    auto p = repo.findById(r.tenantId, r.personalizationId);
    if (p.isNull) return CommandResult(false, null, "FlexPersonalization not found");
    p.content_  = r.content_;
    p.isSynced_ = r.isSynced_;
    p.updatedAt_ = "";
    repo.update(r.tenantId, p);
    return CommandResult(true, p.id_.value, "FlexPersonalization updated successfully.");
  }

  FlexPersonalization getPersonalization(TenantId tenantId, FlexPersonalizationId id) {
    return repo.findById(tenantId, id);
  }

  FlexPersonalization[] listPersonalizations(TenantId tenantId) {
    return repo.findByTenantAll(tenantId);
  }

  FlexPersonalization[] listByUser(TenantId tenantId, string appId, string userId) {
    return repo.findByUser(tenantId, appId, userId);
  }

  CommandResult deletePersonalization(TenantId tenantId, FlexPersonalizationId id) {
    auto existing = repo.findById(tenantId, id);
    if (existing.isNull)
    return CommandResult(false, null, "FlexPersonalization not found");
    repo.removeById(tenantId, id);
    return CommandResult(true, id.value, "FlexPersonalization deleted successfully.");
  }

  CommandResult resetUserPersonalizations(TenantId tenantId, string appId, string userId) {
    repo.removeByUser(tenantId, appId, userId);
    return CommandResult(true, userId, "User personalizations reset successfully.");
  }
}
