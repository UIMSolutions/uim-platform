/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.web.models.system_registration;

import uim.platform.service;
import uim.platform.appevents.domain.entities.system_registration;

@safe:

class WebSystemRegistrationModel {
    SystemRegistration[] items;
    SystemRegistration   selected;
    bool                 hasSelected;
    string               errorMessage;
    string               successMessage;
    string               title;

    void setItems(SystemRegistration[] list) { items = list; errorMessage = ""; title = "System Registrations"; }

    void setSelected(SystemRegistration item, bool found) {
        selected     = item;
        hasSelected  = found;
        title        = found ? "System Registration: " ~ item.systemId : "Not Found";
        errorMessage = found ? "" : "System registration not found";
    }

    void setError(string msg)   { errorMessage = msg; hasSelected = false; title = "Error"; }
    void setSuccess(string msg) { successMessage = msg; errorMessage = ""; }
}
