/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.infrastructure.persistence.memory.configurations;

// import uim.platform.hana.domain.types;
// import uim.platform.hana.domain.entities.configuration;
// import uim.platform.hana.domain.ports.repositories.configurations;
// 
// import std.algorithm : filter;
// import std.array : array;

import uim.platform.hana;

mixin(ShowModule!());

@safe:
class MemoryConfigurationRepository : TenantRepository!(Configuration, ConfigurationId), ConfigurationRepository {

  size_t countByInstance(InstanceId instanceId) {
    return findByInstance(instanceId).length;
  }
  Configuration[] filterByInstance(Configuration[] configurations, InstanceId instanceId) {
    return configurations.filter!(c => c.instanceId == instanceId).array;
  }
  Configuration[] findByInstance(InstanceId instanceId) {
    return filterByInstance(findAll(), instanceId);
  }
  void removeByInstance(InstanceId instanceId) {
    findByInstance(instanceId).each!(c => remove(c.id));
  }

  size_t countBySection(InstanceId instanceId, string section) {
    return findBySection(instanceId, section).length;
  }
  Configuration[] filterBySection(Configuration[] configurations, InstanceId instanceId, string section) {
    return configurations.filter!(c => c.instanceId == instanceId && c.section == section).array;
  }
  Configuration[] findBySection(InstanceId instanceId, string section) {
    return filterBySection(findAll(), instanceId, section);
  }
  void removeBySection(InstanceId instanceId, string section) {
    findBySection(instanceId, section).each!(c => remove(c.id));
  }

}
