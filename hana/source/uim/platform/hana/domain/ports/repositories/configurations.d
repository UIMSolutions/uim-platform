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
interface ConfigurationRepository : ITenantRepository!(Configuration, ConfigurationId) {

  size_t countByInstance(DatabaseInstanceId instanceId);
  Configuration[] findByInstance(DatabaseInstanceId instanceId);
  void removeByInstance(DatabaseInstanceId instanceId);

  size_t countBySection(DatabaseInstanceId instanceId, string section);
  Configuration[] findBySection(DatabaseInstanceId instanceId, string section);
  void removeBySection(DatabaseInstanceId instanceId, string section);

}
