/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.ports.service_binding_repository;

import uim.platform.kyma.domain.entities.service_binding;
import uim.platform.kyma.domain.types;

/// Port: outgoing — service binding persistence.
interface ServiceBindingRepository
{
  ServiceBinding findById(ServiceBindingId id);
  ServiceBinding findByName(NamespaceId nsId, string name);
  ServiceBinding[] findByNamespace(NamespaceId nsId);
  ServiceBinding[] findByServiceInstance(ServiceInstanceId instanceId);
  void save(ServiceBinding binding);
  void update(ServiceBinding binding);
  void remove(ServiceBindingId id);
}
