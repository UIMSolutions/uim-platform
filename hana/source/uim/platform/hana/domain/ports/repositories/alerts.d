/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.domain.ports.repositories.alerts;

// import uim.platform.hana.domain.types;
// import uim.platform.hana.domain.entities.alert;
import uim.platform.hana;

mixin(ShowModule!());

@safe:
interface AlertRepository : ITenantRepository!(Alert, AlertId){

  size_t countByInstance(TenantId tenantId, InstanceId instanceId);
  Alert[] findByInstance(TenantId tenantId, InstanceId instanceId);
  void removeByInstance(TenantId tenantId, InstanceId instanceId);

  size_t countActive(TenantId tenantId);
  Alert[] findActive(TenantId tenantId);
  void removeActive(TenantId tenantId);

}
