/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.ports.repositories.service_instances;

import uim.platform.kyma.domain.entities.service_instance;
import uim.platform.kyma.domain.types;

/// Port: outgoing — service instance persistence.
interface ServiceInstanceRepository {
  ServiceInstance findById(ServiceInstanceId id);
  ServiceInstance findByName(NamespaceId nsId, string name);
  ServiceInstance[] findByNamespace(NamespaceId nsId);
  ServiceInstance[] findByEnvironment(KymaEnvironmentId envId);
  ServiceInstance[] findByOffering(string offeringName);
  void save(ServiceInstance inst);
  void update(ServiceInstance inst);
  void remove(ServiceInstanceId id);
}
