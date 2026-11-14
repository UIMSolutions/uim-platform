/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.application.usecases.manage_brandings;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class ManageBrandingsUseCase : IManageBrandings {
  protected OAuthRepositories repos;

  this(OAuthRepositories repos) {
    this.repos = repos;
  }

  BrandingConfig[] listBrandings(TenantId tenantId) {
    return repos.brandings.findAll(tenantId);
  }

  BrandingConfig getBranding(TenantId tenantId, BrandingConfigId id) {
    return repos.brandings.findById(tenantId, id).required("Branding configuration '" ~ id.value ~ "'");
  }

  BrandingConfig createBranding(CreateBrandingRequest r) {
    BrandingConfig b;
    stampCreated!(BrandingConfig, BrandingConfigId)(b, r.tenantId, r.actor, r.id);
    if (repos.brandings.existsById(r.tenantId, b.id))
      throw OAuthException.conflict("Branding configuration '" ~ b.id.value ~ "' already exists");
    b.name = r.name.strip;
    b.description = r.description;
    b.logoUrl = r.logoUrl.strip;
    b.backgroundUrl = r.backgroundUrl.strip;
    b.primaryColor = r.primaryColor.strip;
    b.secondaryColor = r.secondaryColor.strip;
    b.pageTitle = r.pageTitle;
    b.footerText = r.footerText;
    b.customCss = r.customCss;
    // the first configuration of a tenant becomes the default
    b.isDefault = r.isDefault || repos.brandings.countAll(r.tenantId) == 0;
    b.validate();
    ensureUniqueName(b);
    if (b.isDefault)
      clearOtherDefaults(b);
    repos.brandings.save(b);
    return b;
  }

  BrandingConfig updateBranding(UpdateBrandingRequest r) {
    auto b = getBranding(r.tenantId, r.id);
    r.name.applyTo(b.name);
    b.name = b.name.strip;
    r.description.applyTo(b.description);
    r.logoUrl.applyTo(b.logoUrl);
    r.backgroundUrl.applyTo(b.backgroundUrl);
    r.primaryColor.applyTo(b.primaryColor);
    r.secondaryColor.applyTo(b.secondaryColor);
    r.pageTitle.applyTo(b.pageTitle);
    r.footerText.applyTo(b.footerText);
    r.customCss.applyTo(b.customCss);
    r.isDefault.applyTo(b.isDefault);
    b.validate();
    ensureUniqueName(b);
    if (b.isDefault)
      clearOtherDefaults(b);
    stampUpdated(b, r.actor);
    repos.brandings.save(b);
    return b;
  }

  void deleteBranding(TenantId tenantId, BrandingConfigId id) {
    auto b = getBranding(tenantId, id);
    auto users = repos.clients.findByBranding(tenantId, b.id.value);
    if (users.length > 0)
      throw OAuthException.ruleViolation("Branding '" ~ b.name ~ "' is still used by " ~ countOf(users.length, "client"));
    repos.brandings.removeById(tenantId, id);
  }

  BrandingConfig brandingFor(TenantId tenantId, string clientId) {
    if (clientId.length > 0) {
      auto c = repos.clients.findByClientId(tenantId, clientId);
      if (!c.isNull && c.brandingId.length > 0) {
        auto own = repos.brandings.findById(tenantId, BrandingConfigId(c.brandingId));
        if (!own.isNull)
          return own;
      }
    }
    return repos.brandings.findDefault(tenantId);
  }

  protected void ensureUniqueName(const BrandingConfig b) {
    auto other = repos.brandings.findByName(b.tenantId, b.name);
    if (!other.isNull && other.id != b.id)
      throw OAuthException.conflict("A branding configuration named '" ~ b.name ~ "' already exists");
  }

  protected void clearOtherDefaults(const BrandingConfig b) {
    foreach (other; repos.brandings.findAll(b.tenantId))
      if (other.isDefault && other.id != b.id) {
        other.isDefault = false;
        repos.brandings.save(other);
      }
  }
}
