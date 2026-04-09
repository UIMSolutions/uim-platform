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
interface AlertRepository {
  Alert findById(AlertId id);
  Alert[] findByTenant(TenantId tenantId);
  Alert[] findByInstance(InstanceId instanceId);
  Alert[] findActive(TenantId tenantId);
  void save(Alert a);
  void update(Alert a);
  void remove(AlertId id);
  size_t countByTenant(TenantId tenantId);
}
