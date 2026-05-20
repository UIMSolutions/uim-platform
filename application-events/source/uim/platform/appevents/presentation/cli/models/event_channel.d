/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.cli.models.event_channel;

import uim.platform.service;
import uim.platform.appevents.domain.entities.event_channel;

@safe:

class CliEventChannelModel {
    EventChannel[] items;
    EventChannel   selected;
    bool           hasSelected;
    string         errorMessage;
    string         successMessage;

    void setItems(EventChannel[] list) { items = list; errorMessage = ""; }

    void setSelected(EventChannel item, bool found) {
        selected    = item;
        hasSelected = found;
        errorMessage = found ? "" : "Event channel not found";
    }

    void setError(string msg)   { errorMessage = msg; hasSelected = false; }
    void setSuccess(string msg) { successMessage = msg; errorMessage = ""; }
}
