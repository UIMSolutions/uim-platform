/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.domain.ports.usecases.carriers;
import uim.platform.logistic_management;

mixin(ShowModule!());

@safe:
interface IManageCarriersUseCase {

  CommandResult createCarrier(TenantId tenantId, CreateCarrierRequest req);

  CommandResult updateCarrier(TenantId tenantId, CarrierId id, UpdateCarrierRequest req);
  
  CommandResult deleteCarrier(TenantId tenantId, CarrierId id);

  Carrier getCarrier(TenantId tenantId, CarrierId id);

  Carrier[] listCarriers(TenantId tenantId);

  Carrier[] listByStatus(TenantId tenantId, CarrierStatus status);

}
