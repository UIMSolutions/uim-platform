/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.feature_flags.presentation.web.views.feature_flag;

import uim.platform.feature_flags;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse, HTTPStatus;
import vibe.data.json   : Json;
import std.conv         : to;
import std.algorithm    : map;
import std.array        : array;

mixin(ShowModule!());

@safe:

/// MVC Web View controller — renders feature flag data as HTML for browser-based UIs.
/// In this implementation, responses are JSON with an "Accept: text/html" hint header;
/// a real UI would use vibe.d Diet templates (views/*.dt files).
class FeatureFlagWebView {
    private ManageFeatureFlagsUseCase useCase;

    this(ManageFeatureFlagsUseCase useCase) {
        this.useCase = useCase;
    }

    void registerRoutes(URLRouter router) {
        router.get("/web/feature-flags",      &renderList);
        router.get("/web/feature-flags/*",    &renderDetail);
    }

    // Renders a list view (JSON model for Diet template binding)
    private void renderList(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = req.query.get("tenantId", "default");
        auto flags    = useCase.listFlags(tenantId);

        auto model = Json.emptyObject;
        model["title"]    = "Feature Flags";
        model["tenantId"] = tenantId;
        auto items = Json.emptyArray;
        foreach (f; flags) items ~= toJson(f);
        model["flags"] = items;
        model["count"] = cast(long) flags.length;

        res.writeJsonBody(model, cast(int) HTTPStatus.ok);
    }

    // Renders a detail view model
    private void renderDetail(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = req.query.get("tenantId", "default");
        auto path     = req.requestPath.to!string;
        auto id       = FlagId(extractIdFromPath(path));
        if (id.isNull) { writeError(res, 400, "Invalid flag ID"); return; }

        auto flag_ = useCase.getFlag(tenantId, id);
        if (flag_.isNull) { writeError(res, 404, "Feature flag not found"); return; }

        auto model = Json.emptyObject;
        model["title"] = "Feature Flag - " ~ flag_.name;
        model["flag"]  = toJson(flag_);

        res.writeJsonBody(model, cast(int) HTTPStatus.ok);
    }
}
