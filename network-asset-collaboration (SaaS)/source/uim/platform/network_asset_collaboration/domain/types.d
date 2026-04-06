/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.network_asset_collaboration.domain.types;

import uim.platform.network_asset_collaboration;

mixin(ShowModule!());

@safe:

// --- ID Aliases ---
alias EquipmentId = string;
alias ModelId = string;
alias CompanyProfileId = string;
alias DocumentId = string;
alias AnnouncementId = string;
alias FailureModeId = string;
alias SparePartId = string;
alias IndicatorId = string;
alias TenantId = string;
alias UserId = string;

// --- Enumerations ---

enum EquipmentStatus {
    active,
    inactive,
    inMaintenance,
    decommissioned,
    inTransit,
    reserved
}

enum ModelCategory {
    mechanical,
    electrical,
    electronic,
    hydraulic,
    pneumatic,
    software,
    assembly,
    custom
}

enum CompanyType {
    manufacturer,
    operator,
    serviceProvider,
    oem,
    distributor
}

enum CompanyStatus {
    active,
    inactive,
    pending,
    suspended
}

enum DocumentType {
    manual,
    certificate,
    drawing,
    specification,
    maintenancePlan,
    serviceBulletin,
    safetySheet,
    report
}

enum DocumentStatus {
    draft,
    published,
    archived,
    superseded
}

enum AnnouncementType {
    recall,
    serviceBulletin,
    endOfLife,
    upgrade,
    safetyAlert,
    generalInfo
}

enum AnnouncementSeverity {
    critical,
    high,
    medium,
    low,
    informational
}

enum AnnouncementStatus {
    draft,
    published,
    acknowledged,
    resolved,
    expired
}

enum FailureSeverity {
    critical,
    major,
    minor,
    negligible
}

enum IndicatorType {
    temperature,
    pressure,
    vibration,
    humidity,
    voltage,
    current,
    rpm,
    flowRate,
    custom
}

enum IndicatorStatus {
    normal,
    warning,
    critical,
    unknown
}
