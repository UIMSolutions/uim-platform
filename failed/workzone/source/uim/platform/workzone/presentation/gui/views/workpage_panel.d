/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.gui.views.workpage_panel;

version (Have_gtkd):

import gtk.Box        : Box, Orientation;
import gtk.Label      : Label;
import gtk.ListBox    : ListBox, SelectionMode;
import gtk.ListBoxRow : ListBoxRow;
import gtk.Button     : Button;

import uim.platform.workzone.presentation.gui.models.workpage;

/// GTK view — shows the workpages of the currently selected workspace.
class WorkpagePanelView : Box {
    private WorkpageGuiModel _model;
    private ListBox          _listBox;
    private Label            _titleLabel;

    this(WorkpageGuiModel model) {
        super(Orientation.vertical, 0);
        _model = model;

        _titleLabel = new Label("Pages");
        _titleLabel.setMarkup(`<b>Pages</b>`);
        _titleLabel.setHalign(Label.Align.start);
        _titleLabel.setMarginStart(8);
        _titleLabel.setMarginTop(8);
        packStart(_titleLabel, false, false, 0);

        _listBox = new ListBox();
        _listBox.setSelectionMode(SelectionMode.single);
        packStart(_listBox, true, true, 0);

        _model.onChanged = () { rebuildList(); };
    }

    void loadWorkspace(string workspaceId) {
        _model.setWorkspace(workspaceId);
    }

    private void rebuildList() {
        foreach (child; _listBox.getChildren().toArray!ListBoxRow)
            _listBox.remove(child);

        foreach (i; 0 .. _model.count) {
            auto row   = new ListBoxRow();
            auto label = new Label(_model.titleAt(i));
            label.setHalign(Label.Align.start);
            label.setMarginStart(12);
            label.setMarginTop(4);
            label.setMarginBottom(4);
            row.add(label);
            _listBox.insert(row, -1);
        }
        _listBox.showAll();
    }
}
