/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.application.usecases.manage.repositories;

// // import std.datetime.systime : Clock;
// // import std.uuid : randomUUID;

// import uim.platform.dms.application.application.dto;
// import uim.platform.dms.application.domain.entities.repository;
// import uim.platform.dms.application.domain.ports.repositoriess;
// import uim.platform.dms.application.domain.types;
import uim.platform.dms.application;

mixin(ShowModule!());
@safe:
class ManageRepositoriesUseCase { // TODO: UIMUseCase {
  private IRepositoryRepository repo;

  this(IRepositoryRepository repo) {
    this.repo = repo;
  }

  CommandResult createRepository(CreateRepositoryRequest r) {
    if (r.name.length == 0)
      return CommandResult(false, "", "Repository name is required");
    if (r.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");

    auto existing = repo.findByName(r.name, r.tenantId);
    if (existing !is null)
      return CommandResult(false, "", "Repository with this name already exists");

    auto entity = new Repository();
    entity.id = randomUUID();
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

  Repository[] listRepositories(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  Repository getRepository(TenantId tenantId, RepositoryId repositoryId) {
    return repo.findById(tenantId, repositoryId);
  }

  CommandResult updateRepository(UpdateRepositoryRequest r) {
    auto entity = repo.findById(r.id, r.tenantId);
    if (entity is null)
      return CommandResult(false, "", "Repository not found");

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

  CommandResult archiveRepository(TenantId tenantId, RepositoryId repositoryId) {
    auto entity = repo.findById(tenantId, repositoryId);
    if (entity is null)
      return CommandResult(false, "", "Repository not found");

    entity.status = RepositoryStatus.archived;
    entity.updatedAt = Clock.currStdTime();
    repo.update(entity);
    return CommandResult(entity.id, "");
  }

  CommandResult activateRepository(TenantId tenantId, RepositoryId repositoryId) {
    auto entity = repo.findById(tenantId, repositoryId);
    if (entity is null)
      return CommandResult(false, "", "Repository not found");

    entity.status = RepositoryStatus.active;
    entity.updatedAt = Clock.currStdTime();
    repo.update(entity);
    return CommandResult(entity.id, "");
  }

  CommandResult deleteRepository(TenantId tenantId, RepositoryId repositoryId) {
    auto entity = repo.findById(tenantId, repositoryId);
    if (entity is null)
      return CommandResult(false, "", "Repository not found");

    repo.remove(tenantId, repositoryId);
    return CommandResult(true, repositoryId.toString(), "");
  }
}
