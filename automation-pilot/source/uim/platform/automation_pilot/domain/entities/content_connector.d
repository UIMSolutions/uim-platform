/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.domain.entities.content_connector;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

struct ContentConnector {
    mixin TenantEntity!(ContentConnectorId);

    string name;
    string description;
    ConnectorType connectorType = ConnectorType.github;
    ConnectorStatus status = ConnectorStatus.disconnected;
    string repositoryUrl;
    string branch;
    string path;
    string lastBackupAt;
    string lastRestoreAt;
    BackupStatus backupStatus = BackupStatus.pending;

    Json toJson() const {
        return entityToJson
            .set("name", name)
            .set("description", description)
            .set("connectorType", connectorType.to!string)
            .set("status", status.to!string)
            .set("repositoryUrl", repositoryUrl)
            .set("branch", branch)
            .set("path", path)
            .set("lastBackupAt", lastBackupAt)
            .set("lastRestoreAt", lastRestoreAt)
            .set("backupStatus", backupStatus.to!string);
    }
}
