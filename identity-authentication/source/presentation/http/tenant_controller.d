module presentation.http.tenant_controller;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import uim.platform.identity_authentication.application.use_cases.manage_tenants;
import uim.platform.identity_authentication.application.dto;
import uim.platform.identity_authentication.domain.entities.tenant;
import uim.platform.identity_authentication.domain.types;
import presentation.http.json_utils;

/// HTTP controller for tenant management.
class TenantController
{
    private ManageTenantsUseCase useCase;

    this(ManageTenantsUseCase useCase)
    {
        this.useCase = useCase;
    }

    void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/tenants", &handleCreate);
        router.get("/api/v1/tenants", &handleList);
        router.get("/api/v1/tenants/*", &handleGet);
        router.put("/api/v1/tenants/*", &handleUpdate);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto createReq = CreateTenantRequest(
                jsonStr(j, "name"),
                jsonStr(j, "subdomain"),
                SsoProtocol.oidc,
                [AuthMethod.form],
                false
            );

            auto result = useCase.createTenant(createReq);
            auto response = Json.emptyObject;

            if (result.isSuccess())
            {
                response["tenantId"] = Json(result.tenantId);
                res.writeJsonBody(response, 201);
            }
            else
            {
                response["error"] = Json(result.error);
                res.writeJsonBody(response, 409);
            }
        }
        catch (Exception e)
        {
            auto errRes = Json.emptyObject;
            errRes["error"] = Json("Internal server error");
            res.writeJsonBody(errRes, 500);
        }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto tenants = useCase.listTenants();
            auto response = Json.emptyObject;
            response["totalResults"] = Json(cast(long) tenants.length);
            response["resources"] = toJsonArray(tenants);
            res.writeJsonBody(response, 200);
        }
        catch (Exception e)
        {
            auto errRes = Json.emptyObject;
            errRes["error"] = Json("Internal server error");
            res.writeJsonBody(errRes, 500);
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            import std.string : lastIndexOf;
            auto path = req.requestURI;
            auto idx = path.lastIndexOf('/');
            auto tenantId = idx >= 0 ? path[idx + 1 .. $] : "";

            auto tenant = useCase.getTenant(tenantId);
            if (tenant == Tenant.init)
            {
                auto errRes = Json.emptyObject;
                errRes["error"] = Json("Tenant not found");
                res.writeJsonBody(errRes, 404);
                return;
            }

            res.writeJsonBody(toJsonValue(tenant), 200);
        }
        catch (Exception e)
        {
            auto errRes = Json.emptyObject;
            errRes["error"] = Json("Internal server error");
            res.writeJsonBody(errRes, 500);
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            import std.string : lastIndexOf;
            auto path = req.requestURI;
            auto idx = path.lastIndexOf('/');
            auto tenantId = idx >= 0 ? path[idx + 1 .. $] : "";

            auto j = req.json;
            auto updateReq = UpdateTenantRequest(
                tenantId,
                jsonStr(j, "name"),
                []
            );

            auto error = useCase.updateTenant(updateReq);
            if (error.length > 0)
            {
                auto errRes = Json.emptyObject;
                errRes["error"] = Json(error);
                res.writeJsonBody(errRes, 404);
            }
            else
            {
                auto resp = Json.emptyObject;
                resp["status"] = Json("updated");
                res.writeJsonBody(resp, 200);
            }
        }
        catch (Exception e)
        {
            auto errRes = Json.emptyObject;
            errRes["error"] = Json("Internal server error");
            res.writeJsonBody(errRes, 500);
        }
    }
}
