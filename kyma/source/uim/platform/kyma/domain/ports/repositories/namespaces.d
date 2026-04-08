/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.ports.repositories.namespaces;

// import uim.platform.kyma.domain.entities.namespace;
// import uim.platform.kyma.domain.types;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
/// Port: outgoing — namespace persistence.
interface NamespaceRepository {
  Namespace findById(NamespaceId id);
  Namespace findByName(KymaEnvironmentId envId, string name);
  Namespace[] findByEnvironment(KymaEnvironmentId envId);
  Namespace[] findByTenant(TenantId tenantId);
  void save(Namespace ns);
  void update(Namespace ns);
  void remove(NamespaceId id);
}
