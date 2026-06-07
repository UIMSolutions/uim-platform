/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.domain.entities.repository_;

import uim.platform.dms_integration;

// mixin(ShowModule!());

@safe:

struct Repository_ {
    mixin TenantEntity!RepositoryId;

    string name;
    string description;
    RepositoryType repositoryType = RepositoryType.managed;
    RepositoryStatus status = RepositoryStatus.provisioning;
    bool isDefault = false;
    string externalUrl;
    string cmisVersion;
    bool encryptionEnabled = false;
    long capacityLimitBytes = 0;
    long usedCapacityBytes = 0;
    string connectionStatus;
    string repositoryKey;
    string externalRepositoryId;
    string region;
    bool isReadOnly = false;
    bool versioningEnabled = true;
    bool fullTextSearchEnabled = false;

    Json toJson() const {
        return entityToJson
            .set("name", name)
            .set("description", description)
            .set("repositoryType", repositoryType.to!string)
            .set("status", status.to!string)
            .set("isDefault", isDefault)
            .set("externalUrl", externalUrl)
            .set("cmisVersion", cmisVersion)
            .set("encryptionEnabled", encryptionEnabled)
            .set("capacityLimitBytes", capacityLimitBytes)
            .set("usedCapacityBytes", usedCapacityBytes)
            .set("connectionStatus", connectionStatus)
            .set("repositoryKey", repositoryKey)
            .set("externalRepositoryId", externalRepositoryId)
            .set("region", region)
            .set("isReadOnly", isReadOnly)
            .set("versioningEnabled", versioningEnabled)
            .set("fullTextSearchEnabled", fullTextSearchEnabled);
    }
}
