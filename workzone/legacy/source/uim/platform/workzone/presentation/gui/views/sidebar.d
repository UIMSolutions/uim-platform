/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.gui.views.sidebar;

version (Have_gtkd):

import gtk.Box        : Box, Orientation;
import gtk.Button     : Button;
import gtk.Label      : Label;
import gtk.Stack      : Stack;
import gtk.Separator  : Separator;
import pango.PgFontDescription : PgFontDescription;

/// Navigation sidebar showing section buttons that switch the content stack.
class SidebarView : Box {
    private Stack _stack;

    this(Stack stack) {
        super(Orientation.vertical, 0);
        _stack = stack;

        setName("sidebar");
        setSizeRequest(180, -1);

        // Title label
        auto titleLabel = new Label("WorkZone");
        titleLabel.setMarkup(`<b>&#x25A3; WorkZone</b>`);
        titleLabel.setMarginTop(16);
        titleLabel.setMarginBottom(8);
        packStart(titleLabel, false, false, 0);

        packStart(new Separator(Orientation.horizontal), false, false, 4);

        addNavButton("workspaces", "Workspaces");
        addNavButton("tasks",      "My Tasks");
    }

    private void addNavButton(string stackId, string label) {
        auto btn = new Button(label);
        btn.setRelief(Button.ReliefStyle.none);
        btn.setHalign(Button.Align.start);
        btn.setMarginStart(8);
        btn.addOnClicked((_) { _stack.setVisibleChildName(stackId); });
        packStart(btn, false, false, 2);
    }
}
