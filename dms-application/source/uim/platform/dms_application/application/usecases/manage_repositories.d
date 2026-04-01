module application.usecases.manage_repositories;

import std.datetime.systime : Clock;
import std.uuid : randomUUID;

import uim.platform.dms_application.application.dto;
import uim.platform.dms_application.domain.entities.repository;
import uim.platform.dms_application.domain.ports.repository_repository;
import uim.platform.dms_application.domain.types;

class ManageRepositoriesUseCase
{
  private IRepositoryRepository repo;

  this(IRepositoryRepository repo)
  {
    this.repo = repo;
  }

  CommandResult createRepository(CreateRepositoryRequest r)
  {
    if (r.name.length == 0)
      return CommandResult("", "Repository name is required");
    if (r.tenantId.length == 0)
      return CommandResult("", "Tenant ID is required");

    auto existing = repo.findByName(r.name, r.tenantId);
    if (existing !is null)
      return CommandResult("", "Repository with this name already exists");

    auto entity = new Repository();
    entity.id = randomUUID().toString();
    entity.tenantId = r.tenantId;
    entity.name = r.name;
    entity.description = r.description;
    entity.status = RepositoryStatus.active;
    entity.maxFileSize = r.maxFileSize > 0 ? r.maxFileSize : 104_857_600;
    entity.allowedFileTypes = r.allowedFileTypes;
    entity.createdBy = r.createdBy;
    entity.createdAt = Clock.currStdTime();
    entity.updatedAt = entity.createdAt;

    repo.save(entity);
    return CommandResult(entity.id, "");
  }

  Repository[] listRepositories(TenantId tenantId)
  {
    return repo.findByTenant(tenantId);
  }

  Repository getRepository(RepositoryId id, TenantId tenantId)
  {
    return repo.findById(id, tenantId);
  }

  CommandResult updateRepository(UpdateRepositoryRequest r)
  {
    auto entity = repo.findById(r.id, r.tenantId);
    if (entity is null)
      return CommandResult("", "Repository not found");

    if (r.name.length > 0)
      entity.name = r.name;
    if (r.description.length > 0)
      entity.description = r.description;
    if (r.maxFileSize > 0)
      entity.maxFileSize = r.maxFileSize;
    if (r.allowedFileTypes.length > 0)
      entity.allowedFileTypes = r.allowedFileTypes;
    entity.updatedAt = Clock.currStdTime();

    repo.update(entity);
    return CommandResult(entity.id, "");
  }

  CommandResult archiveRepository(RepositoryId id, TenantId tenantId)
  {
    auto entity = repo.findById(id, tenantId);
    if (entity is null)
      return CommandResult("", "Repository not found");

    entity.status = RepositoryStatus.archived;
    entity.updatedAt = Clock.currStdTime();
    repo.update(entity);
    return CommandResult(entity.id, "");
  }

  CommandResult activateRepository(RepositoryId id, TenantId tenantId)
  {
    auto entity = repo.findById(id, tenantId);
    if (entity is null)
      return CommandResult("", "Repository not found");

    entity.status = RepositoryStatus.active;
    entity.updatedAt = Clock.currStdTime();
    repo.update(entity);
    return CommandResult(entity.id, "");
  }

  CommandResult deleteRepository(RepositoryId id, TenantId tenantId)
  {
    auto entity = repo.findById(id, tenantId);
    if (entity is null)
      return CommandResult("", "Repository not found");

    repo.remove(id, tenantId);
    return CommandResult(id, "");
  }
}
