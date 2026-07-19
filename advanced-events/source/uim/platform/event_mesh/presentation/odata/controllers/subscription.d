/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.presentation.odata.controllers.subscription;

import uim.platform.event_mesh;
mixin(ShowModule!());

@safe:

class ODataSubscriptionController : SubscriptionController {
    this(ManageSubscriptionsUseCase usecase) {
        super(usecase);
    }

    override void registerRoutes(URLRouter router) {
        router.get("/odata/v4/event-mesh/Subscriptions", &handleList);
        router.get("/odata/v4/event-mesh/Subscriptions/*", &handleGet);
        router.post("/odata/v4/event-mesh/Subscriptions", &handleCreate);
        router.put("/odata/v4/event-mesh/Subscriptions/*", &handleUpdate);
        router.delete_("/odata/v4/event-mesh/Subscriptions/*", &handleDelete);
    }
}
