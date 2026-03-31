module presentation.http.software_component_controller;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import application.use_cases.manage_software_components;
import application.dto;
import domain.entities.software_component;
import domain.types;
import presentation.http.json_utils;

class SoftwareComponentController
{
    private ManageSoftwareComponentsUseCase uc;

    this(ManageSoftwareComponentsUseCase uc)
    {
        this.uc = uc;
    }

    void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/software-components", &handleCreate);
        router.get("/api/v1/software-components", &handleList);
        router.get("/api/v1/software-components/*", &handleGetById);
        router.post("/api/v1/software-components/clone/*", &handleClone);
        router.post("/api/v1/software-components/pull/*", &handlePull);
        router.delete_("/api/v1/software-components/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            CreateSoftwareComponentRequest r;
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.systemInstanceId = jsonStr(j, "systemInstanceId");
            r.name = jsonStr(j, "name");
            r.description = jsonStr(j, "description");
            r.componentType = jsonStr(j, "componentType");
            r.repositoryUrl = jsonStr(j, "repositoryUrl");
            r.branch = jsonStr(j, "branch");
            r.branchStrategy = jsonStr(j, "branchStrategy");
            r.namespace = jsonStr(j, "namespace");

            auto result = uc.createComponent(r);
            if (result.isSuccess())
            {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                res.writeJsonBody(resp, 201);
            }
            else
            {
                writeError(res, 400, result.error);
            }
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto systemId = jsonStr(req.json, "systemInstanceId");
            if (systemId.length == 0)
                systemId = req.headers.get("X-System-Id", "");
            auto components = uc.listComponents(systemId);
            auto arr = Json.emptyArray;
            foreach (ref comp; components)
                arr ~= serializeComponent(comp);
            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long) components.length);
            res.writeJsonBody(resp, 200);
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto comp = uc.getComponent(id);
            if (comp is null)
            {
                writeError(res, 404, "Software component not found");
                return;
            }
            res.writeJsonBody(serializeComponent(*comp), 200);
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleClone(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto j = req.json;
            CloneSoftwareComponentRequest r;
            r.branch = jsonStr(j, "branch");
            r.commitId = jsonStr(j, "commitId");

            auto result = uc.cloneComponent(id, r);
            if (result.isSuccess())
            {
                auto resp = Json.emptyObject;
                resp["status"] = Json("cloned");
                res.writeJsonBody(resp, 200);
            }
            else
            {
                writeError(res, 400, result.error);
            }
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handlePull(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto j = req.json;
            PullSoftwareComponentRequest r;
            r.commitId = jsonStr(j, "commitId");

            auto result = uc.pullComponent(id, r);
            if (result.isSuccess())
            {
                auto resp = Json.emptyObject;
                resp["status"] = Json("pulled");
                res.writeJsonBody(resp, 200);
            }
            else
            {
                writeError(res, 400, result.error);
            }
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto result = uc.deleteComponent(id);
            if (result.isSuccess())
            {
                auto resp = Json.emptyObject;
                resp["status"] = Json("deleted");
                res.writeJsonBody(resp, 200);
            }
            else
            {
                writeError(res, 404, result.error);
            }
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private static Json serializeComponent(ref const SoftwareComponent comp)
    {
        auto j = Json.emptyObject;
        j["id"] = Json(comp.id);
        j["tenantId"] = Json(comp.tenantId);
        j["systemInstanceId"] = Json(comp.systemInstanceId);
        j["name"] = Json(comp.name);
        j["description"] = Json(comp.description);
        j["componentType"] = Json(comp.componentType.to!string);
        j["status"] = Json(comp.status.to!string);
        j["repositoryUrl"] = Json(comp.repositoryUrl);
        j["branch"] = Json(comp.branch);
        j["branchStrategy"] = Json(comp.branchStrategy.to!string);
        j["currentCommitId"] = Json(comp.currentCommitId);
        j["namespace"] = Json(comp.namespace);
        j["clonedAt"] = Json(comp.clonedAt);
        j["lastPulledAt"] = Json(comp.lastPulledAt);
        j["createdAt"] = Json(comp.createdAt);
        j["updatedAt"] = Json(comp.updatedAt);

        if (comp.commitHistory.length > 0)
        {
            auto hist = Json.emptyArray;
            foreach (ref c; comp.commitHistory)
            {
                auto hj = Json.emptyObject;
                hj["commitId"] = Json(c.commitId);
                hj["message"] = Json(c.message);
                hj["author"] = Json(c.author);
                hj["timestamp"] = Json(c.timestamp);
                hist ~= hj;
            }
            j["commitHistory"] = hist;
        }

        return j;
    }
}
