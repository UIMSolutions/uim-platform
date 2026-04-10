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
/**
  * A namespace is a logical grouping of Kyma resources within an environment. It serves as a scope for resource names and provides
  * isolation between different teams or applications. Namespaces allow for better organization and management of resources in a Kyma environment.
  *
  * The NamespaceRepository interface defines the contract for persisting and retrieving namespace entities. It includes methods for checking the existence of a namespace by its ID or name, finding namespaces by their environment or tenant, and saving, updating, or removing namespace entities.
  */
interface NamespaceRepository {
  bool existsById(NamespaceId id);
  Namespace findById(NamespaceId id);

  bool existsByName(KymaEnvironmentId envId, string name);
  Namespace findByName(KymaEnvironmentId envId, string name);

  Namespace[] findByEnvironment(KymaEnvironmentId envId);
  Namespace[] findByTenant(TenantId tenantId);

  void save(Namespace ns);
  void update(Namespace ns);
  void remove(NamespaceId id);
}
