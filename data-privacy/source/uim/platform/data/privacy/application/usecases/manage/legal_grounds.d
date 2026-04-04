/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.application.usecases.manage.legal_grounds;

// import std.uuid;
// import std.datetime.systime : Clock;

import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.legal_ground;
import uim.platform.data.privacy.domain.ports.legal_ground_repository;
import uim.platform.data.privacy.application.dto;

class ManageLegalGroundsUseCase
{
  private LegalGroundRepository repo;

  this(LegalGroundRepository repo)
  {
    this.repo = repo;
  }

  CommandResult createGround(CreateLegalGroundRequest req)
  {
    if (req.tenantId.length == 0)
      return CommandResult("", "Tenant ID is required");
    if (req.dataSubjectId.length == 0)
      return CommandResult("", "Data subject ID is required");
    if (req.description.length == 0)
      return CommandResult("", "Description is required");

    auto now = Clock.currStdTime();
    auto ground = LegalGround();
    ground.id = randomUUID().toString();
    ground.tenantId = req.tenantId;
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

    repo.save(ground);
    return CommandResult(ground.id, "");
  }

  LegalGround* getGround(LegalGroundId id, TenantId tenantId)
  {
    return repo.findById(id, tenantId);
  }

  LegalGround[] listGrounds(TenantId tenantId)
  {
    return repo.findByTenant(tenantId);
  }

  LegalGround[] listByDataSubject(TenantId tenantId, DataSubjectId subjectId)
  {
    return repo.findByDataSubject(tenantId, subjectId);
  }

  LegalGround[] listByBasis(TenantId tenantId, LegalBasis basis)
  {
    return repo.findByBasis(tenantId, basis);
  }

  LegalGround[] listByPurpose(TenantId tenantId, ProcessingPurpose purpose)
  {
    return repo.findByPurpose(tenantId, purpose);
  }

  CommandResult updateGround(UpdateLegalGroundRequest req)
  {
    auto ground = repo.findById(req.id, req.tenantId);
    if (ground is null)
      return CommandResult("", "Legal ground not found");

    if (req.description.length > 0)
      ground.description = req.description;
    if (req.legalReference.length > 0)
      ground.legalReference = req.legalReference;
    if (req.categories.length > 0)
      ground.categories = req.categories;
    ground.isActive = req.isActive;
    if (req.validUntil > 0)
      ground.validUntil = req.validUntil;

    repo.update(*ground);
    return CommandResult(ground.id, "");
  }

  void deleteGround(LegalGroundId id, TenantId tenantId)
  {
    repo.remove(id, tenantId);
  }
}
