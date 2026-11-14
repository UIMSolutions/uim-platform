/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A demo scenario for an empty tenant (CLI "seed", local development).
module uim.platform.oauth.application.services.demo_data;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

struct DemoDataResult {
  size_t scopes;
  size_t clients;
  size_t brandings;
  size_t tokens;
  string[string] secrets; /// clientId → plain secret of the confidential demo clients
}

DemoDataResult seedDemoData(OAuthPorts ports, TenantId tenantId, UserId actor) {
  if (ports.clients.listClients(tenantId).length > 0 || ports.scopes.listScopes(tenantId).length > 0)
    throw OAuthException.conflict("Tenant '" ~ tenantId.value ~ "' is not empty");
  DemoDataResult r;

  CreateBrandingRequest b;
  b.tenantId = tenantId;
  b.actor = actor;
  b.id = "corporate";
  b.name = "Corporate";
  b.description = "Default login page branding";
  b.primaryColor = "#0a6ed1";
  b.secondaryColor = "#354a5f";
  b.pageTitle = "ACME Sign-in";
  b.footerText = "© ACME Corp. — Imprint · Privacy";
  b.isDefault = true;
  ports.brandings.createBranding(b);
  r.brandings++;

  foreach (spec; [
      ["orders", "orders.read", "Read sales orders"], ["orders", "orders.write", "Create and change sales orders"],
      ["billing", "billing.read", "Read invoices"], ["billing", "billing.admin", "Administrate billing"],
      ["profile", "openid", "Sign the user in"], ["profile", "profile", "Read the user profile"]
    ]) {
    CreateScopeRequest s;
    s.tenantId = tenantId;
    s.actor = actor;
    s.id = spec[1];
    s.applicationId = spec[0];
    s.name = spec[1];
    s.description = spec[2];
    ports.scopes.createScope(s);
    r.scopes++;
  }

  CreateClientRequest service;
  service.tenantId = tenantId;
  service.actor = actor;
  service.id = "billing-service";
  service.clientId = "sb-billing-service";
  service.name = "Billing Service";
  service.description = "Backend job reading orders (client credentials)";
  service.allowedScopes = ["orders.read", "billing.read", "billing.admin"];
  service.grantTypes = ["client_credentials"];
  service.accessTokenValidity = 1800;
  service.contacts = ["billing-team@example.com"];
  auto created = ports.clients.createClient(service);
  r.secrets[created.client.clientId] = created.clientSecret;
  r.clients++;

  CreateClientRequest web;
  web.tenantId = tenantId;
  web.actor = actor;
  web.id = "order-portal";
  web.clientId = "sb-order-portal";
  web.name = "Order Portal";
  web.description = "Server side web app (authorization code + refresh token)";
  web.redirectUris = ["https://portal.example.com/login/callback", "http://localhost:5000/login/callback"];
  web.allowedScopes = ["openid", "profile", "orders.read", "orders.write"];
  web.grantTypes = ["authorization_code", "refresh_token"];
  created = ports.clients.createClient(web);
  r.secrets[created.client.clientId] = created.clientSecret;
  r.clients++;

  CreateClientRequest spa;
  spa.tenantId = tenantId;
  spa.actor = actor;
  spa.id = "mobile-app";
  spa.clientId = "mobile-app";
  spa.name = "Mobile App";
  spa.description = "Native app (public client, PKCE)";
  spa.clientType = "public";
  spa.redirectUris = ["com.example.orders:/oauth2redirect"];
  spa.allowedScopes = ["openid", "profile", "orders.read"];
  spa.grantTypes = ["authorization_code", "refresh_token"];
  spa.accessTokenValidity = 900;
  ports.clients.createClient(spa);
  r.clients++;

  // one token so that the token lists are not empty
  TokenRequest t;
  t.tenantId = tenantId;
  t.grantType = "client_credentials";
  t.clientId = "sb-billing-service";
  t.clientSecret = r.secrets["sb-billing-service"];
  t.scope_ = "orders.read billing.read";
  ports.issuer.exchange(t);
  r.tokens++;
  return r;
}
