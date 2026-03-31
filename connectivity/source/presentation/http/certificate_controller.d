module presentation.http.certificate;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import application.usecases.manage_certificates;
import application.dto;
import domain.entities.certificate;
import presentation.http.json_utils;

class CertificateController
{
    private ManageCertificatesUseCase uc;

    this(ManageCertificatesUseCase uc)
    {
        this.uc = uc;
    }

    void registerRoutes(URLRouter router)
    {
        router.post("/api/v1/certificates", &handleCreate);
        router.get("/api/v1/certificates", &handleList);
        router.get("/api/v1/certificates/*", &handleGetById);
        router.put("/api/v1/certificates/*", &handleUpdate);
        router.delete_("/api/v1/certificates/*", &handleDelete);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        try
        {
            auto j = req.json;
            auto r = CreateCertificateRequest();
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.name = jsonStr(j, "name");
            r.description = jsonStr(j, "description");
            r.certType = jsonStr(j, "type");
            r.usage = jsonStr(j, "usage");
            r.subjectDN = jsonStr(j, "subjectDN");
            r.issuerDN = jsonStr(j, "issuerDN");
            r.serialNumber = jsonStr(j, "serialNumber");
            r.fingerprint = jsonStr(j, "fingerprint");
            r.validFrom = jsonLong(j, "validFrom");
            r.validTo = jsonLong(j, "validTo");

            auto result = uc.createCertificate(r);
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
            auto certs = uc.listCertificates(tenantId);

            auto arr = Json.emptyArray;
            foreach (ref c; certs)
                arr ~= serializeCert(c);

            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long) certs.length);
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
            auto cert = uc.getCertificate(id);
            if (cert.id.length == 0)
            {
                writeError(res, 404, "Certificate not found");
                return;
            }
            res.writeJsonBody(serializeCert(cert), 200);
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
            auto r = UpdateCertificateRequest();
            r.description = jsonStr(j, "description");
            r.active = jsonBool(j, "active", true);

            auto result = uc.updateCertificate(id, r);
            if (result.success)
            {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                res.writeJsonBody(resp, 200);
            }
            else
            {
                writeError(res, result.error == "Certificate not found" ? 404 : 400, result.error);
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
            auto result = uc.deleteCertificate(id);
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

    private static Json serializeCert(ref const Certificate c)
    {
        auto j = Json.emptyObject;
        j["id"] = Json(c.id);
        j["tenantId"] = Json(c.tenantId);
        j["name"] = Json(c.name);
        j["description"] = Json(c.description);
        j["type"] = Json(c.certType.to!string);
        j["usage"] = Json(c.usage.to!string);
        j["subjectDN"] = Json(c.subjectDN);
        j["issuerDN"] = Json(c.issuerDN);
        j["serialNumber"] = Json(c.serialNumber);
        j["fingerprint"] = Json(c.fingerprint);
        j["validFrom"] = Json(c.validFrom);
        j["validTo"] = Json(c.validTo);
        j["active"] = Json(c.active);
        j["createdAt"] = Json(c.createdAt);
        j["updatedAt"] = Json(c.updatedAt);
        return j;
    }
}
