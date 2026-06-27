/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.ports.repositories.environment_instances;
// import uim.platform.management.domain.entities.environment_instance;

import uim.platform.management;

// mixin(ShowModule!());

@safe:
/// Port: outgoing — environment instance persistence.
interface EnvironmentRepository : ITenantRepository!(Environment, EnvironmentId) {

  Environment[] findBySubaccount(TenantId tenantId, SubaccountId subaccountId);
  Environment[] findByType(TenantId tenantId, SubaccountId subaccountId, EnvironmentType envType);
  Environment[] findByStatus(TenantId tenantId, SubaccountId subaccountId, EnvironmentStatus status);

}
