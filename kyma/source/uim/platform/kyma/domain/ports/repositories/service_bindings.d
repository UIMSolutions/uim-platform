/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.ports.repositories.service_bindings;
// import uim.platform.kyma.domain.entities.service_binding;
// import uim.platform.kyma.domain.types;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
/// Port: outgoing — service binding persistence.
interface ServiceBindingRepository : ITenantRepository!(ServiceBinding, ServiceBindingId) {
  
  bool existsById(ServiceBindingId id);
  ServiceBinding findById(ServiceBindingId id);
  void removeById(ServiceBindingId id);

  bool existsByName(NamespaceId nsId, string name);
  ServiceBinding findByName(NamespaceId nsId, string name);
  void removeByName(NamespaceId nsId, string name);

  size_t countByNamespace(NamespaceId nsId);
  ServiceBinding[] findByNamespace(NamespaceId nsId);
  void removeByNamespace(NamespaceId nsId);

  size_t countByServiceInstance(ServiceInstanceId instanceId);
  ServiceBinding[] findByServiceInstance(ServiceInstanceId instanceId);
  void removeByServiceInstance(ServiceInstanceId instanceId);

}
