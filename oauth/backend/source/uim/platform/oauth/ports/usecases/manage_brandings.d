/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.ports.usecases.manage_brandings;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

interface IManageBrandings {
  BrandingConfig[] listBrandings(TenantId tenantId);
  BrandingConfig getBranding(TenantId tenantId, BrandingConfigId id);
  /// Making a configuration the default clears the flag on all others.
  BrandingConfig createBranding(CreateBrandingRequest request);
  BrandingConfig updateBranding(UpdateBrandingRequest request);
  /// Fails while clients reference the configuration.
  void deleteBranding(TenantId tenantId, BrandingConfigId id);
  /// Branding of a client's login page: its own, else the default (isNull if none).
  BrandingConfig brandingFor(TenantId tenantId, string clientId);
}
