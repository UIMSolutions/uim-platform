/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// OData v4 system query options: $filter, $orderby, $select, $top, $skip, $count, $search.
///
/// Supported $filter subset:
///   comparison  eq ne gt ge lt le        logical  and or not   grouping ( )
///   functions   contains startswith endswith (bool), tolower toupper (string)
///   literals    'string' (with '' escape), integers, decimals, true false null,
///               unquoted date/time values (2026-11-09T10:00:00Z) compared as strings
module uim.platform.translation.presentation.odata.query;

import std.ascii : isAlphaNum, isDigit, isWhite;
import std.uni : toLower, toUpper;
import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// Invalid query option — reported to the client as HTTP 400.
class ODataQueryException : Exception {
  this(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, file, line);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter AST
// ─────────────────────────────────────────────────────────────────────────────

abstract class FilterNode {
  abstract Json evaluate(Json row) const;
}

class LiteralNode : FilterNode {
  Json value;
  this(Json value) {
    this.value = value;
  }

  override Json evaluate(Json row) const {
    return value.clone;
  }
}

class PropertyNode : FilterNode {
  string name;
  this(string name) {
    this.name = name;
  }

  override Json evaluate(Json row) const {
    if (row.type != Json.Type.object)
      return Json(null);
    if (auto v = name in row)
      return *v;
    return Json(null);
  }
}

class NotNode : FilterNode {
  FilterNode operand;
  this(FilterNode operand) {
    this.operand = operand;
  }

  override Json evaluate(Json row) const {
    return Json(!truthy(operand.evaluate(row)));
  }
}

class BinaryNode : FilterNode {
  string op;
  FilterNode left, right;
  this(string op, FilterNode left, FilterNode right) {
    this.op = op;
    this.left = left;
    this.right = right;
  }

  override Json evaluate(Json row) const {
    if (op == "and")
      return Json(truthy(left.evaluate(row)) && truthy(right.evaluate(row)));
    if (op == "or")
      return Json(truthy(left.evaluate(row)) || truthy(right.evaluate(row)));

    auto l = left.evaluate(row);
    auto r = right.evaluate(row);
    if (op == "eq")
      return Json(equalJson(l, r));
    if (op == "ne")
      return Json(!equalJson(l, r));

    int c;
    if (!compareJson(l, r, c))
      return Json(false);
    switch (op) {
    case "gt":
      return Json(c > 0);
    case "ge":
      return Json(c >= 0);
    case "lt":
      return Json(c < 0);
    case "le":
      return Json(c <= 0);
    default:
      return Json(false);
    }
  }
}

class FunctionNode : FilterNode {
  string name;
  FilterNode[] args;
  this(string name, FilterNode[] args) {
    this.name = name;
    this.args = args;
  }

  override Json evaluate(Json row) const {
    string arg(size_t i) {
      auto v = args[i].evaluate(row);
      return v.type == Json.Type.string ? v.get!string : (v.type == Json.Type.null_ ? "" : v.toString);
    }

    switch (name) {
    case "contains":
      return Json(arg(0).toLower.canFind(arg(1).toLower));
    case "startswith":
      return Json(arg(0).startsWith(arg(1)));
    case "endswith":
      return Json(arg(0).endsWith(arg(1)));
    case "tolower":
      return Json(arg(0).toLower);
    case "toupper":
      return Json(arg(0).toUpper);
    default:
      return Json(null);
    }
  }
}

private enum string[] functionArity = ["contains:2", "startswith:2", "endswith:2", "tolower:1", "toupper:1"];

private size_t arityOf(string fn) {
  foreach (entry; functionArity) {
    auto parts = entry.split(":");
    if (parts[0] == fn)
      return parts[1].to!size_t;
  }
  return 0;
}

bool truthy(Json v) {
  return v.type == Json.Type.bool_ && v.get!bool;
}

bool isNumber(Json v) {
  return v.type == Json.Type.int_ || v.type == Json.Type.float_;
}

double asDouble(Json v) {
  return v.type == Json.Type.int_ ? cast(double) v.get!long : v.get!double;
}

bool equalJson(Json a, Json b) {
  if (a.type == Json.Type.null_ || b.type == Json.Type.null_ || a.type == Json.Type.undefined || b.type == Json.Type.undefined)
    return (a.type == Json.Type.null_ || a.type == Json.Type.undefined) && (b.type == Json.Type.null_ || b.type == Json.Type.undefined);
  int c;
  return compareJson(a, b, c) && c == 0;
}

/// Three-way comparison; returns false if the values are not comparable.
bool compareJson(Json a, Json b, out int result) {
  if (isNumber(a) && isNumber(b)) {
    auto x = asDouble(a), y = asDouble(b);
    result = x < y ? -1 : (x > y ? 1 : 0);
    return true;
  }
  if (a.type == Json.Type.string && b.type == Json.Type.string) {
    result = cmp(a.get!string, b.get!string);
    return true;
  }
  if (a.type == Json.Type.bool_ && b.type == Json.Type.bool_) {
    result = cast(int) a.get!bool - cast(int) b.get!bool;
    return true;
  }
  // numbers compared with numeric strings (e.g. Int64 as string)
  if (isNumber(a) && b.type == Json.Type.string || a.type == Json.Type.string && isNumber(b)) {
    try {
      auto x = isNumber(a) ? asDouble(a) : a.get!string.to!double;
      auto y = isNumber(b) ? asDouble(b) : b.get!string.to!double;
      result = x < y ? -1 : (x > y ? 1 : 0);
      return true;
    } catch (Exception) {
      return false;
    }
  }
  return false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter parser (recursive descent)
// ─────────────────────────────────────────────────────────────────────────────

private struct Token {
  enum Kind {
    word,
    str,
    open,
    close,
    comma,
    end
  }

  Kind kind;
  string text;
}

private Token[] tokenize(string input) {
  Token[] tokens;
  size_t i = 0;
  while (i < input.length) {
    auto c = input[i];
    if (isWhite(c)) {
      i++;
      continue;
    }
    if (c == '(') {
      tokens ~= Token(Token.Kind.open, "(");
      i++;
    } else if (c == ')') {
      tokens ~= Token(Token.Kind.close, ")");
      i++;
    } else if (c == ',') {
      tokens ~= Token(Token.Kind.comma, ",");
      i++;
    } else if (c == '\'') {
      string value;
      i++;
      bool closed;
      while (i < input.length) {
        if (input[i] == '\'') {
          if (i + 1 < input.length && input[i + 1] == '\'') {
            value ~= '\'';
            i += 2;
            continue;
          }
          closed = true;
          i++;
          break;
        }
        value ~= input[i];
        i++;
      }
      if (!closed)
        throw new ODataQueryException("Unterminated string literal in $filter");
      tokens ~= Token(Token.Kind.str, value);
    } else if (isAlphaNum(c) || c == '_' || c == '-' || c == '.' || c == ':' || c == '+') {
      auto start = i;
      while (i < input.length && (isAlphaNum(input[i]) || input[i] == '_' || input[i] == '-'
          || input[i] == '.' || input[i] == ':' || input[i] == '+'))
        i++;
      tokens ~= Token(Token.Kind.word, input[start .. i]);
    } else {
      throw new ODataQueryException("Unexpected character '" ~ c ~ "' in $filter");
    }
  }
  tokens ~= Token(Token.Kind.end, "");
  return tokens;
}

private struct FilterParser {
  Token[] tokens;
  size_t pos;
  const(string)[] properties;

  Token peek() {
    return tokens[pos];
  }

  Token next() {
    return tokens[pos++];
  }

  bool isKeyword(string word) {
    return peek().kind == Token.Kind.word && peek().text == word;
  }

  void expect(Token.Kind kind, string what) {
    if (peek().kind != kind)
      throw new ODataQueryException("Expected " ~ what ~ " in $filter near '" ~ peek().text ~ "'");
    pos++;
  }

  FilterNode parse() {
    auto node = parseOr();
    if (peek().kind != Token.Kind.end)
      throw new ODataQueryException("Unexpected '" ~ peek().text ~ "' in $filter");
    return node;
  }

  FilterNode parseOr() {
    auto left = parseAnd();
    while (isKeyword("or")) {
      next();
      left = new BinaryNode("or", left, parseAnd());
    }
    return left;
  }

  FilterNode parseAnd() {
    auto left = parseNot();
    while (isKeyword("and")) {
      next();
      left = new BinaryNode("and", left, parseNot());
    }
    return left;
  }

  FilterNode parseNot() {
    if (isKeyword("not")) {
      next();
      return new NotNode(parseNot());
    }
    return parseComparison();
  }

  FilterNode parseComparison() {
    auto left = parseOperand();
    if (peek().kind == Token.Kind.word && ["eq", "ne", "gt", "ge", "lt", "le"].canFind(peek().text)) {
      auto op = next().text;
      return new BinaryNode(op, left, parseOperand());
    }
    return left;
  }

  FilterNode parseOperand() {
    auto t = peek();
    if (t.kind == Token.Kind.open) {
      next();
      auto inner = parseOr();
      expect(Token.Kind.close, "')'");
      return inner;
    }
    if (t.kind == Token.Kind.str) {
      next();
      return new LiteralNode(Json(t.text));
    }
    if (t.kind != Token.Kind.word)
      throw new ODataQueryException("Unexpected '" ~ t.text ~ "' in $filter");

    next();
    auto word = t.text;

    // function call
    if (peek().kind == Token.Kind.open) {
      auto fn = word.toLower;
      auto arity = arityOf(fn);
      if (arity == 0)
        throw new ODataQueryException("Unsupported function '" ~ word ~ "' in $filter");
      next();
      FilterNode[] args;
      while (true) {
        args ~= parseOr();
        if (peek().kind == Token.Kind.comma) {
          next();
          continue;
        }
        expect(Token.Kind.close, "')'");
        break;
      }
      if (args.length != arity)
        throw new ODataQueryException("Function '" ~ word ~ "' expects " ~ arity.to!string ~ " arguments");
      return new FunctionNode(fn, args);
    }

    switch (word) {
    case "true":
      return new LiteralNode(Json(true));
    case "false":
      return new LiteralNode(Json(false));
    case "null":
      return new LiteralNode(Json(null));
    default:
      break;
    }

    if (isDigit(word[0]) || (word.length > 1 && word[0] == '-' && isDigit(word[1]))) {
      try
        return new LiteralNode(Json(word.to!long));
      catch (Exception) {
      }
      try
        return new LiteralNode(Json(word.to!double));
      catch (Exception) {
      }
      return new LiteralNode(Json(word)); // date / time literal
    }

    if (properties.length > 0 && !properties.canFind(word))
      throw new ODataQueryException("Unknown property '" ~ word ~ "' in $filter");
    return new PropertyNode(word);
  }
}

/// Parse a $filter expression. If properties is non-empty, property names are validated.
FilterNode parseFilter(string expression, const(string)[] properties = null) {
  auto parser = FilterParser(tokenize(expression), 0, properties);
  return parser.parse();
}

// ─────────────────────────────────────────────────────────────────────────────
// System query options
// ─────────────────────────────────────────────────────────────────────────────

struct OrderByItem {
  string property;
  bool descending;
}

struct ODataQuery {
  size_t skip;
  size_t top = size_t.max;
  FilterNode filter;
  OrderByItem[] orderBy;
  string[] select;
  bool count;
  string search;

  /// Apply all options to a list of serialized entities.
  /// Returns the page; totalCount receives the count after $filter/$search.
  Json[] apply(Json[] rows, out size_t totalCount) const {
    Json[] result;
    foreach (row; rows) {
      if (filter !is null && !truthy(filter.evaluate(row)))
        continue;
      if (search.length > 0 && !matchesSearch(row, search))
        continue;
      result ~= row;
    }
    totalCount = result.length;

    if (orderBy.length > 0) {
      auto order = orderBy.dup;
      result.sort!((a, b) {
        foreach (o; order) {
          int c;
          auto av = o.property in a ? a[o.property] : Json(null);
          auto bv = o.property in b ? b[o.property] : Json(null);
          if (!compareJson(av, bv, c))
            c = (av.type == Json.Type.null_ ? -1 : 0) - (bv.type == Json.Type.null_ ? -1 : 0);
          if (c != 0)
            return o.descending ? c > 0 : c < 0;
        }
        return false;
      });
    }

    if (skip >= result.length)
      return null;
    result = result[skip .. $];
    if (top < result.length)
      result = result[0 .. top];

    if (select.length > 0) {
      Json[] projected;
      foreach (row; result) {
        auto p = Json.emptyObject;
        foreach (name; select)
          if (name in row)
            p[name] = row[name];
        projected ~= p;
      }
      result = projected;
    }
    return result;
  }
}

private bool matchesSearch(Json row, string term) {
  auto needle = term.toLower;
  foreach (key, value; row.get!(Json[string]))
    if (value.type == Json.Type.string && value.get!string.toLower.canFind(needle))
      return true;
  return false;
}

/// Parse the system query options from the request's query parameters.
/// get(name) must return "" for missing parameters.
ODataQuery parseQuery(scope string delegate(string) @safe get, const(string)[] properties, string key) {
  ODataQuery q;

  size_t parseCount(string name, string raw) {
    try
      return raw.to!size_t;
    catch (Exception)
      throw new ODataQueryException("Invalid value for " ~ name ~ ": " ~ raw);
  }

  void checkProperty(string option, string name) {
    if (properties.length > 0 && !properties.canFind(name))
      throw new ODataQueryException("Unknown property '" ~ name ~ "' in " ~ option);
  }

  auto top = get("$top");
  if (top.length > 0)
    q.top = parseCount("$top", top);
  auto skip = get("$skip");
  if (skip.length > 0)
    q.skip = parseCount("$skip", skip);

  auto filter = get("$filter");
  if (filter.length > 0)
    q.filter = parseFilter(filter, properties);

  auto orderBy = get("$orderby");
  foreach (part; orderBy.split(",")) {
    auto words = part.strip.split!isWhite.filter!(w => w.length > 0).array;
    if (words.length == 0)
      continue;
    checkProperty("$orderby", words[0]);
    bool desc = words.length > 1 && words[1].toLower == "desc";
    q.orderBy ~= OrderByItem(words[0], desc);
  }

  auto select = get("$select");
  if (select.length > 0 && select != "*") {
    foreach (name; select.split(",").map!(s => s.strip).filter!(s => s.length > 0)) {
      checkProperty("$select", name);
      q.select ~= name;
    }
    if (key.length > 0 && !q.select.canFind(key))
      q.select ~= key;
  }

  q.count = get("$count").toLower == "true";
  q.search = get("$search").strip.strip("\"");
  return q;
}

///
unittest {
  mixin(ShowTest!("ODataQuery"));

  Json row(string id, string cat, long n, string msg) {
    auto r = Json.emptyObject;
    r["id"] = id;
    r["category"] = cat;
    r["n"] = n;
    r["message"] = msg;
    return r;
  }

  auto rows = [row("1", "dataAccess", 3, "Read profile"), row("2", "configuration", 1, "Changed IdP"),
    row("3", "dataAccess", 2, "Read payroll")];
  auto props = ["id", "category", "n", "message"];

  size_t total;
  auto f = parseFilter("category eq 'dataAccess' and n ge 3", props);
  assert(truthy(f.evaluate(rows[0])));
  assert(!truthy(f.evaluate(rows[2])));

  assert(truthy(parseFilter("contains(message,'PAYROLL')", props).evaluate(rows[2])));
  assert(truthy(parseFilter("not (n lt 2) or startswith(id,'2')", props).evaluate(rows[1])));
  assert(truthy(parseFilter("message eq 'It''s'", props).evaluate(row("4", "", 0, "It's"))));

  bool failed;
  try parseFilter("unknown eq 1", props);
  catch (ODataQueryException) failed = true;
  assert(failed);

  string[string] params = ["$filter": "category eq 'dataAccess'", "$orderby": "n desc", "$top": "1", "$select": "message"];
  auto q = parseQuery((name) => params.get(name, ""), props, "id");
  auto page = q.apply(rows, total);
  assert(total == 2);
  assert(page.length == 1);
  assert(page[0]["message"].get!string == "Read profile");
  assert("id" in page[0] && "category" !in page[0]);

  string[string] search = ["$search": "payroll"];
  assert(parseQuery((name) => search.get(name, ""), props, "id").apply(rows, total).length == 1);
}
