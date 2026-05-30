/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.web.models.backup_policy;

import uim.platform.postgres;


mixin(ShowModule!());

@safe:

class WebBackupPolicyModel {
    BackupPolicy[] policies;
    BackupPolicy   selected;
    bool           hasSelected;
    string         errorMessage;
    string         successMessage;
    string         pageTitle  = "Backup Policies";
    int            statusCode = 200;

    void setPolicies(BackupPolicy[] list) {
        policies     = list;
        pageTitle    = "Backup Policies (" ~ list.length.to!string ~ ")";
        errorMessage = "";
    }

    void setSelected(BackupPolicy p, bool found) {
        selected     = p;
        hasSelected  = found;
        pageTitle    = found ? "Backup Policy: " ~ p.id.value : "Policy Not Found";
        statusCode   = found ? 200 : 404;
        errorMessage = found ? "" : "Backup policy not found";
    }

    void setError(int code, string msg) { errorMessage = msg; statusCode = code; }
    void setSuccess(string msg)         { successMessage = msg; errorMessage = ""; }
}
