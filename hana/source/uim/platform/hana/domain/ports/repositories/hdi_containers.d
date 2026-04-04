/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.domain.ports.repositories.hdi_containers;

import uim.platform.hana.domain.types;
import uim.platform.hana.domain.entities.hdi_container;

interface HDIContainerRepository {
  HDIContainer findById(HDIContainerId id);
  HDIContainer[] findByTenant(TenantId tenantId);
  HDIContainer[] findByInstance(InstanceId instanceId);
  void save(HDIContainer c);
  void update(HDIContainer c);
  void remove(HDIContainerId id);
  long countByTenant(TenantId tenantId);
}
