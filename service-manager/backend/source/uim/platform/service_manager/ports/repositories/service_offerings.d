/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.ports.repositories.service_offerings;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

interface IServiceOfferingRepository : IEntityRepository!(ServiceOffering, ServiceOfferingId) {
  ServiceOffering[] findByBroker(TenantId tenantId, ServiceBrokerId brokerId);
  ServiceOffering findByName(TenantId tenantId, ServiceBrokerId brokerId, string name);
}
