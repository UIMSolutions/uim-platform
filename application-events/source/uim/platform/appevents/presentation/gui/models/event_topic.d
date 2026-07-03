/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.gui.models.event_topic;

// import uim.platform.service;
// import uim.platform.appevents.domain.entities.event_topic;

import uim.platform.appevents;

// mixin(ShowModule!());

@safe:


class GuiEventTopicModel {
    private EventTopic[] _items;
    private EventTopic   _selected;
    private bool         _hasSelected;
    private string       _errorMessage;
    private string       _successMessage;

    void delegate() @safe onChanged;

    EventTopic[] items()         { return _items; }
    EventTopic   selected()      { return _selected; }
    bool         hasSelected()   { return _hasSelected; }
    string       errorMessage()  { return _errorMessage; }
    string       successMessage(){ return _successMessage; }

    void setItems(EventTopic[] list) {
        _items = list; _errorMessage = "";
        if (onChanged !is null) onChanged();
    }

    void setSelected(EventTopic item, bool found) {
        _selected    = item;
        _hasSelected = found;
        _errorMessage = found ? "" : "Event topic not found";
        if (onChanged !is null) onChanged();
    }

    void setError(string msg)   { _errorMessage = msg; _hasSelected = false; if (onChanged !is null) onChanged(); }
    void setSuccess(string msg) { _successMessage = msg; _errorMessage = ""; if (onChanged !is null) onChanged(); }
}
