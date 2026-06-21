/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.application.usecases.manage.namespaces;
// import uim.platform.credential_store.domain.ports.repositories.namespaces;
// import uim.platform.credential_store.domain.entities.namespace;
// import uim.platform.credential_store.domain.services.credential_validator;

// import uim.platform.credential_store.application.dto;


import uim.platform.credential_store;

// mixin(ShowModule!());

@safe:
class ManageNamespacesUseCase { // TODO: UIMUseCase {
  private NamespaceRepository namespaces;

  this(NamespaceRepository namespaces) {
    this.namespaces = namespaces;
  }

  CommandResult createNamespace(CreateNamespaceRequest r) {
    if (!CredentialValidator.validateNamespaceName(r.name))
      return CommandResult(false, "", "Invalid namespace name (1-100 chars, allowed: letters, digits, _ - . : ! ~)");

    if (namespaces.existsByName(r.tenantId, r.name))
      return CommandResult(false, "", "Namespace already exists");

    auto ns = Namespace(r.tenantId, r.createdBy);
    ns.name = r.name;
    ns.description = r.description;

    namespaces.save(ns);
    return CommandResult(true, ns.id.value, "");
  }

  CommandResult updateNamespace(UpdateNamespaceRequest r) {
    auto ns = namespaces.findById(r.tenantId, r.namespaceId);
    if (ns.isNull)
      return CommandResult(false, "", "Namespace not found");

    ns.description = r.description;
    ns.updatedAt = currentTimestamp();

    namespaces.update(ns);
    return CommandResult(true, ns.id.value, "");
  }

  bool hasNamespace(TenantId tenantId, NamespaceId id) {
    return namespaces.existsById(tenantId, id);
  }

  Namespace getNamespace(TenantId tenantId, NamespaceId id) {
    return namespaces.findById(tenantId, id);
  }

  Namespace getNamespace(TenantId tenantId, string name) {
    return namespaces.findByName(tenantId, name);
  }

  Namespace[] listNamespaces(TenantId tenantId) {
    return namespaces.findByTenant(tenantId);
  }

  CommandResult deleteNamespace(TenantId tenantId, NamespaceId namespaceId) {
    auto namespace = namespaces.findById(tenantId, namespaceId);
    if (namespace.isNull)
      return CommandResult(false, "", "Namespace not found");

    namespaces.remove(namespace);
    return CommandResult(true, namespace.id.value, "");
  }

  size_t countNamespaces(TenantId tenantId) {
    return namespaces.countByTenant(tenantId);
  }

}
