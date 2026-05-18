/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.presentation.gui.models.business_user;

import gtk.ListStore;
import gobject.c.types : GType;

class BusinessUserGuiModel {
  private ListStore store;

  this() {
    store = new ListStore([GType.STRING, GType.STRING, GType.STRING, GType.STRING]);
  }

  ListStore listStore() { return store; }

  void clear() {
    store.clear();
  }
}
