/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_directory.presentation.gui.views.dashboard;

import uim.platform.identity_directory.presentation.gui.models.dashboard;

version (Have_gtkd):

import gtk.Application : Application;
import gtk.ApplicationWindow : ApplicationWindow;
import gtk.Box : Box, Orientation;
import gtk.HeaderBar : HeaderBar;
import gtk.Label : Label;
import gtk.ScrolledWindow : ScrolledWindow;
import gtk.Stack : Stack;
import gtk.StackSwitcher : StackSwitcher;
import gtk.TextView : TextView;

final class IdentityDirectoryGuiWindow : ApplicationWindow {
    private Stack contentStack;

    this(Application app, GuiPageModel dashboard, GuiPageModel[] pages) {
        super(app);
        setTitle("Identity Directory");
        setDefaultSize(1280, 860);

        auto root = new Box(Orientation.vertical, 0);
        auto header = new HeaderBar();
        auto switcher = new StackSwitcher();

        header.setShowCloseButton(true);
        header.setTitle("Identity Directory");
        header.setCustomTitle(switcher);
        setTitlebar(header);

        contentStack = new Stack();
        switcher.setStack(contentStack);

        contentStack.addTitled(buildPage(dashboard), dashboard.pageId, dashboard.title);
        foreach (page; pages) {
            contentStack.addTitled(buildPage(page), page.pageId, page.title);
        }

        root.packStart(contentStack, true, true, 0);
        add(root);
        showAll();
    }

    private ScrolledWindow buildPage(GuiPageModel model) {
        auto scrolled = new ScrolledWindow();
        auto view = new TextView();
        view.setEditable(false);
        view.getBuffer().setText(renderPageText(model));
        scrolled.add(view);
        return scrolled;
    }
}
