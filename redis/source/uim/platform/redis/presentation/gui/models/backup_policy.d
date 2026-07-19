/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.gui.models.backup_policy;

import uim.platform.redis;
mixin(ShowModule!());

@safe:

class GuiBackupPolicyModel {
    BackupPolicy[] policies;
    BackupPolicy   selected;
    bool           hasSelected;
    string         errorMessage;
    string         successMessage;
    string         windowTitle = "Redis — Backup Policies";
    void delegate() @safe onChanged;

    void setPolicies(BackupPolicy[] list)          { policies = list; errorMessage = ""; if (onChanged !is null) onChanged(); }
    void setSelected(BackupPolicy p, bool found)   { selected = p; hasSelected = found; errorMessage = found ? "" : "Policy not found"; if (onChanged !is null) onChanged(); }
    void setError(string msg)                      { errorMessage = msg; hasSelected = false; if (onChanged !is null) onChanged(); }
    void setSuccess(string msg)                    { successMessage = msg; errorMessage = ""; if (onChanged !is null) onChanged(); }
}
