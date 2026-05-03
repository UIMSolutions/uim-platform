/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.application.usecases.manage.data_subjects;

// import std.uuid;
// import std.datetime.systime : Clock;

// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.data_subject;
// import uim.platform.data.privacy.domain.ports.repositories.data_subjects;
// import uim.platform.data.privacy.application.dto;
import uim.platform.data.privacy;

mixin(ShowModule!());

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
      auto existing = repo.findByExternalId(req.externalId, req.tenantId);
      if (!existing.isNull)
        return CommandResult(false, "", "Data subject with this external ID already exists");
    }

    auto now = Clock.currStdTime();
    auto subject = DataSubject();
    subject.id = randomUUID();
    subject.tenantId = req.tenantId;
    subject.subjectType = req.subjectType;
    subject.externalId = req.externalId;
    subject.displayName = req.displayName;
    subject.email = req.email;
    subject.sourceSystem = req.sourceSystem;
    subject.country = req.country;
    subject.isActive = true;
    subject.createdAt = now;
    subject.updatedAt = now;

    repo.save(subject);
    return CommandResult(true, subject.id, "");
  }

  DataSubject getSubject(DataSubjectId tenantId, id tenantId) {
    return repo.findById(tenantId, id);
  }

  DataSubject[] listSubjects(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  DataSubject[] listByType(TenantId tenantId, DataSubjectType subjectType) {
    return repo.findByType(tenantId, subjectType);
  }

  CommandResult updateSubject(UpdateDataSubjectRequest req) {
    auto subject = repo.findById(req.id, req.tenantId);
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
    subject.updatedAt = Clock.currStdTime();

    repo.update(subject);
    return CommandResult(true, subject.id.value, "");
  }

  CommandResult deleteSubject(TenantId tenantId, DataSubjectId id) {
    auto subject = repo.findById(tenantId, id);
    if (subject.isNull)
      return CommandResult(false, "", "Data subject not found");

    repo.removeById(tenantId, id);
    return CommandResult(true, id.value, ""); // TODO: Consider using a soft delete approach instead of hard delete
  }
}
