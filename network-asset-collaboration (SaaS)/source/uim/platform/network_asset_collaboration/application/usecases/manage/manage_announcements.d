/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.network_asset_collaboration.application.usecases.manage.manage_announcements;

import uim.platform.network_asset_collaboration;

mixin(ShowModule!());

@safe:

class ManageAnnouncementsUseCase : UIMUseCase {
    private AnnouncementRepository repo;

    this(AnnouncementRepository repo) {
        this.repo = repo;
    }

    Announcement* get_(AnnouncementId id) {
        return repo.findById(id);
    }

    Announcement[] list() {
        return repo.findAll();
    }

    Announcement[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Announcement[] listByPublisher(string publisherId) {
        return repo.findByPublisher(publisherId);
    }

    Announcement[] listBySeverity(AnnouncementSeverity severity) {
        return repo.findBySeverity(severity);
    }

    Announcement[] listByStatus(AnnouncementStatus status) {
        return repo.findByStatus(status);
    }

    CommandResult create(AnnouncementDTO dto) {
        Announcement a;
        a.id = dto.id;
        a.tenantId = dto.tenantId;
        a.title = dto.title;
        a.description = dto.description;
        a.publisherId = dto.publisherId;
        a.effectiveDate = dto.effectiveDate;
        a.expiryDate = dto.expiryDate;
        a.createdBy = dto.createdBy;
        if (!AssetValidator.isValidAnnouncement(a))
            return CommandResult(false, "", "Invalid announcement data");
        repo.save(a);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(AnnouncementDTO dto) {
        auto existing = repo.findById(dto.id);
        if (existing is null)
            return CommandResult(false, "", "Announcement not found");
        if (dto.title.length > 0) existing.title = dto.title;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.modifiedBy.length > 0) existing.modifiedBy = dto.modifiedBy;
        repo.update(*existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(AnnouncementId id) {
        auto existing = repo.findById(id);
        if (existing is null)
            return CommandResult(false, "", "Announcement not found");
        repo.remove(id);
        return CommandResult(true, id, "");
    }
}
