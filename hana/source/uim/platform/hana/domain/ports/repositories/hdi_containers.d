/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.domain.ports.repositories.hdi_containers;

// import uim.platform.hana.domain.types;
// import uim.platform.hana.domain.entities.hdi_container;
import uim.platform.hana;

mixin(ShowModule!());

@safe:
interface HDIContainerRepository : ITenantRepository!(HDIContainer, HDIContainerId) {

  size_t countByInstance(InstanceId instanceId);
  HDIContainer[] findByInstance(InstanceId instanceId);
  void removeByInstance(InstanceId instanceId);

}
