/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.usecases.client_resources;
// import uim.platform.mobile.domain.ports.repositories.client_resources;
// import uim.platform.mobile.domain.entities.client_resource;

// import uim.platform.mobile.application.dto;


import uim.platform.mobile;

// mixin(Showmodule!());

@safe:
interface IManageClientResourcesUseCase { 

    UsecaseResult createClientResource(CreateClientResourceRequest r);

    UsecaseResult updateClientResource(UpdateClientResourceRequest r);

    ClientResource getClientResource(TenantId tenantId, ClientResourceId id);

    ClientResource[] listClientResources(TenantId tenantId);

    ClientResource[] listClientResources(TenantId tenantId, MobileAppId appId);

    UsecaseResult deleteClientResource(TenantId tenantId, ClientResourceId id);

    size_t countClientResourcesByApp(TenantId tenantId, MobileAppId appId);

}
