module uim.platform.portal.application.usecases.manage_sites;

import uim.platform.portal.domain.entities.site;
import uim.platform.portal.domain.types;
import uim.platform.portal.domain.ports.site_repository;
import uim.platform.portal.domain.services.site_publisher;
import uim.platform.portal.application.dto;

import std.uuid;
import std.datetime.systime : Clock;

class ManageSitesUseCase
{
    private SiteRepository siteRepo;

    this(SiteRepository siteRepo)
    {
        this.siteRepo = siteRepo;
    }

    SiteResponse createSite(CreateSiteRequest req)
    {
        if (req.name.length == 0)
            return SiteResponse("", "Site name is required");

        if (req.alias_.length > 0)
        {
            auto existing = siteRepo.findByAlias(req.tenantId, req.alias_);
            if (existing != Site.init)
                return SiteResponse("", "Site alias already exists");
        }

        auto now = Clock.currStdTime();
        auto id = randomUUID().toString();
        auto site = Site(
            id,
            req.tenantId,
            req.name,
            req.description,
            req.alias_,
            SiteStatus.draft,
            req.themeId,
            [],  // pageIds
            [],  // menuItemIds
            [],  // allowedRoleIds
            req.settings,
            now,
            now,
            "",  // createdBy
        );
        siteRepo.save(site);
        return SiteResponse(id, "");
    }

    Site getSite(SiteId id)
    {
        return siteRepo.findById(id);
    }

    Site[] listSites(TenantId tenantId, uint offset = 0, uint limit = 100)
    {
        return siteRepo.findByTenant(tenantId, offset, limit);
    }

    Site[] listSitesByStatus(TenantId tenantId, SiteStatus status, uint offset = 0, uint limit = 100)
    {
        return siteRepo.findByStatus(tenantId, status, offset, limit);
    }

    string updateSite(UpdateSiteRequest req)
    {
        auto site = siteRepo.findById(req.siteId);
        if (site == Site.init)
            return "Site not found";

        site.name = req.name.length > 0 ? req.name : site.name;
        site.description = req.description;
        site.alias_ = req.alias_.length > 0 ? req.alias_ : site.alias_;
        site.themeId = req.themeId.length > 0 ? req.themeId : site.themeId;
        site.settings = req.settings;
        site.updatedAt = Clock.currStdTime();
        siteRepo.update(site);
        return "";
    }

    string publishSite(SiteId id)
    {
        auto site = siteRepo.findById(id);
        if (site == Site.init)
            return "Site not found";

        auto result = validateForPublish(site);
        if (!result.valid)
        {
            import std.algorithm : joiner;
            import std.conv : to;
            return result.errors.joiner("; ").to!string;
        }

        site.status = SiteStatus.published;
        site.updatedAt = Clock.currStdTime();
        siteRepo.update(site);
        return "";
    }

    string unpublishSite(SiteId id)
    {
        auto site = siteRepo.findById(id);
        if (site == Site.init)
            return "Site not found";

        site.status = SiteStatus.unpublished;
        site.updatedAt = Clock.currStdTime();
        siteRepo.update(site);
        return "";
    }

    string archiveSite(SiteId id)
    {
        auto site = siteRepo.findById(id);
        if (site == Site.init)
            return "Site not found";

        site.status = SiteStatus.archived;
        site.updatedAt = Clock.currStdTime();
        siteRepo.update(site);
        return "";
    }

    string deleteSite(SiteId id)
    {
        auto site = siteRepo.findById(id);
        if (site == Site.init)
            return "Site not found";

        siteRepo.remove(id);
        return "";
    }
}
