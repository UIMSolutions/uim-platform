/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.application.usecases.manage_clients;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class ManageClientsUseCase : IManageClients {
  protected OAuthRepositories repos;
  protected ISecretGenerator secrets;
  protected IManageTokens tokens;

  this(OAuthRepositories repos, ISecretGenerator secrets, IManageTokens tokens) {
    this.repos = repos;
    this.secrets = secrets;
    this.tokens = tokens;
  }

  OAuthClient[] listClients(TenantId tenantId) {
    return repos.clients.findAll(tenantId);
  }

  OAuthClient getClient(TenantId tenantId, OAuthClientId id) {
    return repos.clients.findById(tenantId, id).required("OAuth client '" ~ id.value ~ "'");
  }

  ClientCredentials createClient(CreateClientRequest r) {
    OAuthClient c;
    stampCreated!(OAuthClient, OAuthClientId)(c, r.tenantId, r.actor, r.id);
    if (repos.clients.existsById(r.tenantId, c.id))
      throw OAuthException.conflict("OAuth client '" ~ c.id.value ~ "' already exists");
    c.clientId = r.clientId.strip.length > 0 ? r.clientId.strip : "sb-" ~ c.id.value;
    c.name = r.name.strip;
    c.description = r.description;
    c.clientType = parseDomainEnumOr!ClientType(r.clientType, ClientType.confidential, "clientType");
    c.redirectUris = normalizeTexts(r.redirectUris);
    c.allowedScopes = normalizeTexts(r.allowedScopes);
    auto grants = normalizeTexts(r.grantTypes);
    c.grantTypes = grants.length > 0 ? parseDomainEnums!GrantType(grants, "grantType")
      : [c.isConfidential ? GrantType.clientCredentials : GrantType.authorizationCode];
    if (r.accessTokenValidity > 0)
      c.accessTokenValidity = r.accessTokenValidity;
    if (r.refreshTokenValidity > 0)
      c.refreshTokenValidity = r.refreshTokenValidity;
    c.contacts = normalizeTexts(r.contacts);
    c.brandingId = r.brandingId.strip;
    c.validate();
    checkReferences(c);
    ensureUniqueClientId(c);

    string secret;
    if (c.isConfidential)
      secret = assignNewSecret(c);
    repos.clients.save(c);
    return ClientCredentials(c, secret);
  }

  OAuthClient updateClient(UpdateClientRequest r) {
    auto c = getClient(r.tenantId, r.id);
    auto wasBlocked = c.status == ClientStatus.blocked;
    r.name.applyTo(c.name);
    c.name = c.name.strip;
    r.description.applyTo(c.description);
    applyEnum(r.status, c.status, "status");
    if (r.brandingId.isSet)
      c.brandingId = r.brandingId.value.strip;
    if (r.redirectUris.isSet)
      c.redirectUris = normalizeTexts(r.redirectUris.value);
    if (r.allowedScopes.isSet)
      c.allowedScopes = normalizeTexts(r.allowedScopes.value);
    if (r.grantTypes.isSet)
      c.grantTypes = parseDomainEnums!GrantType(normalizeTexts(r.grantTypes.value), "grantType");
    if (r.contacts.isSet)
      c.contacts = normalizeTexts(r.contacts.value);
    r.accessTokenValidity.applyTo(c.accessTokenValidity);
    r.refreshTokenValidity.applyTo(c.refreshTokenValidity);
    c.validate();
    checkReferences(c);
    stampUpdated(c, r.actor);
    repos.clients.save(c);
    if (!wasBlocked && c.status == ClientStatus.blocked)
      tokens.revokeClientTokens(c.tenantId, c.clientId, RevocationReason.clientBlocked);
    return c;
  }

  void deleteClient(TenantId tenantId, OAuthClientId id) {
    auto c = getClient(tenantId, id);
    foreach (t; repos.accessTokens.findByClient(tenantId, c.clientId))
      repos.accessTokens.removeById(tenantId, t.id);
    foreach (t; repos.refreshTokens.findByClient(tenantId, c.clientId))
      repos.refreshTokens.removeById(tenantId, t.id);
    foreach (code; repos.codes.findByClient(tenantId, c.clientId))
      repos.codes.removeById(tenantId, code.id);
    repos.clients.removeById(tenantId, id);
  }

  ClientCredentials rotateSecret(TenantId tenantId, OAuthClientId id, UserId actor) {
    auto c = getClient(tenantId, id);
    if (!c.isConfidential)
      throw OAuthException.ruleViolation("Public client '" ~ c.clientId ~ "' has no secret");
    auto secret = assignNewSecret(c);
    stampUpdated(c, actor);
    repos.clients.save(c);
    auto revoked = tokens.revokeClientTokens(tenantId, c.clientId, RevocationReason.secretRotated);
    return ClientCredentials(c, secret, revoked.total);
  }

  protected string assignNewSecret(ref OAuthClient c) {
    auto secret = secrets.generate(32);
    c.secretSalt = secrets.generate(16);
    c.secretHash = hashSecret(c.secretSalt, secret);
    c.secretRotatedAt = nowStdTime();
    return secret;
  }

  protected void checkReferences(const OAuthClient c) {
    foreach (s; c.allowedScopes)
      if (repos.scopes.findByName(c.tenantId, s).isNull)
        throw OAuthException.invalid("Unknown scope '" ~ s ~ "' (create it first)");
    if (c.brandingId.length > 0 && !repos.brandings.existsById(c.tenantId, BrandingConfigId(c.brandingId)))
      throw OAuthException.invalid("Unknown branding configuration '" ~ c.brandingId ~ "'");
  }

  protected void ensureUniqueClientId(const OAuthClient c) {
    auto other = repos.clients.findByClientId(c.tenantId, c.clientId);
    if (!other.isNull && other.id != c.id)
      throw OAuthException.conflict("Client ID '" ~ c.clientId ~ "' is already registered");
  }
}
