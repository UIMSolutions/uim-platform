/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.repositories.anonymization_configs;
// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.anonymization_config;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
/// Port for persisting and querying anonymization configurations.
interface AnonymizationConfigRepository : ITenantRepository!(AnonymizationConfig, AnonymizationConfigId) {
  // size_t countByController(TenantId tenantId, DataControllerId controllerId);
  // AnonymizationConfig[] findByController(TenantId tenantId, DataControllerId controllerId);
  // void removeByController(TenantId tenantId, DataControllerId controllerId);

  AnonymizationConfig[] findByStatus(TenantId tenantId, AnonymizationConfigStatus status);

}
