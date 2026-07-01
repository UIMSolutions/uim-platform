/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.presentation.odata.controllers.mesh_bridge;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class ODataMeshBridgeController : MeshBridgeController {
    this(ManageMeshBridgesUseCase usecase) {
        super(usecase);
    }

    override void registerRoutes(URLRouter router) {
        router.get("/odata/v4/event-mesh/MeshBridges", &handleList);
        router.get("/odata/v4/event-mesh/MeshBridges/*", &handleGet);
        router.post("/odata/v4/event-mesh/MeshBridges", &handleCreate);
        router.put("/odata/v4/event-mesh/MeshBridges/*", &handleUpdate);
        router.delete_("/odata/v4/event-mesh/MeshBridges/*", &handleDelete);
    }
}
