/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.solution_lifecycle.domain.entities.mta_archive;

import uim.platform.solution_lifecycle;

mixin(ShowModule!());

@safe:

/// An uploaded MTA archive (.mtar) file ready for deployment.
class MtaArchive {
    mixin TenantEntity!(MtaArchiveId);

    string fileName;       /// Original file name (e.g. my-app-1.0.0.mtar)
    string mtaId;          /// MTA application ID from descriptor
    string mtaVersion;     /// MTA version from descriptor
    long   fileSizeBytes;  /// Size of the archive in bytes
    string checksum;       /// SHA-256 checksum for integrity verification
    string uploadedBy;     /// User who uploaded the archive
    string namespace_;     /// Optional MTA namespace
    string[] targetPlatforms; /// Supported target platforms
    bool   validated;      /// Whether the archive has passed validation

    Json toJson() {
        auto j = Json.emptyObject;
        j["id"]              = id.value;
        j["tenantId"]        = tenantId;
        j["fileName"]        = fileName;
        j["mtaId"]           = mtaId;
        j["mtaVersion"]      = mtaVersion;
        j["fileSizeBytes"]   = fileSizeBytes;
        j["checksum"]        = checksum;
        j["uploadedBy"]      = uploadedBy;
        j["namespace"]       = namespace_;
        j["validated"]       = validated;
        auto tp = Json.emptyArray;
        foreach (p; targetPlatforms) tp ~= Json(p);
        j["targetPlatforms"] = tp;
        j["createdAt"]       = createdAt;
        j["updatedAt"]       = updatedAt;
        return j;
    }

    bool isNull() { return id.value.length == 0; }
}
