/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.domain.ports.usecases.mesh_bridges;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

interface IManageMeshBridgesUseCase { 

    MeshBridge getBridge(TenantId tenantId,  MeshBridgeId bridgeId);
    MeshBridge[] listBridges(TenantId tenantId);
    MeshBridge[] listBridges(TenantId tenantId, BrokerServiceId serviceId);
    CommandResult createBridge(MeshBridgeDTO dto);
    CommandResult updateBridge(MeshBridgeDTO dto);
    CommandResult deleteBridge(TenantId tenantId, MeshBridgeId bridgeId);

}

