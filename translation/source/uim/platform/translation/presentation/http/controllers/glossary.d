/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.presentation.http.controllers.glossary;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// CRUD /api/v1/translation/glossaries — manage company MLTR (custom translation memory).
class GlossaryController : ManageController {
    private ManageGlossaryEntriesUseCase usecase;

    this(ManageGlossaryEntriesUseCase usecase) {
        this.usecase = usecase;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);

        router.get("/api/v1/translation/glossaries", &handleList);
        router.get("/api/v1/translation/glossaries/*", &handleGet);
        router.post("/api/v1/translation/glossaries", &handleCreate);
        router.put("/api/v1/translation/glossaries/*", &handleUpdate);
        router.delete_("/api/v1/translation/glossaries/*", &handleDelete);
    }

    override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError) {
            return precheck;
        }

        auto tenantId = precheck.tenantId;
        auto data = precheck.data;

        CreateGlossaryEntryRequest r;
        r.tenantId = tenantId;
        r.sourceLanguage = data.getString("sourceLanguage");
        r.targetLanguage = data.getString("targetLanguage");
        r.sourceTerm = data.getString("sourceTerm");
        r.targetTerm = data.getString("targetTerm");
        r.domainName = data.getString("domain");
        r.context = data.getString("context");
        r.mandatory = data.getBoolean("mandatory", false);

        auto result = usecase.createEntry(r);
        if (result.hasError) {
            return Json.emptyObject
                .set("status", "error")
                .set("message", result.message)
                .set("statusCode", 400);
        }

        return Json.emptyObject
            .set("status", "success")
            .set("id", result.id)
            .set("message", "Glossary entry created")
            .set("statusCode", 201);
    }

    override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError) {
            return precheck;
        }

        auto tenantId = precheck.tenantId;

        auto entries = usecase.listEntries(tenantId);
        auto arr = entries.map!(e => e.toJson)
            .array
            .to!Json;

        return Json.emptyObject
            .set("count", entries.length)
            .set("entries", arr)
            .set("statusCode", 200);
    }

    override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError) {
            return precheck;
        }

        auto tenantId = precheck.tenantId;
        auto id = GlossaryEntryprecheck.id);

        auto entry = usecase.getEntry(tenantId, id);
        if (entry.isNull) {
            return Json.emptyObject
                .set("status", "error")
                .set("message", "Glossary entry not found")
                .set("statusCode", 404);
        }
        return Json.emptyObject
            .set("status", "success")
            .set("id", entry.id)
            .set("message", "Glossary entry retrieved")
            .set("statusCode", 200);
    }

    override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError) {
            return precheck;
        }

        auto tenantId = precheck.tenantId;
        auto entryId = GlossaryEntryprecheck.id);
        auto data = precheck.data;

        UpdateGlossaryEntryRequest r;
        r.tenantId = tenantId;
        r.entryId = entryId;
        r.targetTerm = data.getString("targetTerm");
        r.domainName = data.getString("domain");
        r.context = data.getString("context");
        r.mandatory = data.getBoolean("mandatory", false);

        auto result = usecase.updateEntry(r);
        if (result.hasError) {
            return Json.emptyObject
                .set("status", "error")
                .set("message", result.message)
                .set("statusCode", 400);
        }

        return Json.emptyObject
            .set("status", "success")
            .set("id", result.id)
            .set("message", "Glossary entry updated")
            .set("statusCode", 200);
    }

    override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError) {
            return precheck;
        }

        auto tenantId = TenantId(req.getTenantId);
        auto entryId = GlossaryEntryprecheck.id);
        if (entryId.isNull) {
            return Json.emptyObject
                .set("status", "error")
                .set("message", "Invalid glossary entry ID")
                .set("statusCode", 400);
        }

        auto result = usecase.deleteEntry(tenantId, entryId);
        if (result.hasError) {
            return Json.emptyObject
                .set("status", "error")
                .set("message", result.message)
                .set("statusCode", 400);
        }

        return Json.emptyObject
            .set("status", "error")
            .set("message", result.message)
            .set("statusCode", 404);
    }
}
