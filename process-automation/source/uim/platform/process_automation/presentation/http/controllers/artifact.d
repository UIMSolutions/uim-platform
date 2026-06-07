/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.presentation.http.controllers.artifact;
// import uim.platform.process_automation.application.usecases.manage.artifacts;
// import uim.platform.process_automation.application.dto;

import uim.platform.process_automation;

// mixin(ShowModule!());

@safe:

class ArtifactController : ManageHttpController {
    private ManageArtifactsUseCase artifactUsecase;

    this(ManageArtifactsUseCase artifactUsecase) {
        this.artifactUsecase = artifactUsecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/process-automation/store/artifacts", &handleList);
        router.get("/api/v1/process-automation/store/artifacts/*", &handleGet);
        router.post("/api/v1/process-automation/store/artifacts", &handleCreate);
        router.put("/api/v1/process-automation/store/artifacts/*", &handleUpdate);
        router.delete_("/api/v1/process-automation/store/artifacts/*", &handleDelete);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        CreateArtifactRequest r;
        r.tenantId = tenantId;
        r.artifactId = ArtifactId(precheck.id);
        r.name = data.getString("name");
        r.description = data.getString("description");
        r.type = data.getString("type");
        r.version_ = data.getString("version");
        r.author = data.getString("author");
        r.category = data.getString("category");
        r.tags = data.getStrings("tags");
        r.contentUrl = data.getString("contentUrl");

        auto result = artifactUsecase.createArtifact(r);
        if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
            .set("id", result.id);

        return successResponse("Artifact created successfully", "Created", 201, resp);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto artifacts = artifactUsecase.listArtifacts(tenantId);

        auto jarr = Json.emptyArray;
        foreach (a; artifacts) {
            jarr ~= Json.emptyObject
                .set("id", a.id)
                .set("name", a.name)
                .set("description", a.description)
                .set("type", a.type.to!string)
                .set("status", a.status.to!string)
                .set("version", a.version_)
                .set("author", a.author)
                .set("category", a.category)
                .set("downloadCount", a.downloadCount)
                .set("rating", a.rating);
        }

        auto resp = Json.emptyObject
            .set("count", artifacts.length)
            .set("resources", jarr);

        return successResponse("Artifacts retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto id = ArtifactId(precheck.id);
        auto a = artifactUsecase.getArtifact(tenantId, id);
        if (a.isNull)
            return errorResponse("Artifact not found", 404);

        auto resp = Json.emptyObject
            .set("id", a.id)
            .set("name", a.name)
            .set("description", a.description)
            .set("type", a.type.to!string)
            .set("status", a.status.to!string)
            .set("version", a.version_)
            .set("author", a.author)
            .set("category", a.category)
            .set("tags", a.tags.toJson)
            .set("contentUrl", a.contentUrl)
            .set("downloadCount", a.downloadCount)
            .set("rating", a.rating)
            .set("publishedAt", a.publishedAt)
            .set("updatedAt", a.updatedAt);

        return successResponse("Artifact retrieved successfully", "Retrieved", 200, resp);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        UpdateArtifactRequest r;
        r.tenantId = tenantId;
        r.artifactId = ArtifactId(precheck.id);
        r.name = data.getString("name");
        r.description = data.getString("description");
        r.version_ = data.getString("version");
        r.contentUrl = data.getString("contentUrl");

        auto result = artifactUsecase.updateArtifact(r);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Artifact updated successfully", "Updated", 200, responseData);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = ArtifactId(precheck.id);

        auto result = artifactUsecase.deleteArtifact(tenantId, id);
        if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Artifact deleted successfully", "Deleted", 200, responseData);
    }
}
