/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.application.usecases.manage.data_subjects;

// import uim.platform.data.privacy.domain.entities.data_subject;
// import uim.platform.data.privacy.domain.ports.repositories.data_subjects;
// import uim.platform.data.privacy.application.dto;
import uim.platform.data.privacy;

// mixin(ShowModule!());

@safe:
class ManageDataSubjectsUseCase { // TODO: UIMUseCase {
  private DataSubjectRepository repo;

  this(DataSubjectRepository repo) {
    this.repo = repo;
  }

  CommandResult createSubject(CreateDataSubjectRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.displayName.length == 0)
      return CommandResult(false, "", "Display name is required");

    // Check for duplicate external ID
    if (req.externalId.length > 0) {
      auto existing = repo.findByExternalId(req.tenantId, req.externalId);
      if (!existing.isNull)
        return CommandResult(false, "", "Data subject with this external ID already exists");
    }

    DataSubject subject;
    subject.initEntity(req.tenantId);
    
    subject.subjectType = req.subjectType;
    subject.externalId = req.externalId;
    subject.displayName = req.displayName;
    subject.email = req.email;
    subject.sourceSystem = req.sourceSystem;
    subject.country = req.country;
    subject.isActive = true;

    repo.save(subject);
    return CommandResult(true, subject.id.value, "");
  }

  DataSubject getSubject(TenantId tenantId, DataSubjectId id) {
    return repo.findById(tenantId, id);
  }

  DataSubject[] listSubjects(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  DataSubject[] listByType(TenantId tenantId, DataSubjectType subjectType) {
    return repo.findByType(tenantId, subjectType);
  }

  CommandResult updateSubject(UpdateDataSubjectRequest req) {
    auto subject = repo.findById(req.tenantId, req.id);
    if (subject.isNull)
      return CommandResult(false, "", "Data subject not found");

    if (req.displayName.length > 0)
      subject.displayName = req.displayName;
    if (req.email.length > 0)
      subject.email = req.email;
    if (req.sourceSystem.length > 0)
      subject.sourceSystem = req.sourceSystem;
    if (req.country.length > 0)
      subject.country = req.country;
    subject.subjectType = req.subjectType;
    subject.isActive = req.isActive;
    subject.updatedAt = currentTimestamp();

    repo.update(subject);
    return CommandResult(true, subject.id.value, "");
  }

  CommandResult deleteSubject(TenantId tenantId, DataSubjectId id) {
    auto subject = repo.findById(tenantId, id);
    if (subject.isNull)
      return CommandResult(false, "", "Data subject not found");

    repo.remove(subject);
    return CommandResult(true, subject.id.value, ""); // TODO: Consider using a soft delete approach instead of hard delete
  }
}
