module presentation.http.consent;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import application.usecases.manage_consent_records;
import application.dto;
import domain.types;
import domain.entities.consent_record;
import presentation.http.json_utils;

class ConsentController
{
    private ManageConsentRecordsUseCase uc;

    this(ManageConsentRecordsUseCase uc) { this.uc = uc; }

    override void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/consents", &handleGrant);
        router.get("/api/v1/consents", &handleList);
        router.get("/api/v1/consents/active", &handleListActive);
        router.get("/api/v1/consents/*", &handleGetById);
        router.post("/api/v1/consents/revoke", &handleRevoke);
        router.delete_("/api/v1/consents/*", &handleDelete);
    }

    private void handleGrant(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            CreateConsentRecordRequest r;
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.dataSubjectId = j.getString("dataSubjectId");
            r.purpose = parsePurpose(jsonStr(j, "purpose"));
            r.channel = j.getString("channel");
            r.consentText = j.getString("consentText");
            r.version_ = j.getString("version");
            r.ipAddress = j.getString("ipAddress");
            r.expiresAt = jsonLong(j, "expiresAt");

            auto result = uc.grantConsent(r);
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
            auto subjectParam = req.headers.get("X-Subject-Filter", "");
            auto purposeParam = req.headers.get("X-Purpose-Filter", "");

            ConsentRecord[] items;
            if (subjectParam.length > 0)
                items = uc.listByDataSubject(tenantId, subjectParam);
            else if (purposeParam.length > 0)
                items = uc.listByPurpose(tenantId, parsePurpose(purposeParam));
            else
                items = uc.listConsents(tenantId);

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

    private void handleListActive(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto subjectParam = req.headers.get("X-Subject-Filter", "");

            ConsentRecord[] items;
            if (subjectParam.length > 0)
                items = uc.listActiveConsents(tenantId, subjectParam);
            else
                items = uc.listConsents(tenantId);

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
            auto entry = uc.getConsent(id, tenantId);
            if (entry is null)
            {
                writeError(res, 404, "Consent record not found");
                return;
            }
            res.writeJsonBody(serialize(*entry), 200);
        }
        catch (Exception e)
            writeError(res, 500, "Internal server error");
    }

    private void handleRevoke(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            RevokeConsentRequest r;
            r.id = j.getString("id");
            r.tenantId = req.headers.get("X-Tenant-Id", "");

            auto result = uc.revokeConsent(r);
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
            uc.deleteConsent(id, tenantId);
            res.writeJsonBody(Json.emptyObject, 204);
        }
        catch (Exception e)
            writeError(res, 500, "Internal server error");
    }

    private static Json serialize(ref const ConsentRecord e)
    {
        auto j = Json.emptyObject;
        j["id"] = Json(e.id);
        j["tenantId"] = Json(e.tenantId);
        j["dataSubjectId"] = Json(e.dataSubjectId);
        j["purpose"] = Json(e.purpose.to!string);
        j["status"] = Json(e.status.to!string);
        j["channel"] = Json(e.channel);
        j["consentText"] = Json(e.consentText);
        j["version"] = Json(e.version_);
        j["ipAddress"] = Json(e.ipAddress);
        j["grantedAt"] = Json(e.grantedAt);
        j["revokedAt"] = Json(e.revokedAt);
        j["expiresAt"] = Json(e.expiresAt);
        j["createdAt"] = Json(e.createdAt);

        auto cats = Json.emptyArray;
        foreach (ref c; e.categories)
            cats ~= Json(c.to!string);
        j["categories"] = cats;

        return j;
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
