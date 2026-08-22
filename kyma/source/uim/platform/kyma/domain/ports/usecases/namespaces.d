/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.ports.usecases.namespaces;
// import uim.platform.kyma.application.dto;
// import uim.platform.kyma.domain.entities.namespace;
// import uim.platform.kyma.domain.ports.repositories.namespaces;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:
/// Application service for Kubernetes namespace management.
interface IManageNamespacesUseCase {

  UsecaseResult createNamespace(CreateNamespaceRequest req);

  UsecaseResult updateNamespace(UpdateNamespaceRequest req);

  bool hasNamespace(TenantId tenantId, NamespaceId namespaceId);

  Namespace getNamespace(TenantId tenantId, NamespaceId namespaceId);

  Namespace[] listNamespaces(TenantId tenantId, KymaEnvironmentId envId);

  UsecaseResult deleteNamespace(TenantId tenantId, NamespaceId namespaceId);
  
}
