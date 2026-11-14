/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.domain.entities.branding_config;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

/// Corporate branding of the login / consent page. One configuration per
/// tenant can be the default; clients may reference a specific one.
struct BrandingConfig {
  mixin TenantEntity!BrandingConfigId;

  string name;
  string description;
  string logoUrl;
  string backgroundUrl;
  string primaryColor; /// #RGB / #RRGGBB
  string secondaryColor;
  string pageTitle;
  string footerText;
  string customCss;
  bool isDefault;

  void validate() const {
    requireText(name, "Branding name");
    foreach (url; [logoUrl, backgroundUrl])
      if (url.length > 0 && !(url.startsWith("https://") && isHttpUrl(url)))
        throw OAuthException.invalid("Image URL '" ~ url ~ "' must be an https URL");
    foreach (color; [primaryColor, secondaryColor])
      if (color.length > 0 && !isBrandingColor(color))
        throw OAuthException.invalid("Color '" ~ color ~ "' must look like #RRGGBB");
    if (pageTitle.length > 120)
      throw OAuthException.invalid("Page title must not exceed 120 characters");
    if (footerText.length > 500)
      throw OAuthException.invalid("Footer text must not exceed 500 characters");
    auto problem = customCssProblem(customCss);
    if (problem.length)
      throw OAuthException.invalid(problem);
  }
}

///
unittest {
  BrandingConfig b;
  b.name = "Corporate";
  b.primaryColor = "#0a6ed1";
  b.logoUrl = "https://cdn.example.com/logo.svg";
  b.validate();
  b.logoUrl = "http://cdn.example.com/logo.svg";
  assert(failsWith(OAuthErrorKind.invalid, () { b.validate(); }));
}
