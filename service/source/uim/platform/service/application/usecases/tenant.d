module uim.platform.service.application.usecases.tenant;

import uim.platform.service;

mixin(ShowModule!());

@safe:

class TenantUseCase(TRepository, TEntity, TId) {
  protected TRepository repository;

  this(TRepository repository) {
    this.repository = repository;
  }

  bool execute(Json[string] parameters) {
    // Business logic for the tenant use case

    return true;
  }

  bool hasById(TenantId tenantId, TId id) {
    return repository.existsById(tenantId, id);
  }

  TEntity getById(TenantId tenantId, TId id) {
    return repository.findById(tenantId, id);
  }

  TEntity[] list(TenantId tenantId) {
    return repository.findByTenant(tenantId);
  }
}