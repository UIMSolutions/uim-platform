module application.usecases.manage_push_notifications;

import uim.platform.xyz.application.dto;
import uim.platform.xyz.domain.entities.push_notification;
import uim.platform.xyz.domain.ports.push_notification_repository;
import uim.platform.xyz.domain.ports.push_template_repository;
import uim.platform.xyz.domain.ports.push_campaign_repository;
import uim.platform.xyz.domain.entities.push_template;
import uim.platform.xyz.domain.entities.push_campaign;
import uim.platform.xyz.domain.services.push_dispatcher;
import uim.platform.xyz.domain.types;

/// Use case: manage push notifications, templates, and campaigns.
class ManagePushNotificationsUseCase
{
    private PushNotificationRepository notifRepo;
    private PushTemplateRepository templateRepo;
    private PushCampaignRepository campaignRepo;
    private PushDispatcher dispatcher;

    this(PushNotificationRepository notifRepo,
        PushTemplateRepository templateRepo,
        PushCampaignRepository campaignRepo,
        PushDispatcher dispatcher)
    {
        this.notifRepo = notifRepo;
        this.templateRepo = templateRepo;
        this.campaignRepo = campaignRepo;
        this.dispatcher = dispatcher;
    }

    // --- Notifications ---

    CommandResult send(SendPushRequest req)
    {
        if (req.appId.length == 0)
            return CommandResult(false, "", "App ID is required");

        import std.uuid : randomUUID;
        auto id = randomUUID().toString();

        PushNotification n;
        n.id = id;
        n.appId = req.appId;
        n.tenantId = req.tenantId;
        n.templateId = req.templateId;

        // Resolve template if specified
        if (req.templateId.length > 0)
        {
            auto tmpl = templateRepo.findById(req.templateId);
            if (tmpl.id.length > 0)
            {
                n.title = tmpl.titleTemplate;
                n.body_ = tmpl.bodyTemplate;
                n.imageUrl = tmpl.imageUrl;
                n.deepLink = tmpl.deepLink;
                n.sound = tmpl.sound;
                n.silent = tmpl.silent;
            }
        }

        // Override with request values if provided
        if (req.title.length > 0) n.title = req.title;
        if (req.body_.length > 0) n.body_ = req.body_;
        if (req.imageUrl.length > 0) n.imageUrl = req.imageUrl;
        if (req.deepLink.length > 0) n.deepLink = req.deepLink;
        n.priority = parsePriority(req.priority);
        n.targetDeviceIds = req.targetDeviceIds;
        n.targetUserIds = req.targetUserIds;
        n.targetSegment = req.targetSegment;
        n.targetPlatforms = parsePlatforms(req.targetPlatforms);
        n.customData = req.customData;
        n.badge = req.badge;
        if (req.sound.length > 0) n.sound = req.sound;
        n.silent = req.silent;
        n.scheduledAt = req.scheduledAt;
        n.createdBy = req.createdBy;
        n.createdAt = clockSeconds();

        // Validate
        auto validation = dispatcher.validateNotification(n);
        if (!validation.valid)
            return CommandResult(false, "", validation.reason);

        n.status = req.scheduledAt > 0 ? PushStatus.pending : PushStatus.sent;
        if (n.status == PushStatus.sent) n.sentAt = clockSeconds();

        notifRepo.save(n);
        return CommandResult(true, id, "");
    }

    CommandResult cancel(PushNotificationId id)
    {
        auto n = notifRepo.findById(id);
        if (n.id.length == 0)
            return CommandResult(false, "", "Notification not found");
        if (n.status != PushStatus.pending)
            return CommandResult(false, "", "Only pending notifications can be cancelled");
        n.status = PushStatus.cancelled;
        notifRepo.update(n);
        return CommandResult(true, id, "");
    }

    PushNotification getNotification(PushNotificationId id) { return notifRepo.findById(id); }
    PushNotification[] listByApp(MobileAppId appId) { return notifRepo.findByApp(appId); }

    // --- Templates ---

    CommandResult createTemplate(CreatePushTemplateRequest req)
    {
        if (req.name.length == 0)
            return CommandResult(false, "", "Template name is required");

        import std.uuid : randomUUID;
        auto id = randomUUID().toString();

        PushTemplate t;
        t.id = id;
        t.appId = req.appId;
        t.tenantId = req.tenantId;
        t.name = req.name;
        t.titleTemplate = req.titleTemplate;
        t.bodyTemplate = req.bodyTemplate;
        t.imageUrl = req.imageUrl;
        t.deepLink = req.deepLink;
        t.defaultPriority = parsePriority(req.defaultPriority);
        t.defaultData = req.defaultData;
        t.sound = req.sound.length > 0 ? req.sound : "default";
        t.silent = req.silent;
        t.locale = req.locale;
        t.createdBy = req.createdBy;
        t.createdAt = clockSeconds();
        t.updatedAt = t.createdAt;

        templateRepo.save(t);
        return CommandResult(true, id, "");
    }

    PushTemplate getTemplate(PushTemplateId id) { return templateRepo.findById(id); }
    PushTemplate[] listTemplates(MobileAppId appId) { return templateRepo.findByApp(appId); }

    CommandResult removeTemplate(PushTemplateId id)
    {
        auto t = templateRepo.findById(id);
        if (t.id.length == 0)
            return CommandResult(false, "", "Template not found");
        templateRepo.remove(id);
        return CommandResult(true, id, "");
    }

    // --- Campaigns ---

    CommandResult createCampaign(CreatePushCampaignRequest req)
    {
        if (req.name.length == 0)
            return CommandResult(false, "", "Campaign name is required");

        if (req.templateId.length == 0)
            return CommandResult(false, "", "Template ID is required");

        import std.uuid : randomUUID;
        auto id = randomUUID().toString();

        PushCampaign c;
        c.id = id;
        c.appId = req.appId;
        c.tenantId = req.tenantId;
        c.name = req.name;
        c.description = req.description;
        c.templateId = req.templateId;
        c.status = CampaignStatus.draft;
        c.targetSegment = req.targetSegment;
        c.targetPlatforms = parsePlatforms(req.targetPlatforms);
        c.scheduledStartAt = req.scheduledStartAt;
        c.scheduledEndAt = req.scheduledEndAt;
        c.templateVariables = req.templateVariables;
        c.createdBy = req.createdBy;
        c.createdAt = clockSeconds();
        c.updatedAt = c.createdAt;

        campaignRepo.save(c);
        return CommandResult(true, id, "");
    }

    CommandResult activateCampaign(PushCampaignId id)
    {
        auto c = campaignRepo.findById(id);
        if (c.id.length == 0)
            return CommandResult(false, "", "Campaign not found");
        c.status = CampaignStatus.active;
        c.updatedAt = clockSeconds();
        campaignRepo.update(c);
        return CommandResult(true, id, "");
    }

    CommandResult pauseCampaign(PushCampaignId id)
    {
        auto c = campaignRepo.findById(id);
        if (c.id.length == 0)
            return CommandResult(false, "", "Campaign not found");
        c.status = CampaignStatus.paused;
        c.updatedAt = clockSeconds();
        campaignRepo.update(c);
        return CommandResult(true, id, "");
    }

    PushCampaign getCampaign(PushCampaignId id) { return campaignRepo.findById(id); }
    PushCampaign[] listCampaigns(MobileAppId appId) { return campaignRepo.findByApp(appId); }

    CommandResult removeCampaign(PushCampaignId id)
    {
        auto c = campaignRepo.findById(id);
        if (c.id.length == 0)
            return CommandResult(false, "", "Campaign not found");
        campaignRepo.remove(id);
        return CommandResult(true, id, "");
    }
}

private PushPriority parsePriority(string s)
{
    switch (s)
    {
    case "low": return PushPriority.low;
    case "high": return PushPriority.high;
    case "critical": return PushPriority.critical;
    default: return PushPriority.normal;
    }
}

private MobilePlatform[] parsePlatforms(string[] platforms)
{
    MobilePlatform[] result;
    foreach (p; platforms)
    {
        switch (p)
        {
        case "ios": result ~= MobilePlatform.ios; break;
        case "android": result ~= MobilePlatform.android; break;
        case "windows": result ~= MobilePlatform.windows; break;
        case "webApp": result ~= MobilePlatform.webApp; break;
        default: break;
        }
    }
    return result;
}

private long clockSeconds()
{
    import core.time : MonoTime;
    return MonoTime.currTime.ticks / 1_000_000_000;
}
