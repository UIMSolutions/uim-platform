/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.ports.usecases.manage_service_offerings;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

interface IManageServiceOfferings {
  ServiceOffering[] listOfferings(TenantId tenantId);
  ServiceOffering getOffering(TenantId tenantId, ServiceOfferingId id);
  ServiceOffering createOffering(CreateServiceOfferingRequest request);
  ServiceOffering updateOffering(UpdateServiceOfferingRequest request);
  /// Refused while the offering has plans.
  void deleteOffering(TenantId tenantId, ServiceOfferingId id);
}
