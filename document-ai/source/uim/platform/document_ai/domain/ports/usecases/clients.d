/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.domain.ports.usecases.clients;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:
interface IManageClientsUseCase { 
  
  UsecaseResult createClient(CreateClientRequest r);
  UsecaseResult patchClient(PatchClientRequest r);
  Client getClient(TenantId tenantId, ClientId id);
  Client[] listClients(TenantId tenantId);
  size_t countClients(TenantId tenantId);
  UsecaseResult deleteClient(TenantId tenantId, ClientId id);

}
