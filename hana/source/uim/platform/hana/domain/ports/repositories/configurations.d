/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.domain.ports.repositories.configurations;

// import uim.platform.hana.domain.types;
// import uim.platform.hana.domain.entities.configuration;
import uim.platform.hana;

mixin(ShowModule!());

@safe:
interface ConfigurationRepository {
  Configuration findById(ConfigurationId id);
  Configuration[] findByTenant(TenantId tenantId);
  Configuration[] findByInstance(InstanceId instanceId);
  Configuration[] findBySection(InstanceId instanceId, string section);
  void save(Configuration c);
  void update(Configuration c);
  void remove(ConfigurationId id);
  size_t countByTenant(TenantId tenantId);
}
