/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.application.usecases.manage.legal_grounds;
// import std.uuid;
// import std.datetime.systime : Clock;
// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.legal_ground;
// import uim.platform.data.privacy.domain.ports.repositories.legal_grounds;
// import uim.platform.data.privacy.application.dto;

import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class ManageLegalGroundsUseCase { // TODO: UIMUseCase {
  private LegalGroundRepository legalGrounds;

  this(LegalGroundRepository legalGrounds) {
    this.legalGrounds = legalGrounds;
  }

  CommandResult createGround(CreateLegalGroundRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.dataSubjectId.isEmpty)
      return CommandResult(false, "", "Data subject ID is required");
    if (req.description.length == 0)
      return CommandResult(false, "", "Description is required");

    auto now = Clock.currStdTime();
    LegalGround ground;
    ground.initEntity(req.tenantId);
    ground.dataSubjectId = req.dataSubjectId;
    ground.basis = req.basis;
    ground.purpose = req.purpose;
    ground.description = req.description;
    ground.legalReference = req.legalReference;
    ground.categories = req.categories;
    ground.isActive = true;
    ground.validFrom = req.validFrom > 0 ? req.validFrom : now;
    ground.validUntil = req.validUntil;
    ground.createdAt = now;

    legalGrounds.save(ground);
    return CommandResult(true, ground.id.value, "");
  }

  LegalGround getGround(TenantId tenantId, LegalGroundId id) {
    return legalGrounds.findById(tenantId, id);
  }

  LegalGround[] listGrounds(TenantId tenantId) {
    return legalGrounds.findByTenant(tenantId);
  }

  LegalGround[] listByDataSubject(TenantId tenantId, DataSubjectId subjectId) {
    return legalGrounds.findByDataSubject(tenantId, subjectId);
  }

  LegalGround[] listByBasis(TenantId tenantId, LegalBasis basis) {
    return legalGrounds.findByBasis(tenantId, basis);
  }

  LegalGround[] listByPurpose(TenantId tenantId, ProcessingPurpose purpose) {
    return legalGrounds.findByPurpose(tenantId, purpose);
  }

  CommandResult updateGround(UpdateLegalGroundRequest req) {
    auto ground = legalGrounds.findById(req.tenantId, req.id);
    if (ground.isNull)
      return CommandResult(false, "", "Legal ground not found");

    if (req.description.length > 0)
      ground.description = req.description;
    if (req.legalReference.length > 0)
      ground.legalReference = req.legalReference;
    if (req.categories.length > 0)
      ground.categories = req.categories;
    ground.isActive = req.isActive;
    if (req.validUntil > 0)
      ground.validUntil = req.validUntil;

    legalGrounds.update(ground);
    return CommandResult(true, ground.id.value, "");
  }

  CommandResult deleteGround(TenantId tenantId, LegalGroundId id) {
    auto ground = legalGrounds.findById(tenantId, id);
    if (ground.isNull)
      return CommandResult(false, "", "Legal ground not found");

    legalGrounds.remove(ground);
    return CommandResult(true, ground.id.value, "");
  }
}
