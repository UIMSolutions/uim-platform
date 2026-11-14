/* global QUnit */
QUnit.config.autostart = false;
sap.ui.require(["uim/oauth/test/unit/formatter.qunit", "uim/oauth/test/unit/models.qunit"], function () {
  "use strict";
  QUnit.start();
});
