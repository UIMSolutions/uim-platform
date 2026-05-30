/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.gui.views.task_view;

version (Have_gtkd):

import gtk.Box        : Box, Orientation;
import gtk.Button     : Button;
import gtk.Label      : Label;
import gtk.ListBox    : ListBox, SelectionMode;
import gtk.ListBoxRow : ListBoxRow;
import gtk.Image      : Image;

import uim.platform.workzone.presentation.gui.models.task;
import uim.platform.workzone;

/// GTK view — displays the task inbox for the current user.
class TaskInboxView : Box {
    private TaskGuiModel _model;
    private ListBox      _listBox;
    private Label        _summaryLabel;

    this(TaskGuiModel model) {
        super(Orientation.vertical, 0);
        _model = model;

        // Summary bar
        _summaryLabel = new Label("Tasks");
        _summaryLabel.setHalign(Label.Align.start);
        _summaryLabel.setMarginStart(12);
        _summaryLabel.setMarginTop(8);
        packStart(_summaryLabel, false, false, 0);

        // Refresh button
        auto btnRefresh = new Button("Refresh");
        btnRefresh.addOnClicked((_) { _model.refresh(); });
        btnRefresh.setHalign(Button.Align.end);
        btnRefresh.setMarginEnd(8);
        btnRefresh.setMarginTop(4);
        packStart(btnRefresh, false, false, 0);

        // Task list
        _listBox = new ListBox();
        _listBox.setSelectionMode(SelectionMode.single);
        packStart(_listBox, true, true, 0);

        _model.onChanged = () { rebuildList(); };
    }

    private void rebuildList() {
        foreach (child; _listBox.getChildren().toArray!ListBoxRow)
            _listBox.remove(child);

        immutable overdue = _model.overdueCount();
        
        _summaryLabel.setText(
            _model.count.to!string ~ " task(s)" ~
            (overdue > 0 ? "  ⚠ " ~ overdue.to!string ~ " overdue" : "")
        );

        foreach (i; 0 .. _model.count) {
            auto row = new ListBoxRow();
            auto hbox = new Box(Orientation.horizontal, 8);
            hbox.setMarginStart(12);
            hbox.setMarginTop(6);
            hbox.setMarginBottom(6);

            auto titleLabel  = new Label(_model.titleAt(i));
            titleLabel.setHalign(Label.Align.start);
            titleLabel.setHexpand(true);

            auto statusLabel = new Label(_model.statusAt(i));
            statusLabel.setMarginEnd(8);

            auto btnComplete = new Button("✓");
            btnComplete.setSensitive(_model.statusAt(i) != "completed");
            immutable taskIndex = i;
            btnComplete.addOnClicked((_) {
                immutable id = (cast(const) _model.items)[taskIndex].id.value;
                _model.completeTask(id);
            });

            hbox.packStart(titleLabel,  true,  true,  0);
            hbox.packStart(statusLabel, false, false, 0);
            hbox.packStart(btnComplete, false, false, 0);

            row.add(hbox);
            _listBox.insert(row, -1);
        }
        _listBox.showAll();
    }
}
