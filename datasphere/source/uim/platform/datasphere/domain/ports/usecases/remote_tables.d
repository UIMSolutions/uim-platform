/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.ports.usecases.remote_tables;

// import uim.platform.datasphere.domain.entities.remote_table;
// import uim.platform.datasphere.domain.ports.repositories.remote_tables;
// import uim.platform.datasphere.application.dto;

import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
interface IManageRemoteTablesUseCase { 

  UsecaseResult createRemoteTable(CreateRemoteTableRequest r);
  RemoteTable getRemoteTable(TenantId tenantId, SpaceId spaceId, RemoteTableId id);
  RemoteTable[] listRemoteTables(TenantId tenantId, SpaceId spaceId);
  UsecaseResult deleteRemoteTable(TenantId tenantId, SpaceId spaceId, RemoteTableId id);

}
