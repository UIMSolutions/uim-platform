/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.gui.models.dead_letter_entry;

import uim.platform.service;
import uim.platform.appevents.domain.entities.dead_letter_entry;

@safe:

class GuiDeadLetterEntryModel {
    private DeadLetterEntry[] _items;
    private DeadLetterEntry   _selected;
    private bool              _hasSelected;
    private string            _errorMessage;
    private string            _successMessage;

    void delegate() @safe onChanged;

    DeadLetterEntry[] items()         { return _items; }
    DeadLetterEntry   selected()      { return _selected; }
    bool              hasSelected()   { return _hasSelected; }
    string            errorMessage()  { return _errorMessage; }
    string            successMessage(){ return _successMessage; }

    void setItems(DeadLetterEntry[] list) {
        _items = list; _errorMessage = "";
        if (onChanged !is null) onChanged();
    }

    void setSelected(DeadLetterEntry item, bool found) {
        _selected    = item;
        _hasSelected = found;
        _errorMessage = found ? "" : "Dead letter entry not found";
        if (onChanged !is null) onChanged();
    }

    void setError(string msg)   { _errorMessage = msg; _hasSelected = false; if (onChanged !is null) onChanged(); }
    void setSuccess(string msg) { _successMessage = msg; _errorMessage = ""; if (onChanged !is null) onChanged(); }
}
