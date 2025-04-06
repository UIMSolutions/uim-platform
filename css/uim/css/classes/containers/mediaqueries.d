/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.css.classes.containers.mediaqueries;

import uim.css;

@safe:

class DCSSMediaQueries {
  this() {
    _queries["default"] = CSSMediaQuery;
  }

  protected DCSSMediaQuery[string] _queries;

  auto query(string queryName = null) {
    return queryName
      ? _queries.get(queryName, null) : _queries.get("default", null);
  }

  unittest {
    /// TODO
  }

  O query(this O)(string queryName, string condition) {
    if (!_queries.hasKey(queryName))
      _queries[queryName] = CSSMediaQuery(condition);
    return cast(O) this;
  }

  version (test_uim_css) {
    unittest {
      /// TODO
    }
  }

  auto rule(this O)(string ruleName) {
    return query("default").rule(ruleName, properties);
  }

  version (test_uim_css) {
    unittest {
      /// TODO
    }
  }

  O rule(this O)(string name, string properties) {
    query("default").rule(name, properties);
    return cast(O) this;
  }

  version (test_uim_css) {
    unittest {
      /// TODO
    }
  }

  O rule(this O)(string queryName, string ruleName, string properties) {
    if (_queries.hasKey(queryName))
      _queries[query].rule(ruleName, properties);
    return cast(O) this;
  }

  version (test_uim_css) {
    unittest {
      /// TODO
    }
  }

  O removeRule(this O)(string name) {
    _queries["default"].removeRule(name);
    return cast(O) this;
  }

  version (test_uim_css) {
    unittest {
      /// TODO
    }
  }

  O removeRule(this O)(string queryName, string ruleName) {
    if (_queries.hasKey(queryName))
      _queries[queryName].removeRule(ruleName);
    return cast(O) this;
  }

  version (test_uim_css) {
    unittest {
      /// TODO
    }
  }

  override string toString() {
    return _queries.byValue
      .filter!(query => query !is null)
      .map!(query => query.toString)
      .join;
  }

  unittest {
    /// TODO
  }

  string toString(string[] queryNames) {
    return _queries.byValue
      .map!(query => query.toString).join;
  }

  unittest {
    /// TODO
  }
}

auto CSSMediaQueries() {
  return new DCSSMediaQueries;
}
