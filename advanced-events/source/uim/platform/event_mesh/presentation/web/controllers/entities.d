/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.presentation.web.controllers.entities;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class WebBrokerServiceController {
    private WebBrokerServiceModel model;
    private WebBrokerServiceView view;

    this(WebBrokerServiceModel model, WebBrokerServiceView view) {
        this.model = model;
        this.view = view;
    }

    void registerRoutes(URLRouter router) {
        router.get("/web/event-mesh/broker-services", &handleIndex);
        router.get("/web/event-mesh/broker-services/*", &handleGet);
        router.post("/web/event-mesh/broker-services", &handleCreate);
        router.put("/web/event-mesh/broker-services/*", &handleUpdate);
        router.delete_("/web/event-mesh/broker-services/*", &handleDelete);
    }

    void handleIndex(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        writeHtml(res, view.renderIndex(model.list(tenantFromRequest(req))));
    }

    void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        writeHtml(res, view.renderDetails(model.get(tenantFromRequest(req), extractId(req))));
    }

    void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        writeHtml(res, view.renderMutation(model.create(tenantFromRequest(req), bodyFromRequest(req))));
    }

    void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        writeHtml(        res,
            view.renderMutation(            model.update(tenantFromRequest(req), extractId(req), bodyFromRequest(req))));
    }

    void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        writeHtml(res, view.renderMutation(model.remove(tenantFromRequest(req), extractId(req))));
    }
}

class WebQueueController {
    protected WebQueueModel model;
    protected WebQueueView view;

    this(WebQueueModel model, WebQueueView view) {
        this.model = model;
        this.view = view;
    }

    void registerRoutes(URLRouter router) {
        router.get("/web/event-mesh/queues", &handleIndex);
        router.get("/web/event-mesh/queues/*", &handleGet);
        router.post("/web/event-mesh/queues", &handleCreate);
        router.put("/web/event-mesh/queues/*", &handleUpdate);
        router.delete_("/web/event-mesh/queues/*", &handleDelete);
    }

    void handleIndex(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        writeHtml(res, view.renderIndex(model.list(tenantFromRequest(req))));
    }

    void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        writeHtml(res, view.renderDetails(model.get(tenantFromRequest(req), extractId(req))));
    }

    void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        writeHtml(res, view.renderMutation(model.create(tenantFromRequest(req), bodyFromRequest(req))));
    }

    void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        writeHtml(        res,
            view.renderMutation(            model.update(tenantFromRequest(req), extractId(req), bodyFromRequest(req))));
    }

    void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        writeHtml(res, view.renderMutation(model.remove(tenantFromRequest(req), extractId(req))));
    }
}

class WebEventMessageController {
    private WebEventMessageModel model;
    private WebEventMessageView view;

    this(WebEventMessageModel model, WebEventMessageView view) {
        this.model = model;
        this.view = view;
    }

    void registerRoutes(URLRouter router) {
        router.get("/web/event-mesh/messages", &handleIndex);
        router.get("/web/event-mesh/messages/*", &handleGet);
        router.post("/web/event-mesh/messages", &handleCreate);
        router.put("/web/event-mesh/messages/*", &handleUpdate);
        router.delete_("/web/event-mesh/messages/*", &handleDelete);
    }

    void handleIndex(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        writeHtml(res, view.renderIndex(model.list(tenantFromRequest(req))));
    }

    void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        writeHtml(res, view.renderDetails(model.get(tenantFromRequest(req), extractId(req))));
    }

    void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        writeHtml(res, view.renderMutation(model.create(tenantFromRequest(req), bodyFromRequest(req))));
    }

    void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        writeHtml(        res,
            view.renderMutation(            model.update(tenantFromRequest(req), extractId(req), bodyFromRequest(req))));
    }

    void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        writeHtml(res, view.renderMutation(model.remove(tenantFromRequest(req), extractId(req))));
    }
}

class WebEventSchemaController {
    private WebEventSchemaModel model;
    private WebEventSchemaView view;

    this(WebEventSchemaModel model, WebEventSchemaView view) {
        this.model = model;
        this.view = view;
    }

    void registerRoutes(URLRouter router) {
        router.get("/web/event-mesh/schemas", &handleIndex);
        router.get("/web/event-mesh/schemas/*", &handleGet);
        router.post("/web/event-mesh/schemas", &handleCreate);
        router.put("/web/event-mesh/schemas/*", &handleUpdate);
        router.delete_("/web/event-mesh/schemas/*", &handleDelete);
    }

    void handleIndex(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        writeHtml(res, view.renderIndex(model.list(tenantFromRequest(req))));
    }

    void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        writeHtml(res, view.renderDetails(model.get(tenantFromRequest(req), extractId(req))));
    }

    void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        writeHtml(res, view.renderMutation(model.create(tenantFromRequest(req), bodyFromRequest(req))));
    }

    void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        writeHtml(        res,
            view.renderMutation(            model.update(tenantFromRequest(req), extractId(req), bodyFromRequest(req))));
    }

    void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        writeHtml(res, view.renderMutation(model.remove(tenantFromRequest(req), extractId(req))));
    }
}

class WebEventApplicationController {
    private WebEventApplicationModel model;
    private WebEventApplicationView view;

    this(WebEventApplicationModel model, WebEventApplicationView view) {
        this.model = model;
        this.view = view;
    }

    void registerRoutes(URLRouter router) {
        router.get("/web/event-mesh/applications", &handleIndex);
        router.get("/web/event-mesh/applications/*", &handleGet);
        router.post("/web/event-mesh/applications", &handleCreate);
        router.put("/web/event-mesh/applications/*", &handleUpdate);
        router.delete_("/web/event-mesh/applications/*", &handleDelete);
    }

    void handleIndex(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        writeHtml(res, view.renderIndex(model.list(tenantFromRequest(req))));
    }

    void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        writeHtml(res, view.renderDetails(model.get(tenantFromRequest(req), extractId(req))));
    }

    void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        writeHtml(res, view.renderMutation(model.create(tenantFromRequest(req), bodyFromRequest(req))));
    }

    void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        writeHtml(        res,
            view.renderMutation(            model.update(tenantFromRequest(req), extractId(req), bodyFromRequest(req))));
    }

    void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        writeHtml(res, view.renderMutation(model.remove(tenantFromRequest(req), extractId(req))));
    }
}

class WebMeshBridgeController {
    private WebMeshBridgeModel model;
    private WebMeshBridgeView view;

    this(WebMeshBridgeModel model, WebMeshBridgeView view) {
        this.model = model;
        this.view = view;
    }

    void registerRoutes(URLRouter router) {
        router.get("/web/event-mesh/bridges", &handleIndex);
        router.get("/web/event-mesh/bridges/*", &handleGet);
        router.post("/web/event-mesh/bridges", &handleCreate);
        router.put("/web/event-mesh/bridges/*", &handleUpdate);
        router.delete_("/web/event-mesh/bridges/*", &handleDelete);
    }

    void handleIndex(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        writeHtml(res, view.renderIndex(model.list(tenantFromRequest(req))));
    }

    void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        writeHtml(res, view.renderDetails(model.get(tenantFromRequest(req), extractId(req))));
    }

    void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        writeHtml(res, view.renderMutation(model.create(tenantFromRequest(req), bodyFromRequest(req))));
    }

    void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        writeHtml(        res,
            view.renderMutation(            model.update(tenantFromRequest(req), extractId(req), bodyFromRequest(req))));
    }

    void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        writeHtml(res, view.renderMutation(model.remove(tenantFromRequest(req), extractId(req))));
    }
}
