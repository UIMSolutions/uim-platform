module uim.platform.xyz.presentation.http.fragment;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import uim.platform.xyz.application.usecases.manage_fragments;
import uim.platform.xyz.application.dto;
import uim.platform.xyz.domain.entities.destination_fragment;
import uim.platform.xyz.domain.types;
import uim.platform.xyz.presentation.http.json_utils;

class FragmentController
{
    private ManageFragmentsUseCase uc;

    this(ManageFragmentsUseCase uc)
    {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/fragments", &handleCreate);
        router.get("/api/v1/fragments", &handleList);
        router.get("/api/v1/fragments/*", &handleGetById);
        router.put("/api/v1/fragments/*", &handleUpdate);
        router.delete_("/api/v1/fragments/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            CreateFragmentRequest r;
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.subaccountId = req.headers.get("X-Subaccount-Id", "");
            r.name = j.getString("name");
            r.description = j.getString("description");
            r.level = j.getString("level");
            r.url = j.getString("url");
            r.authenticationType = j.getString("authentication");
            r.proxyType = j.getString("proxyType");
            r.user = j.getString("user");
            r.password = j.getString("password");
            r.clientId = j.getString("clientId");
            r.clientSecret = j.getString("clientSecret");
            r.tokenServiceUrl = j.getString("tokenServiceURL");
            r.locationId = j.getString("locationId");
            r.keystoreId = j.getString("keystoreId");
            r.truststoreId = j.getString("truststoreId");
            r.properties = jsonStrMap(j, "properties");
            r.createdBy = req.headers.get("X-User-Id", "");

            auto result = uc.create(r);
            if (result.success)
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
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto subaccountId = req.headers.get("X-Subaccount-Id", "");
            auto fragments = uc.listBySubaccount(tenantId, subaccountId);

            auto arr = Json.emptyArray;
            foreach (ref f; fragments)
                arr ~= serializeFragment(f);

            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long) fragments.length);
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
            auto f = uc.getFragment(id);
            if (f.id.length == 0)
            {
                writeError(res, 404, "Fragment not found");
                return;
            }
            res.writeJsonBody(serializeFragment(f), 200);
        }
        catch (Exception e)
        {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto j = req.json;
            UpdateFragmentRequest r;
            r.description = j.getString("description");
            r.url = j.getString("url");
            r.authenticationType = j.getString("authentication");
            r.proxyType = j.getString("proxyType");
            r.user = j.getString("user");
            r.password = j.getString("password");
            r.clientId = j.getString("clientId");
            r.clientSecret = j.getString("clientSecret");
            r.tokenServiceUrl = j.getString("tokenServiceURL");
            r.locationId = j.getString("locationId");
            r.keystoreId = j.getString("keystoreId");
            r.truststoreId = j.getString("truststoreId");
            r.properties = jsonStrMap(j, "properties");

            auto result = uc.updateFragment(id, r);
            if (result.success)
            {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                res.writeJsonBody(resp, 200);
            }
            else
            {
                writeError(res, result.error == "Fragment not found" ? 404 : 400, result.error);
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
            auto result = uc.removeFragment(id);
            if (result.success)
            {
                auto resp = Json.emptyObject;
                resp["deleted"] = Json(true);
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

    private static Json serializeFragment(const ref DestinationFragment f)
    {
        auto j = Json.emptyObject;
        j["id"] = Json(f.id);
        j["tenantId"] = Json(f.tenantId);
        j["subaccountId"] = Json(f.subaccountId);
        j["name"] = Json(f.name);
        j["description"] = Json(f.description);
        j["level"] = Json(f.level.to!string);
        j["url"] = Json(f.url);
        j["authentication"] = Json(f.authenticationType);
        j["proxyType"] = Json(f.proxyType);
        j["locationId"] = Json(f.locationId);
        j["properties"] = toJsonObject(f.properties);
        j["createdBy"] = Json(f.createdBy);
        j["createdAt"] = Json(f.createdAt);
        j["modifiedAt"] = Json(f.modifiedAt);
        return j;
    }
}
