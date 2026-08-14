/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.feature_flags.domain.ports.repositories.service_instances;

import uim.platform.feature_flags;

mixin(ShowModule!());

@safe:

/// Port for service instance persistence.
interface IServiceInstanceRepository : ITenantRepository!(ServiceInstanceId, ServiceInstance) {

    ServiceInstance findByName(TenantId tenantId, string name);

}
