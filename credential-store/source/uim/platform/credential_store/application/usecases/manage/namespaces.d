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
  private NamespaceRepository namespaces;

  this(NamespaceRepository namespaces) {
    this.namespaces = namespaces;
  }

  CommandResult create(CreateNamespaceRequest r) {
    if (!CredentialValidator.validateNamespaceName(r.name))
      return CommandResult(false, "", "Invalid namespace name (1-100 chars, allowed: letters, digits, _ - . : ! ~)");

    auto existing = namespaces.findByName(r.tenantId, r.name);
    if (!existing.isNull)
      return CommandResult(false, "", "Namespace already exists");

    Namespace ns;
    ns.initEntity(r.tenantId);
    ns.name = r.name;
    ns.description = r.description;
    ns.createdBy = r.createdBy;

    namespaces.save(ns);
    return CommandResult(true, ns.id.value, "");
  }

  CommandResult update(string id, UpdateNamespaceRequest r) {
    return update(NamespaceId(id), r);
  }

  CommandResult update(NamespaceId id, UpdateNamespaceRequest r) {
    auto ns = namespaces.findById(id);
    if (ns.isNull)
      return CommandResult(false, "", "Namespace not found");

    ns.description = r.description;
    ns.updatedAt = now();
    namespaces.update(ns);
    return CommandResult(true, ns.id.value, "");
  }

  bool hasById(NamespaceId id) {
    return namespaces.existsById(id);
  }


  Namespace getById(NamespaceId id) {
    return namespaces.findById(id);
  }

  Namespace getByName(TenantId tenantId, string name) {
    return namespaces.findByName(tenantId, name);
  }

  Namespace[] list(TenantId tenantId) {
    return namespaces.findByTenant(tenantId);
  }


  void remove(NamespaceId id) {
    namespaces.removeById(id);
  }


  size_t count(TenantId tenantId) {
    return namespaces.countByTenant(tenantId);
  }

}
