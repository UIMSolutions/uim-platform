/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.themes;

// import std.uuid;
// import std.datetime.systime : Clock;

// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.theme;
// import uim.platform.workzone.domain.ports.repositories.themes;
// import uim.platform.workzone.application.dto;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class ManageThemesUseCase { // TODO: UIMUseCase {
  private ThemeRepository repo;

  this(ThemeRepository repo) {
    this.repo = repo;
  }

  CommandResult createTheme(CreateThemeRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Theme name is required");

    auto now = Clock.currStdTime();
    auto t = Theme();
    t.id = randomUUID();
    t.tenantId = req.tenantId;
    t.name = req.name;
    t.description = req.description;
    t.baseTheme = req.baseTheme;
    t.colors = req.colors;
    t.logoUrl = req.logoUrl;
    t.faviconUrl = req.faviconUrl;
    t.customCss = req.customCss;
    t.isDefault = req.isDefault;
    t.createdAt = now;
    t.updatedAt = now;

    repo.save(t);
    return CommandResult(t.id, "");
  }

  Theme getTheme(ThemeId tenantId, id tenantId) {
    return repo.findById(tenantId, id);
  }

  Theme[] listThemes(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult updateTheme(UpdateThemeRequest req) {
    auto t = repo.findById(req.id, req.tenantId);
    if (t.isNull)
      return CommandResult(false, "", "Theme not found");

    if (req.name.length > 0)
      t.name = req.name;
    if (req.description.length > 0)
      t.description = req.description;
    t.colors = req.colors;
    if (req.customCss.length > 0)
      t.customCss = req.customCss;
    t.isDefault = req.isDefault;
    t.updatedAt = Clock.currStdTime();

    repo.update(t);
    return CommandResult(t.id, "");
  }

  CommandResult deleteTheme(ThemeId tenantId, id tenantId) {
    auto t = repo.findById(tenantId, id);
    if (t.isNull)
      return CommandResult(false, "", "Theme not found");

    repo.removeById(tenantId, id);
    return CommandResult(true, id.value, "");
  }
}
