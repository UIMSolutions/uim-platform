module presentation.http.legal_ground;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import application.usecases.manage_legal_grounds;
import application.dto;
import domain.types;
import domain.entities.legal_ground;
import uim.platform.xyz.presentation.http.json_utils;

class LegalGroundController
{
    private ManageLegalGroundsUseCase uc;

    this(ManageLegalGroundsUseCase uc) { this.uc = uc; }

    override void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/legal-grounds", &handleCreate);
        router.get("/api/v1/legal-grounds", &handleList);
        router.get("/api/v1/legal-grounds/*", &handleGetById);
        router.put("/api/v1/legal-grounds/*", &handleUpdate);
        router.delete_("/api/v1/legal-grounds/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            CreateLegalGroundRequest r;
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.dataSubjectId = j.getString("dataSubjectId");
            r.basis = parseLegalBasis(j.getString("basis"));
            r.purpose = parsePurpose(j.getString("purpose"));
            r.description = j.getString("description");
            r.legalReference = j.getString("legalReference");
            r.validFrom = jsonLong(j, "validFrom");
            r.validUntil = jsonLong(j, "validUntil");

            auto result = uc.createGround(r);
            if (result.isSuccess())
            {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                res.writeJsonBody(resp, 201);
            }
            else
                writeError(res, 400, result.error);
        }
        catch (Exception e)
            writeError(res, 500, "Internal server error");
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto basisParam = req.headers.get("X-Basis-Filter", "");
            auto purposeParam = req.headers.get("X-Purpose-Filter", "");
            auto subjectParam = req.headers.get("X-Subject-Filter", "");

            LegalGround[] items;
            if (basisParam.length > 0)
                items = uc.listByBasis(tenantId, parseLegalBasis(basisParam));
            else if (purposeParam.length > 0)
                items = uc.listByPurpose(tenantId, parsePurpose(purposeParam));
            else if (subjectParam.length > 0)
                items = uc.listByDataSubject(tenantId, subjectParam);
            else
                items = uc.listGrounds(tenantId);

            auto arr = Json.emptyArray;
            foreach (ref e; items)
                arr ~= serialize(e);

            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long) items.length);
            res.writeJsonBody(resp, 200);
        }
        catch (Exception e)
            writeError(res, 500, "Internal server error");
    }

    private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto entry = uc.getGround(id, tenantId);
            if (entry is null)
            {
                writeError(res, 404, "Legal ground not found");
                return;
            }
            res.writeJsonBody(serialize(*entry), 200);
        }
        catch (Exception e)
            writeError(res, 500, "Internal server error");
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            UpdateLegalGroundRequest r;
            r.id = extractIdFromPath(req.requestURI);
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.description = j.getString("description");
            r.legalReference = j.getString("legalReference");
            r.isActive = j.getBoolean("isActive", true);
            r.validUntil = jsonLong(j, "validUntil");

            auto result = uc.updateGround(r);
            if (result.isSuccess())
            {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                res.writeJsonBody(resp, 200);
            }
            else
                writeError(res, 400, result.error);
        }
        catch (Exception e)
            writeError(res, 500, "Internal server error");
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto id = extractIdFromPath(req.requestURI);
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            uc.deleteGround(id, tenantId);
            res.writeJsonBody(Json.emptyObject, 204);
        }
        catch (Exception e)
            writeError(res, 500, "Internal server error");
    }

    private static Json serialize(ref const LegalGround e)
    {
        auto j = Json.emptyObject;
        j["id"] = Json(e.id);
        j["tenantId"] = Json(e.tenantId);
        j["dataSubjectId"] = Json(e.dataSubjectId);
        j["basis"] = Json(e.basis.to!string);
        j["purpose"] = Json(e.purpose.to!string);
        j["description"] = Json(e.description);
        j["legalReference"] = Json(e.legalReference);
        j["isActive"] = Json(e.isActive);
        j["validFrom"] = Json(e.validFrom);
        j["validUntil"] = Json(e.validUntil);
        j["createdAt"] = Json(e.createdAt);

        auto cats = Json.emptyArray;
        foreach (ref c; e.categories)
            cats ~= Json(c.to!string);
        j["categories"] = cats;

        return j;
    }

    private static LegalBasis parseLegalBasis(string s)
    {
        switch (s)
        {
            case "consent": return LegalBasis.consent;
            case "contract": return LegalBasis.contract;
            case "legalObligation": return LegalBasis.legalObligation;
            case "vitalInterest": return LegalBasis.vitalInterest;
            case "publicTask": return LegalBasis.publicTask;
            case "legitimateInterest": return LegalBasis.legitimateInterest;
            default: return LegalBasis.consent;
        }
    }

    private static ProcessingPurpose parsePurpose(string s)
    {
        switch (s)
        {
            case "serviceDelivery": return ProcessingPurpose.serviceDelivery;
            case "marketing": return ProcessingPurpose.marketing;
            case "analytics": return ProcessingPurpose.analytics;
            case "compliance": return ProcessingPurpose.compliance;
            case "humanResources": return ProcessingPurpose.humanResources;
            case "customerSupport": return ProcessingPurpose.customerSupport;
            case "billing": return ProcessingPurpose.billing;
            case "security": return ProcessingPurpose.security;
            case "research": return ProcessingPurpose.research;
            default: return ProcessingPurpose.serviceDelivery;
        }
    }
}
