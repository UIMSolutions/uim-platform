/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.presentation.web.controllers.topic;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

// class WebTopicController {
//     private WebTopicModel model;
//     private WebTopicView view;

//     this(WebTopicModel model, WebTopicView view) {
//         this.model = model;
//         this.view = view;
//     }

//     void registerRoutes(URLRouter router) {
//         super.registerRoutes(router);

//         router.get("/web/event-mesh/topics", &handleIndex);
//         router.get("/web/event-mesh/topics/*", &handleGet);
//         router.post("/web/event-mesh/topics", &handleCreate);
//         router.put("/web/event-mesh/topics/*", &handleUpdate);
//         router.delete_("/web/event-mesh/topics/*", &handleDelete);
//     }

//     void handleIndex(scope HTTPServerRequest req, scope HTTPServerResponse res) {
//         writeHtml(res, view.renderIndex(model.list(tenantFromRequest(req))));
//     }

//     void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
//         writeHtml(res, view.renderDetails(model.get(tenantFromRequest(req), extractId(req))));
//     }

//     void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
//         writeHtml(res, view.renderMutation(model.create(tenantFromRequest(req), bodyFromRequest(req))));
//     }

//     void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
//         writeHtml(        res,
//             view.renderMutation(            model.update(tenantFromRequest(req), extractId(req), bodyFromRequest(req))));
//     }

//     void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
//         writeHtml(res, view.renderMutation(model.remove(tenantFromRequest(req), extractId(req))));
//     }
// }
