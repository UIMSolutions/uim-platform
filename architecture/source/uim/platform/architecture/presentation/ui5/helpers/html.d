module uim.platform.architecture.presentation.ui5.helpers.html;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

void writeHtml(scope HTTPServerResponse res, string html) {
    res.writeBody(html, cast(int)HTTPStatus.ok, "text/html; charset=utf-8");
}

void writeJson(scope HTTPServerResponse res, int status, UsecaseResult result) {
    auto payload = Json.emptyObject;
    payload["success"] = Json(result.success);
    payload["id"] = Json(result.id);
    payload["message"] = Json(result.message);
    payload["code"] = Json(result.code);
    res.writeBody(payload.toString(), status, "application/json; charset=utf-8");
}

void writeJsonError(scope HTTPServerResponse res, int status, string message) {
    auto payload = Json.emptyObject;
    payload["success"] = Json(false);
    payload["id"] = Json("");
    payload["message"] = Json(message);
    payload["code"] = Json(cast(uint)status);
    res.writeBody(payload.toString(), status, "application/json; charset=utf-8");
}

string pageStart(string title) {
    return "<!doctype html><html><head><meta charset='utf-8'><meta name='viewport' content='width=device-width,initial-scale=1'>"
        ~ "<title>" ~ escapeHtml(title) ~ "</title>"
        ~ "<script id='sap-ui-bootstrap' src='https://sdk.openui5.org/resources/sap-ui-core.js' data-sap-ui-theme='sap_horizon' data-sap-ui-libs='sap.m,sap.ui.layout' data-sap-ui-compatVersion='edge' data-sap-ui-async='true'></script>"
        ~ "</head><body class='sapUiBody'><div id='content'></div>";
}

string navItem(string title, string href) {
    return "list.addItem(new sap.m.StandardListItem({title:'" ~ escapeJs(title) ~ "',type:'Navigation',press:function(){window.location='" ~ escapeJs(
        href) ~ "';}}));";
}

string field(string label, string propertyName) {
    return "new sap.m.Label({text:'" ~ escapeJs(
        label) ~ "'}),new sap.m.Text({text:'{" ~ escapeJs(propertyName) ~ "}'})";
}

string escapeHtml(string value) {
    return value
        .replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace("\"", "&quot;")
        .replace("'", "&#39;");
}

string escapeJs(string value) {
    return value
        .replace("\\", "\\\\")
        .replace("'", "\\'")
        .replace("\n", "\\n")
        .replace("\r", "\\r")
        .replace("</", "<\\/");
}
