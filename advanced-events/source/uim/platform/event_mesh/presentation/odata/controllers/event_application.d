/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.presentation.odata.controllers.event_application;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class ODataEventApplicationController : EventApplicationController {
    this(ManageEventApplicationsUseCase usecase) {
        super(usecase);
    }

    override void registerRoutes(URLRouter router) {
        router.get("/odata/v4/event-mesh/EventApplications", &handleList);
        router.get("/odata/v4/event-mesh/EventApplications/*", &handleGet);
        router.post("/odata/v4/event-mesh/EventApplications", &handleCreate);
        router.put("/odata/v4/event-mesh/EventApplications/*", &handleUpdate);
        router.delete_("/odata/v4/event-mesh/EventApplications/*", &handleDelete);
    }
}
