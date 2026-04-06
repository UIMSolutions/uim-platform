/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.network_asset_collaboration.domain.entities.announcement;

import uim.platform.network_asset_collaboration;

mixin(ShowModule!());

@safe:

struct Announcement {
    AnnouncementId id;
    TenantId tenantId;
    string title;
    string description;
    AnnouncementType announcementType = AnnouncementType.generalInfo;
    AnnouncementSeverity severity = AnnouncementSeverity.informational;
    AnnouncementStatus status = AnnouncementStatus.draft;
    string publisherId;
    string[] affectedModelIds;
    string[] affectedEquipmentIds;
    string effectiveDate;
    string expiryDate;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}
