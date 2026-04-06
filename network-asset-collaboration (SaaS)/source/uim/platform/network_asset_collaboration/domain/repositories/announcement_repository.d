/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.network_asset_collaboration.domain.repositories.announcement_repository;

import uim.platform.network_asset_collaboration;

mixin(ShowModule!());

@safe:

interface AnnouncementRepository {
    Announcement[] findAll();
    Announcement* findById(AnnouncementId id);
    Announcement[] findByTenant(TenantId tenantId);
    Announcement[] findByPublisher(string publisherId);
    Announcement[] findBySeverity(AnnouncementSeverity severity);
    Announcement[] findByStatus(AnnouncementStatus status);
    void save(Announcement announcement);
    void update(Announcement announcement);
    void remove(AnnouncementId id);
}
