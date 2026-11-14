/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.application.usecases.delegated_auth;

import vibe.textfilter.urlencode : urlEncode;
import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Delegated authentication: corporate identity providers, routing by e-mail
/// domain and the authorization request URL.
class DelegatedAuthUseCase : IManageIdentityProvidersUseCase {
  protected IIdpConfigRepository repo;

  this(IIdpConfigRepository repo) {
    this.repo = repo;
  }

  IdpConfig[] listIdps(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  IdpConfig getIdp(TenantId tenantId, IdpConfigId id) {
    return repo.findById(tenantId, id);
  }

  UsecaseResult createIdp(IdpConfigDTO dto) {
    return guarded(() {
      if (!dto.idpId.isNull && repo.existsById(dto.tenantId, dto.idpId))
        return conflict("Identity provider '" ~ dto.idpId.value ~ "' already exists");
      auto idp = newEntity!IdpConfig(dto.tenantId, dto.idpId, dto.createdBy);
      string[] errors;
      apply(idp, dto, errors);
      errors ~= IdentityValidator.validate(idp);
      if (errors.length)
        return invalid(errors);
      if (idp.isDefault)
        clearDefault(dto.tenantId, idp.id);
      repo.save(idp);
      return created(idp.id.value, "Identity provider created");
    });
  }

  UsecaseResult updateIdp(IdpConfigDTO dto) {
    return guarded(() {
      auto idp = repo.findById(dto.tenantId, dto.idpId);
      if (idp.isNull)
        return notFound("Identity provider", dto.idpId.value);
      string[] errors;
      apply(idp, dto, errors);
      errors ~= IdentityValidator.validate(idp);
      if (errors.length)
        return invalid(errors);
      if (idp.isDefault)
        clearDefault(dto.tenantId, idp.id);
      touch(idp, dto.updatedBy);
      repo.update(idp);
      return succeeded(idp.id.value, "Identity provider updated");
    });
  }

  UsecaseResult deleteIdp(TenantId tenantId, IdpConfigId id) {
    auto idp = repo.findById(tenantId, id);
    if (idp.isNull)
      return notFound("Identity provider", id.value);
    repo.remove(idp);
    return succeeded(id.value, "Identity provider deleted");
  }

  IdpConfig resolveIdp(TenantId tenantId, string email) {
    auto at = email.lastIndexOf('@');
    if (at >= 0) {
      auto domain = email[at + 1 .. $].strip;
      foreach (idp; repo.findByTenant(tenantId))
        if (idp.active && idp.handlesDomain(domain))
          return idp;
    }
    auto fallback = repo.findDefault(tenantId);
    return fallback.active ? fallback : IdpConfig.init;
  }

  string buildAuthorizationUrl(const IdpConfig idp, string redirectUri, string state) {
    if (idp.isNull || idp.authorizationEndpoint.length == 0)
      return "";
    auto separator = idp.authorizationEndpoint.canFind('?') ? "&" : "?";
    return idp.authorizationEndpoint ~ separator
      ~ "response_type=code"
      ~ "&client_id=" ~ urlEncode(idp.clientId)
      ~ "&redirect_uri=" ~ urlEncode(redirectUri)
      ~ "&scope=" ~ urlEncode("openid email profile")
      ~ "&state=" ~ urlEncode(state);
  }

  protected void clearDefault(TenantId tenantId, IdpConfigId keep) {
    foreach (other; repo.findByTenant(tenantId)) {
      if (other.isDefault && other.id != keep) {
        other.isDefault = false;
        repo.update(other);
      }
    }
  }

  protected void apply(ref IdpConfig idp, const IdpConfigDTO dto, ref string[] errors) {
    assignIf(idp.name, dto.name);
    assignIf(idp.metadataUrl, dto.metadataUrl);
    assignIf(idp.authorizationEndpoint, dto.authorizationEndpoint);
    assignIf(idp.tokenEndpoint, dto.tokenEndpoint);
    assignIf(idp.userInfoEndpoint, dto.userInfoEndpoint);
    assignIf(idp.clientId, dto.clientId);
    assignIf(idp.clientSecret, dto.clientSecret);
    idp.domainHints = cleanList(dto.domainHints).map!(d => d.toLower).array;
    idp.isDefault = dto.isDefault;
    idp.active = dto.active;
    readEnum(dto.idpType, idp.idpType, "idpType", errors);
  }
}

///
unittest {
  mixin(ShowTest!("DelegatedAuthUseCase"));

  auto uc = new DelegatedAuthUseCase(new IdpConfigRepository());
  auto t = TenantId("t1");

  IdpConfigDTO azure;
  azure.tenantId = t;
  azure.name = "Azure AD";
  azure.idpType = "oidc";
  azure.authorizationEndpoint = "https://login.example.com/authorize";
  azure.clientId = "client 1";
  azure.domainHints = ["Example.com"];
  assert(uc.createIdp(azure).isSuccess);

  IdpConfigDTO fallback;
  fallback.tenantId = t;
  fallback.name = "Corporate LDAP";
  fallback.idpType = "ldap";
  fallback.isDefault = true;
  assert(uc.createIdp(fallback).isSuccess);

  assert(uc.resolveIdp(t, "jane@example.com").name == "Azure AD");
  assert(uc.resolveIdp(t, "joe@other.org").name == "Corporate LDAP");

  auto url = uc.buildAuthorizationUrl(uc.resolveIdp(t, "jane@example.com"), "https://app/cb?x=1", "s 1");
  assert(url.canFind("client_id=client%201"));
  assert(url.canFind("redirect_uri=https%3A%2F%2Fapp%2Fcb%3Fx%3D1"));
  assert(uc.buildAuthorizationUrl(IdpConfig.init, "x", "y") == "");

  IdpConfigDTO broken;
  broken.tenantId = t;
  broken.name = "Broken";
  broken.idpType = "oidc";
  assert(uc.createIdp(broken).code == 400);
}
