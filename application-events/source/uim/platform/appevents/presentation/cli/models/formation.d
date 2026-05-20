/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.cli.models.formation;

import uim.platform.service;
import uim.platform.appevents.domain.entities.formation;

@safe:

class CliFormationModel {
    Formation[] items;
    Formation   selected;
    bool        hasSelected;
    string      errorMessage;
    string      successMessage;

    void setItems(Formation[] list) { items = list; errorMessage = ""; }

    void setSelected(Formation item, bool found) {
        selected    = item;
        hasSelected = found;
        errorMessage = found ? "" : "Formation not found";
    }

    void setError(string msg)   { errorMessage = msg; hasSelected = false; }
    void setSuccess(string msg) { successMessage = msg; errorMessage = ""; }
}
