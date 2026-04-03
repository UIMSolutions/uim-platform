module uim.platform.data.privacy.application.usecases.manage_data_subjects;

// import std.uuid;
// import std.datetime.systime : Clock;

import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.data_subject;
import uim.platform.data.privacy.domain.ports.data_subject_repository;
import uim.platform.data.privacy.application.dto;

class ManageDataSubjectsUseCase
{
  private DataSubjectRepository repo;

  this(DataSubjectRepository repo)
  {
    this.repo = repo;
  }

  CommandResult createSubject(CreateDataSubjectRequest req)
  {
    if (req.tenantId.length == 0)
      return CommandResult("", "Tenant ID is required");
    if (req.displayName.length == 0)
      return CommandResult("", "Display name is required");

    // Check for duplicate external ID
    if (req.externalId.length > 0)
    {
      auto existing = repo.findByExternalId(req.externalId, req.tenantId);
      if (existing !is null)
        return CommandResult("", "Data subject with this external ID already exists");
    }

    auto now = Clock.currStdTime();
    auto subject = DataSubject();
    subject.id = randomUUID().toString();
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
    return CommandResult(subject.id, "");
  }

  DataSubject* getSubject(DataSubjectId id, TenantId tenantId)
  {
    return repo.findById(id, tenantId);
  }

  DataSubject[] listSubjects(TenantId tenantId)
  {
    return repo.findByTenant(tenantId);
  }

  DataSubject[] listByType(TenantId tenantId, DataSubjectType subjectType)
  {
    return repo.findByType(tenantId, subjectType);
  }

  CommandResult updateSubject(UpdateDataSubjectRequest req)
  {
    auto subject = repo.findById(req.id, req.tenantId);
    if (subject is null)
      return CommandResult("", "Data subject not found");

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

    repo.update(*subject);
    return CommandResult(subject.id, "");
  }

  void deleteSubject(DataSubjectId id, TenantId tenantId)
  {
    repo.remove(id, tenantId);
  }
}
