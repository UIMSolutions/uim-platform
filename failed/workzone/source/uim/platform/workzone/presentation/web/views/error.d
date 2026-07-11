/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.web.views.error;

import uim.platform.workzone.presentation.web.views.layout;
import std.conv : to;

@safe:
/// Render an HTTP error page.
string renderError(int statusCode, string message, string detail = "") {
    
    auto body_ = `
<div class="d-flex justify-content-center align-items-center" style="min-height:60vh">
  <div class="text-center">
    <h1 class="display-1 text-muted">` ~ statusCode.to!string ~ `</h1>
    <h4 class="mb-3">` ~ escapeHtml(message) ~ `</h4>`;
    if (detail.length > 0) {
        body_ ~= `<p class="text-muted">` ~ escapeHtml(detail) ~ `</p>`;
    }
    body_ ~= `
    <a href="/ui/workspaces" class="btn btn-primary mt-3">Back to WorkZone</a>
  </div>
</div>`;
    return renderLayout(statusCode.to!string ~ " — " ~ message, body_);
}

/// Render a 404 Not Found page.
string renderNotFound(string resourceType, string id) {
    return renderError(404, "Not Found",
        resourceType ~ " '" ~ id ~ "' could not be found.");
}
