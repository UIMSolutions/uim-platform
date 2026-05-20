/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.web.models.event_message;

import uim.platform.service;
import uim.platform.appevents.domain.entities.event_message;

@safe:

class WebEventMessageModel {
    EventMessage[] items;
    EventMessage   selected;
    bool           hasSelected;
    string         errorMessage;
    string         successMessage;
    string         title;

    void setItems(EventMessage[] list) { items = list; errorMessage = ""; title = "Event Messages"; }

    void setSelected(EventMessage item, bool found) {
        selected     = item;
        hasSelected  = found;
        title        = found ? "Event Message: " ~ item.id.value : "Not Found";
        errorMessage = found ? "" : "Event message not found";
    }

    void setError(string msg)   { errorMessage = msg; hasSelected = false; title = "Error"; }
    void setSuccess(string msg) { successMessage = msg; errorMessage = ""; }
}
