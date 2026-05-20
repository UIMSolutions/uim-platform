/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.cli.models.event_message;

import uim.platform.service;
import uim.platform.appevents.domain.entities.event_message;

@safe:

class CliEventMessageModel {
    EventMessage[] items;
    EventMessage   selected;
    bool           hasSelected;
    string         errorMessage;
    string         successMessage;

    void setItems(EventMessage[] list) { items = list; errorMessage = ""; }

    void setSelected(EventMessage item, bool found) {
        selected    = item;
        hasSelected = found;
        errorMessage = found ? "" : "Event message not found";
    }

    void setError(string msg)   { errorMessage = msg; hasSelected = false; }
    void setSuccess(string msg) { successMessage = msg; errorMessage = ""; }
}
