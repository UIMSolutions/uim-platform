/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.presentation.http.controllers.message_client;

import uim.platform.events;

mixin(ShowModule!());

@safe:

class MessageClientController : ManageHttpController {
    private ManageMessageClientsUseCase usecase;

    this(ManageMessageClientsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/sap-event-mesh/message-clients", &handleList);
        router.get("/api/v1/sap-event-mesh/message-clients/*", &handleGet);
        router.post("/api/v1/sap-event-mesh/message-clients", &handleCreate);
        router.put("/api/v1/sap-event-mesh/message-clients/*", &handleUpdate);
        router.delete_("/api/v1/sap-event-mesh/message-clients/*", &handleDelete);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto items = usecase.listClients(tenantId);
        return successResponse("Message clients retrieved successfully", "Retrieved", 200, Json.emptyObject
                .set("count", items.length)
                .set("resources", items.map!(e => e.toJson).array.toJson));

}

override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
        return precheck;

    auto tenantId = precheck.tenantId;
    auto id = precheck.id;
    auto e = usecase.getClient(tenantId, MessageClientId(id));
    if (e.isNull)
            return errorResponse("", 0);
            
    return successResponse("Message client retrieved successfully", "Retrieved", 200, Json.emptyObject
            .set("resource", e.toJson));
}

override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
        return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    MessageClientDTO dto;
    dto.clientId = MessageClientId(precheck.id);
    dto.tenantId = tenantId;
    dto.serviceId = MessagingServiceId(data.getString("serviceId"));
    dto.name = data.getString("name");
    dto.description = data.getString("description");
    dto.protocol = data.getString("protocol");
    dto.xsappname = data.getString("xsappname");
    dto.namespace = data.getString("namespace");
    dto.permittedNamespace = data.getString("permittedNamespace");
    dto.createdBy = UserId(data.getString("createdBy"));
    auto result = usecase.createClient(dto);
    if (result.hasError)
        return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Message client created successfully", "Created", 201, responseData);
}

override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
        return precheck;

    auto tenantId = precheck.tenantId;
    auto clientId = MessageClientId(precheck.id);
    auto data = precheck.data;
    MessageClientDTO dto;
    dto.tenantId = tenantId;
    dto.clientId = clientId;
    dto.name = data.getString("name");
    dto.description = data.getString("description");
    dto.namespace = data.getString("namespace");
    dto.permittedNamespace = data.getString("permittedNamespace");
    dto.updatedBy = UserId(data.getString("updatedBy"));
    auto result = usecase.updateClient(dto);
    if (result.hasError)
        return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Message client updated successfully", "Updated", 200, responseData);
}

override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
        return precheck;

    auto tenantId = precheck.tenantId;
    auto id = MessageClientId(precheck.id);
    auto result = usecase.deleteClient(tenantId, id);
    if (result.hasError)
        return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Message client deleted successfully", "Deleted", 200, responseData);
}
}
