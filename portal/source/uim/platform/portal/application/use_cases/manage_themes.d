module uim.platform.portal.application.usecases.manage_themes;

import uim.platform.portal.domain.entities.theme;
import uim.platform.portal.domain.types;
import uim.platform.portal.domain.ports.theme_repository;
import uim.platform.portal.application.dto;

// import std.uuid;
// import std.datetime.systime : Clock;

class ManageThemesUseCase
{
    private ThemeRepository themeRepo;

    this(ThemeRepository themeRepo)
    {
        this.themeRepo = themeRepo;
    }

    ThemeResponse createTheme(CreateThemeRequest req)
    {
        if (req.name.length == 0)
            return ThemeResponse("", "Theme name is required");

        auto now = Clock.currStdTime();
        auto id = randomUUID().toString();
        auto theme = Theme(
            id,
            req.tenantId,
            req.name,
            req.description,
            req.mode,
            req.baseTheme,
            req.colors,
            req.fonts,
            req.customCss,
            req.isDefault,
            now,
            now,
        );

        // If this is the default, unset previous default
        if (req.isDefault)
        {
            auto currentDefault = themeRepo.findDefault(req.tenantId);
            if (currentDefault != Theme.init)
            {
                currentDefault.isDefault = false;
                currentDefault.updatedAt = now;
                themeRepo.update(currentDefault);
            }
        }

        themeRepo.save(theme);
        return ThemeResponse(id, "");
    }

    Theme getTheme(ThemeId id)
    {
        return themeRepo.findById(id);
    }

    Theme getDefaultTheme(TenantId tenantId)
    {
        return themeRepo.findDefault(tenantId);
    }

    Theme[] listThemes(TenantId tenantId, uint offset = 0, uint limit = 100)
    {
        return themeRepo.findByTenant(tenantId, offset, limit);
    }

    string updateTheme(UpdateThemeRequest req)
    {
        auto theme = themeRepo.findById(req.themeId);
        if (theme == Theme.init)
            return "Theme not found";

        theme.name = req.name.length > 0 ? req.name : theme.name;
        theme.description = req.description;
        theme.mode = req.mode;
        theme.colors = req.colors;
        theme.fonts = req.fonts;
        theme.customCss = req.customCss;

        if (req.isDefault && !theme.isDefault)
        {
            auto currentDefault = themeRepo.findDefault(theme.tenantId);
            if (currentDefault != Theme.init && currentDefault.id != theme.id)
            {
                currentDefault.isDefault = false;
                currentDefault.updatedAt = Clock.currStdTime();
                themeRepo.update(currentDefault);
            }
        }
        theme.isDefault = req.isDefault;
        theme.updatedAt = Clock.currStdTime();
        themeRepo.update(theme);
        return "";
    }

    string deleteTheme(ThemeId id)
    {
        auto theme = themeRepo.findById(id);
        if (theme == Theme.init)
            return "Theme not found";

        if (theme.isDefault)
            return "Cannot delete the default theme";

        themeRepo.remove(id);
        return "";
    }
}
