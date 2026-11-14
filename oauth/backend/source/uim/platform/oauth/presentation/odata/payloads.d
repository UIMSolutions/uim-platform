/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Validated payload (see ODataEngine.validatePayload) → request DTOs.
module uim.platform.oauth.presentation.odata.payloads;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

TenantId tenantOf(const RequestContext ctx) {
  return TenantId(ctx.tenantId);
}

UserId actorOf(const RequestContext ctx) {
  return UserId(ctx.actor);
}

string textOf(Json p, string key) {
  return key in p && p[key].type == Json.Type.string ? p[key].get!string : "";
}

bool boolOf(Json p, string key, bool fallback = false) {
  return key in p && p[key].type == Json.Type.bool_ ? p[key].get!bool : fallback;
}

long longOf(Json p, string key, long fallback = 0) {
  if (key !in p)
    return fallback;
  auto v = p[key];
  if (v.type == Json.Type.int_)
    return v.get!long;
  if (v.type == Json.Type.string) {
    try
      return v.get!string.to!long;
    catch (Exception) {
    }
  }
  return fallback;
}

/// Array of strings (a single string is split at spaces and commas).
string[] textsOf(Json p, string key) @trusted {
  if (key !in p)
    return null;
  auto v = p[key];
  if (v.type == Json.Type.string)
    return parseScopeList(v.get!string);
  string[] values;
  if (v.type == Json.Type.array)
    foreach (item; v.get!(Json[]))
      if (item.type == Json.Type.string)
        values ~= item.get!string;
  return values;
}

/// Present (incl. null → "") or unset.
Patch!string textPatch(Json p, string key) {
  Patch!string r;
  if (key in p)
    r = textOf(p, key);
  return r;
}

Patch!bool boolPatch(Json p, string key) {
  Patch!bool r;
  if (key in p && p[key].type == Json.Type.bool_)
    r = p[key].get!bool;
  return r;
}

Patch!long longPatch(Json p, string key) {
  Patch!long r;
  if (key in p && p[key].type != Json.Type.null_)
    r = longOf(p, key);
  return r;
}

Patch!(string[]) textsPatch(Json p, string key) {
  Patch!(string[]) r;
  if (key in p)
    r = textsOf(p, key);
  return r;
}

// ── clients ─────────────────────────────────────────────────────────────────
CreateClientRequest createClientRequest(const RequestContext ctx, Json p) {
  CreateClientRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = textOf(p, "id");
  r.clientId = textOf(p, "clientId");
  r.name = textOf(p, "name");
  r.description = textOf(p, "description");
  r.clientType = textOf(p, "clientType");
  r.redirectUris = textsOf(p, "redirectUris");
  r.allowedScopes = textsOf(p, "allowedScopes");
  r.grantTypes = textsOf(p, "grantTypes");
  r.accessTokenValidity = longOf(p, "accessTokenValidity");
  r.refreshTokenValidity = longOf(p, "refreshTokenValidity");
  r.contacts = textsOf(p, "contacts");
  r.brandingId = textOf(p, "brandingId");
  return r;
}

UpdateClientRequest updateClientRequest(const RequestContext ctx, string key, Json p) {
  UpdateClientRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = OAuthClientId(key);
  r.name = textPatch(p, "name");
  r.description = textPatch(p, "description");
  r.status = textPatch(p, "status");
  r.brandingId = textPatch(p, "brandingId");
  r.redirectUris = textsPatch(p, "redirectUris");
  r.allowedScopes = textsPatch(p, "allowedScopes");
  r.grantTypes = textsPatch(p, "grantTypes");
  r.contacts = textsPatch(p, "contacts");
  r.accessTokenValidity = longPatch(p, "accessTokenValidity");
  r.refreshTokenValidity = longPatch(p, "refreshTokenValidity");
  return r;
}

// ── scopes ──────────────────────────────────────────────────────────────────
CreateScopeRequest createScopeRequest(const RequestContext ctx, Json p) {
  CreateScopeRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = textOf(p, "id");
  r.applicationId = textOf(p, "applicationId");
  r.name = textOf(p, "name");
  r.description = textOf(p, "description");
  return r;
}

UpdateScopeRequest updateScopeRequest(const RequestContext ctx, string key, Json p) {
  UpdateScopeRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = OAuthScopeId(key);
  r.applicationId = textPatch(p, "applicationId");
  r.description = textPatch(p, "description");
  r.status = textPatch(p, "status");
  return r;
}

// ── brandings ───────────────────────────────────────────────────────────────
enum string[] brandingTextFields = [
    "name", "description", "logoUrl", "backgroundUrl", "primaryColor", "secondaryColor", "pageTitle", "footerText",
    "customCss"
  ];

CreateBrandingRequest createBrandingRequest(const RequestContext ctx, Json p) {
  CreateBrandingRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = textOf(p, "id");
  static foreach (f; brandingTextFields)
    __traits(getMember, r, f) = textOf(p, f);
  r.isDefault = boolOf(p, "isDefault");
  return r;
}

UpdateBrandingRequest updateBrandingRequest(const RequestContext ctx, string key, Json p) {
  UpdateBrandingRequest r;
  r.tenantId = tenantOf(ctx);
  r.actor = actorOf(ctx);
  r.id = BrandingConfigId(key);
  static foreach (f; brandingTextFields)
    __traits(getMember, r, f) = textPatch(p, f);
  r.isDefault = boolPatch(p, "isDefault");
  return r;
}

///
unittest {
  auto ctx = RequestContext.local("t1", "test", "jane");
  auto r = createClientRequest(ctx, parseJsonString(`{"name":"A","grantTypes":"authorization_code refresh_token","accessTokenValidity":"600"}`));
  assert(r.grantTypes == ["authorization_code", "refresh_token"] && r.accessTokenValidity == 600 && r.actor.value == "jane");
  auto u = updateClientRequest(ctx, "c1", parseJsonString(`{"status":"blocked","redirectUris":[]}`));
  assert(u.status.isSet && u.redirectUris.isSet && u.redirectUris.value.length == 0 && !u.name.isSet);
  auto b = updateBrandingRequest(ctx, "b1", parseJsonString(`{"primaryColor":"#fff","isDefault":true}`));
  assert(b.primaryColor.value == "#fff" && b.isDefault.value && !b.logoUrl.isSet);
}
