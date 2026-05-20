/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.web.models.dead_letter_entry;

import uim.platform.service;
import uim.platform.appevents.domain.entities.dead_letter_entry;

@safe:

class WebDeadLetterEntryModel {
    DeadLetterEntry[] items;
    DeadLetterEntry   selected;
    bool              hasSelected;
    string            errorMessage;
    string            successMessage;
    string            title;

    void setItems(DeadLetterEntry[] list) { items = list; errorMessage = ""; title = "Dead Letter Entries"; }

    void setSelected(DeadLetterEntry item, bool found) {
        selected     = item;
        hasSelected  = found;
        title        = found ? "Dead Letter Entry: " ~ item.id.value : "Not Found";
        errorMessage = found ? "" : "Dead letter entry not found";
    }

    void setError(string msg)   { errorMessage = msg; hasSelected = false; title = "Error"; }
    void setSuccess(string msg) { successMessage = msg; errorMessage = ""; }
}
