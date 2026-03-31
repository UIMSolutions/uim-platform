module application.use_cases.manage_subaccounts;

import application.dto;
import domain.entities.subaccount;
import domain.entities.platform_event;
import domain.ports.subaccount_repository;
import domain.ports.platform_event_repository;
import domain.types;

/// Use case: manage subaccount lifecycle within global accounts.
class ManageSubaccountsUseCase
{
    private SubaccountRepository repo;
    private PlatformEventRepository eventRepo;

    this(SubaccountRepository repo, PlatformEventRepository eventRepo)
    {
        this.repo = repo;
        this.eventRepo = eventRepo;
    }

    CommandResult create(CreateSubaccountRequest req)
    {
        if (req.globalAccountId.length == 0)
            return CommandResult(false, "", "Global account ID is required");
        if (req.displayName.length == 0)
            return CommandResult(false, "", "Display name is required");
        if (req.subdomain.length == 0)
            return CommandResult(false, "", "Subdomain is required");
        if (req.region.length == 0)
            return CommandResult(false, "", "Region is required");

        // Check subdomain uniqueness
        auto existing = repo.findBySubdomain(req.subdomain);
        if (existing.id.length > 0)
            return CommandResult(false, "", "Subdomain '" ~ req.subdomain ~ "' is already taken");

        import std.uuid : randomUUID;
        auto id = randomUUID().toString();

        Subaccount sub;
        sub.id = id;
        sub.globalAccountId = req.globalAccountId;
        sub.parentDirectoryId = req.parentDirectoryId;
        sub.displayName = req.displayName;
        sub.description = req.description;
        sub.subdomain = req.subdomain;
        sub.region = req.region;
        sub.usage = parseUsage(req.usage);
        sub.betaEnabled = req.betaEnabled;
        sub.usedForProduction = req.usedForProduction;
        sub.status = SubaccountStatus.creating;
        sub.createdAt = clockSeconds();
        sub.modifiedAt = sub.createdAt;
        sub.createdBy = req.createdBy;
        sub.labels = req.labels;
        sub.customProperties = req.customProperties;

        repo.save(sub);

        // Transition to active
        sub.status = SubaccountStatus.active;
        repo.update(sub);

        emitEvent(req.globalAccountId, id, PlatformEventCategory.subaccountLifecycle,
            "subaccount.created", "Subaccount created: " ~ req.displayName, req.createdBy);

        return CommandResult(true, id, "");
    }

    CommandResult update(SubaccountId id, UpdateSubaccountRequest req)
    {
        auto sub = repo.findById(id);
        if (sub.id.length == 0)
            return CommandResult(false, "", "Subaccount not found");

        if (req.displayName.length > 0) sub.displayName = req.displayName;
        if (req.description.length > 0) sub.description = req.description;
        if (req.usage.length > 0) sub.usage = parseUsage(req.usage);
        sub.betaEnabled = req.betaEnabled;
        sub.usedForProduction = req.usedForProduction;
        if (req.labels.length > 0) sub.labels = req.labels;
        if (req.customProperties.length > 0) sub.customProperties = req.customProperties;
        sub.modifiedAt = clockSeconds();

        repo.update(sub);
        return CommandResult(true, id, "");
    }

    CommandResult moveSubaccount(SubaccountId id, MoveSubaccountRequest req)
    {
        auto sub = repo.findById(id);
        if (sub.id.length == 0)
            return CommandResult(false, "", "Subaccount not found");
        if (sub.status != SubaccountStatus.active)
            return CommandResult(false, "", "Subaccount must be active to move");

        sub.status = SubaccountStatus.moveInProgress;
        sub.parentDirectoryId = req.targetDirectoryId;
        sub.modifiedAt = clockSeconds();
        repo.update(sub);

        // Complete move
        sub.status = SubaccountStatus.active;
        repo.update(sub);
        return CommandResult(true, id, "");
    }

    CommandResult suspend(SubaccountId id)
    {
        auto sub = repo.findById(id);
        if (sub.id.length == 0)
            return CommandResult(false, "", "Subaccount not found");
        if (sub.status != SubaccountStatus.active)
            return CommandResult(false, "", "Only active subaccounts can be suspended");

        sub.status = SubaccountStatus.suspended;
        sub.modifiedAt = clockSeconds();
        repo.update(sub);
        return CommandResult(true, id, "");
    }

    CommandResult reactivate(SubaccountId id)
    {
        auto sub = repo.findById(id);
        if (sub.id.length == 0)
            return CommandResult(false, "", "Subaccount not found");
        if (sub.status != SubaccountStatus.suspended)
            return CommandResult(false, "", "Only suspended subaccounts can be reactivated");

        sub.status = SubaccountStatus.active;
        sub.modifiedAt = clockSeconds();
        repo.update(sub);
        return CommandResult(true, id, "");
    }

    Subaccount getById(SubaccountId id) { return repo.findById(id); }
    Subaccount[] listByGlobalAccount(GlobalAccountId gaId) { return repo.findByGlobalAccount(gaId); }
    Subaccount[] listByDirectory(DirectoryId dirId) { return repo.findByDirectory(dirId); }
    Subaccount[] listByRegion(GlobalAccountId gaId, string region) { return repo.findByRegion(gaId, region); }

    CommandResult remove(SubaccountId id)
    {
        auto sub = repo.findById(id);
        if (sub.id.length == 0)
            return CommandResult(false, "", "Subaccount not found");
        repo.remove(id);
        emitEvent(sub.globalAccountId, id, PlatformEventCategory.subaccountLifecycle,
            "subaccount.deleted", "Subaccount deleted: " ~ sub.displayName, "system");
        return CommandResult(true, id, "");
    }

    private void emitEvent(string gaId, string subId, PlatformEventCategory cat,
        string eventType, string desc, string initiatedBy)
    {
        import std.uuid : randomUUID;
        PlatformEvent ev;
        ev.id = randomUUID().toString();
        ev.globalAccountId = gaId;
        ev.subaccountId = subId;
        ev.category = cat;
        ev.severity = PlatformEventSeverity.info;
        ev.eventType = eventType;
        ev.description = desc;
        ev.initiatedBy = initiatedBy;
        ev.sourceService = "cloud-management";
        ev.timestamp = clockSeconds();
        eventRepo.save(ev);
    }

    private SubaccountUsage parseUsage(string s)
    {
        switch (s)
        {
            case "production": return SubaccountUsage.production;
            case "development": return SubaccountUsage.development;
            case "test": return SubaccountUsage.test;
            case "staging": return SubaccountUsage.staging;
            case "demo": return SubaccountUsage.demo;
            default: return SubaccountUsage.unset;
        }
    }

    private long clockSeconds()
    {
        import core.time : MonoTime;
        return MonoTime.currTime.ticks / 10_000_000;
    }
}
