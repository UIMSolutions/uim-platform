/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.application.usecases.manage.namespaces;

// import uim.platform.credential_store.domain.ports.repositories.namespaces;
// import uim.platform.credential_store.domain.entities.namespace;
// import uim.platform.credential_store.domain.services.credential_validator;
// import uim.platform.credential_store.domain.types;
// import uim.platform.credential_store.application.dto;

// import std.uuid : randomUUID;
// import std.conv : to;
import uim.platform.credential_store;

mixin(ShowModule!());

@safe:
class ManageNamespacesUseCase { // TODO: UIMUseCase {
  private NamespaceRepository repo;

  this(NamespaceRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateNamespaceRequest r) {
    if (!CredentialValidator.validateNamespaceName(r.name))
      return CommandResult(false, "", "Invalid namespace name (1-100 chars, allowed: letters, digits, _ - . : ! ~)");

    auto existing = repo.findByName(r.tenantId, r.name);
    if (existing.id.length > 0)
      return CommandResult(false, "", "Namespace already exists");

    Namespace ns;
    ns.id = randomUUID();
    ns.tenantId = r.tenantId;
    ns.name = r.name;
    ns.description = r.description;
    ns.createdBy = r.createdBy;
    ns.createdAt = currentTimestamp();
    ns.updatedAt = ns.createdAt;

    repo.save(ns);
    return CommandResult(true, ns.id, "");
  }

  CommandResult update(string id, UpdateNamespaceRequest r) {
    return update(NamespaceId(id), r);
  }

  CommandResult update(NamespaceId id, UpdateNamespaceRequest r) {
    auto ns = repo.findById(id);
    if (ns.id.isEmpty)
      return CommandResult(false, "", "Namespace not found");

    ns.description = r.description;
    ns.updatedAt = currentTimestamp();
    repo.update(ns);
    return CommandResult(true, ns.id, "");
  }

  bool getById(string id) {
    return hasById(NamespaceId(id));
  }

  bool hasById(NamespaceId id) {
    return repo.existsById(id);
  }

  Namespace getById(string id) {
    return getById(NamespaceId(id));
  }

  Namespace getById(NamespaceId id) {
    return repo.findById(id);
  }

  Namespace getByName(string tenantId, string name) {
    return getByName(TenantId(tenantId), name);
  }
  
  Namespace getByName(TenantId tenantId, string name) {
    return repo.findByName(tenantId, name);
  }

  Namespace[] list(string tenantId) {
    return list(TenantId(tenantId));
  }
  
  Namespace[] list(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  void remove(string id) {
    remove(NamespaceId(id));
  }

  void remove(NamespaceId id) {
    repo.remove(id);
  }

  size_t count(string tenantId) {
    return count(TenantId(tenantId));
  }

  size_t count(TenantId tenantId) {
    return repo.countByTenant(tenantId);
  }

  private static long currentTimestamp() {
    import core.time : Duration;
    import std.datetime.systime : Clock;

    return Clock.currStdTime();
  }
}
