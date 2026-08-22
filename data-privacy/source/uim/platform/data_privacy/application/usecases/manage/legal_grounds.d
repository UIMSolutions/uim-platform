/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_privacy.application.usecases.manage.legal_grounds;

// import uim.platform.data_privacy.domain.entities.legal_ground;
// import uim.platform.data_privacy.domain.ports.repositories.legal_grounds;
// import uim.platform.data_privacy.application.dto;

import uim.platform.data_privacy;

mixin(ShowModule!());

@safe:
class ManageLegalGroundsUseCase {
  protected ILegalGroundRepository legalGrounds;

  this(ILegalGroundRepository legalGrounds) {
    this.legalGrounds = legalGrounds;
  }

  UsecaseResult createGround(CreateLegalGroundRequest req) {
    if (req.tenantId.isEmpty)
      return UsecaseResult(false, "", "Tenant ID is required");
    if (req.dataSubjectId.isEmpty)
      return UsecaseResult(false, "", "Data subject ID is required");
    if (req.description.length == 0)
      return UsecaseResult(false, "", "Description is required");

    auto ground = LegalGround(req.tenantId);
    ground.dataSubjectId = req.dataSubjectId;
    ground.basis = req.basis;
    ground.purpose = req.purpose.toProcessingPurpose;
    ground.description = req.description;
    ground.legalReference = req.legalReference;
    ground.categories = req.categories.map!(c => c.toPersonalDataCategory).array;
    ground.isActive = true;
    ground.validFrom = req.validFrom > 0 ? req.validFrom : ground.createdAt;
    ground.validUntil = req.validUntil;

    legalGrounds.save(ground);
    return UsecaseResult(true, ground.id.value, "");
  }

  LegalGround getGround(TenantId tenantId, LegalGroundId id) {
    return legalGrounds.findById(tenantId, id);
  }

  LegalGround[] listGrounds(TenantId tenantId) {
    return legalGrounds.findByTenant(tenantId);
  }

  LegalGround[] listGrounds(TenantId tenantId, DataSubjectId subjectId) {
    return legalGrounds.findByDataSubject(tenantId, subjectId);
  }

  LegalGround[] listGrounds(TenantId tenantId, LegalBasis basis) {
    return legalGrounds.findByBasis(tenantId, basis);
  }

  LegalGround[] listGrounds(TenantId tenantId, ProcessingPurpose purpose) {
    return legalGrounds.findByPurpose(tenantId, purpose);
  }

  UsecaseResult updateGround(UpdateLegalGroundRequest req) {
    auto ground = legalGrounds.findById(req.tenantId, req.groundId);
    if (ground.isNull)
      return UsecaseResult(false, "", "Legal ground not found");

    if (req.description.length > 0)
      ground.description = req.description;
    if (req.legalReference.length > 0)
      ground.legalReference = req.legalReference;
    if (req.categories.length > 0)
      ground.categories = req.categories.map!(c => c.toPersonalDataCategory).array;
    ground.isActive = req.isActive;
    if (req.validUntil > 0)
      ground.validUntil = req.validUntil;

    legalGrounds.update(ground);
    return UsecaseResult(true, ground.id.value, "");
  }

  UsecaseResult deleteGround(TenantId tenantId, LegalGroundId id) {
    auto ground = legalGrounds.findById(tenantId, id);
    if (ground.isNull)
      return UsecaseResult(false, "", "Legal ground not found");

    legalGrounds.remove(ground);
    return UsecaseResult(true, ground.id.value, "");
  }
}
