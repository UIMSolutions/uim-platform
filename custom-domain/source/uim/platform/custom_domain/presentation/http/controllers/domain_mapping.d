/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.custom_domain.presentation.http.controllers.domain_mapping;

import uim.platform.custom_domain;

mixin(ShowModule!());

@safe:

class DomainMappingController : ManageController {
    private ManageDomainMappingsUseCase usecase;

    this(ManageDomainMappingsUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/custom-domain/mappings", &handleList);
        router.get("/api/v1/custom-domain/mappings/*", &handleGet);
        router.post("/api/v1/custom-domain/mappings", &handleCreate);
        router.delete_("/api/v1/custom-domain/mappings/*", &handleDelete); // Corrected route to point to handleDelete
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = getTenantId(precheck);
        auto mappings = usecase.listDomainMappings(tenantId);
        auto jarr = Json.emptyArray;
        foreach (m; mappings) {
            jarr ~= Json.emptyObject
                .set("id", m.id)
                .set("customDomainId", m.customDomainId)
                .set("standardRoute", m.standardRoute)
                .set("customRoute", m.customRoute)
                .set("mappingType", m.mappingType.to!string)
                .set("status", m.status.to!string)
                .set("applicationName", m.applicationName)
                .set("createdBy", m.createdBy)
                .set("createdAt", m.createdAt);
        }

        return successResponse("Domain mappings retrieved successfully", 200,
            Json.emptyObject.set("count", mappings.length).set("mappings", jarr));
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = getTenantId(precheck);
        auto data = precheck["data"];

        CreateDomainMappingRequest r;
        r.tenantId = tenantId;
        r.domainMappingId = DomainMappingId(data.getString("id"));
        r.customDomainId = CustomDomainId(data.getString("customDomainId"));
        r.standardRoute = data.getString("standardRoute");
        r.customRoute = data.getString("customRoute");
        r.mappingType = data.getString("mappingType");
        r.applicationName = data.getString("applicationName");
        r.organizationId = data.getString("organizationId");
        r.spaceId = data.getString("spaceId");
        r.createdBy = UserId(data.getString("createdBy"));

        auto result = usecase.createDomainMapping(r);
        if (result.hasError)
            return errorResponse(result.errorMessage, 400);

        return successResponse("Domain mapping created successfully", 201,
            Json.emptyObject.set("id", result.id));
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req); // Assuming ManageController.getHandler for pre-checks
        if (precheck.hasError)
            return precheck;

        auto tenantId = getTenantId(precheck);
        auto id = DomainMappingId(extractIdFromPath(req.requestURI.to!string));
        if (id.isNull)
            return errorResponse("Invalid Domain Mapping ID", 400);

        auto m = usecase.getDomainMapping(tenantId, id);
        if (m.isNull)
            return errorResponse("Domain mapping not found", 404);

        auto result = m.entityToJson()
            .set("entity", "DomainMapping")
            .set("id", m.id)
            .set("customDomainId", m.customDomainId)
            .set("standardRoute", m.standardRoute)
            .set("customRoute", m.customRoute)
            .set("mappingType", m.mappingType.to!string)
            .set("status", m.status.to!string)
            .set("applicationName", m.applicationName)
            .set("organizationId", m.organizationId)
            .set("spaceId", m.spaceId)
            .set("createdBy", m.createdBy)
            .set("createdAt", m.createdAt)
            .set("updatedAt", m.updatedAt);

        return successResponse("Domain mapping retrieved successfully", 200, result);
    }

    // No update route defined in registerRoutes, so no updateHandler is needed.
    // If a PUT route is added, an updateHandler would be implemented here.
    // override protected Json updateHandler(HTTPServerRequest req) {
    //     auto precheck = super.updateHandler(req);
    //     if (precheck.hasError)
    //         return precheck;
    //     // ... update logic ...
    //     return successResponse("Domain mapping updated successfully", 200, Json.emptyObject.set("id", result.id));
    // }

    // This was previously named updateHandler but performed a delete operation.
    // Renamed to deleteHandler to match its functionality and the route.
    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req); // Assuming ManageController.deleteHandler for pre-checks
        if (precheck.hasError) return precheck;
        auto tenantId = getTenantId(precheck);
        auto id = DomainMappingId(extractIdFromPath(req.requestURI.to!string));
        auto result = usecase.deleteDomainMapping(tenantId, id);
        if (result.hasError) return errorResponse(result.errorMessage, 404);
        return successResponse("Domain mapping deleted successfully", 200, Json.emptyObject.set("id", result.id));
    }
}
