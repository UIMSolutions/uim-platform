/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.application.usecases.manage.consent_purposes;

import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class ManageConsentPurposesUseCase { // TODO: UIMUseCase {
  private ConsentPurposeRepository repo;

  this(ConsentPurposeRepository repo) {
    this.repo = repo;
  }

  CommandResult createPurpose(CreateConsentPurposeRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.name.length == 0)
      return CommandResult(false, "", "Name is required");

    ConsentPurpose cp;
    cp.initEntity(req.tenantId);
    cp.controllerId = req.controllerId;
    cp.name = req.name;
    cp.description = req.description;
    cp.purpose = req.purpose;
    cp.dataCategories = req.dataCategories;
    cp.status = ConsentPurposeStatus.draft;
    cp.consentFormTemplate = req.consentFormTemplate;
    cp.version_ = req.version_;
    cp.requiresExplicitConsent = req.requiresExplicitConsent;
    cp.validFrom = req.validFrom;
    cp.validUntil = req.validUntil;

    repo.save(cp);
    return CommandResult(true, cp.id.value, "");
  }

  ConsentPurpose getPurpose(TenantId tenantId, ConsentPurposeId id) {
    return repo.findById(tenantId, id);
  }

  ConsentPurpose[] listPurposes(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  ConsentPurpose[] listByController(TenantId tenantId, DataControllerId controllerId) {
    return repo.findByController(tenantId, controllerId);
  }

  CommandResult updatePurpose(UpdateConsentPurposeRequest req) {
    auto cp = repo.findById(req.tenantId, req.id);
    if (cp.isNull)
      return CommandResult(false, "", "Consent purpose not found");

    if (req.name.length > 0)
      cp.name = req.name;
    if (req.description.length > 0)
      cp.description = req.description;
    if (req.consentFormTemplate.length > 0)
      cp.consentFormTemplate = req.consentFormTemplate;
    if (req.version_.length > 0)
      cp.version_ = req.version_;
    cp.requiresExplicitConsent = req.requiresExplicitConsent;
    cp.updatedAt = Clock.currStdTime();

    repo.update(cp);
    return CommandResult(true, cp.id.value, "");
  }

  CommandResult deletePurpose(TenantId tenantId, ConsentPurposeId id) {
    auto cp = repo.findById(tenantId, id);
    if (cp.isNull)
      return CommandResult(false, "", "Consent purpose not found");

    repo.remove(cp);
    return CommandResult(true, cp.id.value, "");
  }
}
