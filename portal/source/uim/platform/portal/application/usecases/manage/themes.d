/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.application.usecases.manage.themes;
// import uim.platform.portal.domain.entities.theme;
// import uim.platform.portal.domain.types;
// import uim.platform.portal.domain.ports.repositories.themes;
// import uim.platform.portal.application.dto;


// import uim.platform.portal.application.dto;
// import uim.platform.portal.domain.types;
import uim.platform.portal;

// mixin(ShowModule!());

@safe:
class ManageThemesUseCase { // TODO: UIMUseCase {
  private ThemeRepository repo;

  this(ThemeRepository repo) {
    this.repo = repo;
  }

  ThemeResponse createTheme(CreateThemeRequest req) {
    if (req.name.length == 0)
      return ThemeResponse("", "Theme name is required");

    Theme theme;
    theme.initEntity(req.tenantId, req.createdBy);

    theme.name = req.name;
    theme.description = req.description;
    theme.baseTheme = req.baseTheme;
    theme.colors = req.colors;
    theme.fonts = req.fonts;
    theme.customCss = req.customCss;
    theme.isDefault = req.isDefault;  

    // If this is the default, unset previous default
    if (req.isDefault) {
      auto currentDefault = repo.findDefault(req.tenantId);
      if (currentDefault != Theme.init) {
        currentDefault.isDefault = false;
        currentDefault.updatedAt = currentTimestamp();
        repo.update(currentDefault);
      }
    }

    repo.save(theme);
    return ThemeResponse(theme.id.value, "");
  }

  Theme getTheme(TenantId tenantId, ThemeId id) {
    return repo.findById(tenantId, id);
  }

  Theme getDefaultTheme(TenantId tenantId) {
    return repo.findDefault(tenantId);
  }

  Theme[] listThemes(TenantId tenantId, size_t offset = 0, size_t limit = 100) {
    return repo.findByTenant(tenantId, offset, limit);
  }

  CommandResult updateTheme(UpdateThemeRequest req) {
    auto theme = repo.findById(req.tenantId, req.themeId);
    if (theme.isNull)
      return CommandResult(false, "", "Theme not found");

    with (theme) {
      name = req.name.length > 0 ? req.name : theme.name;
      description = req.description;
      mode = req.mode;
      colors = req.colors;
      fonts = req.fonts;
      customCss = req.customCss;
    }
    if (req.isDefault && !theme.isDefault) {
      auto currentDefault = repo.findDefault(theme.tenantId);
      if (currentDefault != Theme.init && currentDefault.id != theme.id) {
        currentDefault.isDefault = false;
        currentDefault.updatedAt = currentTimestamp();
        repo.update(currentDefault);
      }
    }
    theme.isDefault = req.isDefault;
    theme.updatedAt = currentTimestamp();

    repo.update(theme);
    return CommandResult(true, theme.id.value, "Theme updated successfully.");
  }

  CommandResult deleteTheme(TenantId tenantId, ThemeId id) {
    auto theme = repo.findById(tenantId, id);
    if (theme.isNull)
      return CommandResult(false, "", "Theme not found");

    if (theme.isDefault)
      return CommandResult(false, "", "Cannot delete the default theme");

    repo.remove(theme);
    return CommandResult(true, theme.id.value, "Theme deleted successfully.");
  }
}
