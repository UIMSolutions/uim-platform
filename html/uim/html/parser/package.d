/****************************************************************************************************************
* Copyright: © 2018-2025 Ozan Nurettin Süel (aka UIManufaktur)                                                  *
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *
* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *
*****************************************************************************************************************/
module uim.html.parser;

import uim.html;

@safe:

size_t[] posOfAll(string text, string searchTxt) {
  size_t[] results;

  if (searchTxt.length > 0) {
    size_t currentPos = 0;
    while ((currentPos < text.length) && (currentPos >= 0)) {
      currentPos = text.indexOf(searchTxt, currentPos); // looking for first or next pos
      if (currentPos == -1)
        break; // not found

      results ~= currentPos; // found pos and add to results      
      currentPos += searchTxt.length;
    }
  }

  return results;
}

size_t[] posOfAll(string text, string searchTxt, size_t startPos, size_t endPos) {
  size_t[] results;

  if (searchTxt.length > 0) {
    size_t currentPos = startPos;
    while ((currentPos < endPos) && (currentPos >= 0)) {
      currentPos = text.indexOf(searchTxt, currentPos); // looking for first or next pos
      if (currentPos == -1)
        break; // not found

      if (currentPos < endPos)
        results ~= currentPos; // found pos and add to results      
      currentPos += searchTxt.length;
    }
  }

  return results;
}

version (test_uim_html) {
  unittest {
    writeln("x x x x".posOfAll(" ", 2, 6));
    // assert("x x x x".posOfAll(" ", 2, 6) == [3, 5]);
  }
}

string fillWith(string txt, string addTxt, size_t startPos, size_t endPos) {
  string result = txt;

  for (size_t i = startPos; (i < endPos) && (i < result.length); i++) {
    result = result[0 .. i] ~ addTxt ~ result[i + addTxt.length .. $];
  }

  return result;
}

class DH5Node {
  string txt;
  bool isRoot = true;
  bool isContent = false;
  bool isStartTag = false;
  bool isEndTag = false;
  bool hasEndTag = true;
  size_t startPos;
  size_t startEnd;

  string _tag;
  size_t level;
  DH5Node[] nodes;
  DH5Node rootNode;

  string _id;
  string[] _classes;
  STRINGAA _attributes;

  this() {
  }

  this(DH5Node myRoot) {
    this();
    rootNode = myRoot;
  }

  this(string myTagName) {
    this();
    tag = myTagName;
  }

  this(DH5Node myRoot, string myTagName) {
    this();
    rootNode = myRoot;
    tag = myTagName;
  }

  @property auto tag() {
    return _tag;
  }

  @property void tag(string newTag) {
    _tag = newTag.strip;
  }

  string tagToH5() {
    return `H5%s`.format(capitalize(_tag));
  }

  @property auto id() {
    return _id;
  }

  @property void id(string newId) {
    _id = newId.strip;
  }

  string idToH5() {
    return `"%s"`.format(_id);
  }

  @property auto classes() {
    return _classes;
  }

  @property void classes(string newClasses) {
    auto items = newClasses.split(" ");
    foreach (ref item; items) {
      item = item.strip;
    }

    _classes = items.filter!(item => item.length > 0)
      .map!(item => item)
      .array;
  }

  string classesToH5() {
    return !_classes.isEmpty
      ? "[%s]".format(_classes.map!(cl => `"%s"`.format(cl)).join(", ")) : null;
  }

  @property auto attributes() {
    return _attributes;
  }

  @property void attributes(string[string] newAttributes) {
    _attributes = newAttributes;
    if ("id" in _attributes) {
      id = _attributes.shift("id");
    }
    if ("class" in _attributes) {
      classes = _attributes.shift("class");
    }
  }

  string attributesToH5() {
    string[] results;
    return "[" ~
      _attributes.byKeyValue
      .filter!(attribute => attribute.key.length > 0)
      .map!(attribute => `"%s":%s`.format(attribute.key, (attribute.value.indexOf(`"`) > -1 ? attribute.value
          : `"` ~ attribute.value ~ `"`)))
      .join(",")
      ~ "]";
  }

  void setNodes(DH5Node[] newNodes) {
    auto min = minLevel(newNodes); // writeln("MinLevel = ", min, " --------------");

    // TODO newNodes.each!(node => writeln("%s - %s ".format(node.level, node).indent(node.level * 2)));

    DH5Node[] nodes = null;
    DH5Node levelNode;
    DH5Node[] subNodes;
    newNodes.each!(
      node => setNode(node, levelNode, nodes, subNodes));
  }

  void setNode(DH5Node newNode, DH5Node levelNode, DH5Node[] nodes, DH5Node[] subNodes) {
    if (newNode.level == minLevel(nodes)) {
      if (newNode.isContent || (newNode.isStartTag && newNode.isEndTag)) { // single node
        nodes ~= newNode;
      } else if (newNode.isStartTag) { // start dode 
        levelNode = newNode;
      } else if (newNode.isEndTag) { // end Node
        levelNode.setNodes(subNodes);
        nodes ~= levelNode;
      }
      subNodes = null;
    } else {
      subNodes ~= newNode;
    }
  }

  DH5Obj[] toH5() {
    if (isRoot)
      return nodes.map!(node => node.toH5).join;
    if (isContent)
      return [H5String(txt)];
    return isStartTag && isEndTag
      ? [H5Obj(_attributes)
        .tag(tag)
        .single(true)] : [
        H5Obj(_attributes).tag(tag).content(nodes.toH5)
      ];
  }

  string toH5String() {
    if (isRoot)
      return nodes.toH5String;
    if (isContent)
      return `"` ~ txt ~ `"`;
    string[] tagContent;
    if (id.length > 0)
      tagContent ~= idToH5;
    if (classes.length > 0)
      tagContent ~= classesToH5;
    if (attributes.length > 0)
      tagContent ~= attributesToH5; // writeln(tagContent);
    if (isStartTag && isEndTag)
      return "H5%s(%s)".format(tag.capitalize, tagContent.join(","));

    if (nodes.length > 0)
      tagContent ~= nodes.toH5String;
    return "H5%s(%s)".format(tag.capitalize, tagContent
        .join(","));
  }
}

auto H5Node() {
  return new DH5Node;
}

auto H5Node(DH5Node myRoot) {
  return new DH5Node(myRoot);
}

auto H5Node(string myTagName) {
  return new DH5Node(myTagName);
}

auto H5Node(DH5Node myRoot, string myTagName) {
  return new DH5Node(myRoot, myTagName);
}

DH5Obj[] toH5(DH5Node[] nodes) {
  return nodes.map!(node => node.toH5).join;
}

auto toH5String(DH5Node[] nodes) {
  return nodes.map!(node => node.toH5String).join(",");
}

size_t minLevel(DH5Node[] newNodes) {
  if (newNodes.isEmpty) {
    return -1;
  }
  if (newNodes.length == 1) {
    return newNodes[0].level;
  }

  size_t result = newNodes[0].level;
  newNodes[1 .. $].each!(
    node => result = min(node.level, result));
  return result;
}

/* DH5Node parse(string html) {
  DH5Node rootNode = H5Node(html);

  auto level1Items = html.replace("\n", "").split("<")[1 ..$];
  foreach (ref item; level1Items)
    item = "<" ~ item;

  string[] level2Items;
  foreach (ref item; level1Items) {
    auto items = item.split(">");
    foreach (ref it; items)
    {
      if (it.strip.isEmpty)
        continue;
      if (it.indexOf("<") > -1)
        level2Items ~= it ~ ">";
      else
        level2Items ~= it;
    }
  }

  DH5Node[] newNodes;
  foreach (value; level2Items) {
    DH5Node node;
    auto v = value.strip.toLower;
    if (v.indexOf("<") == -1)
      node.isContent = true;
    else if (v.indexOf("</") > -1)
      node.isEndTag = true;
    else
    {
      node.isStartTag = true;
      if (v.indexOf("/>") > -1)
        node.isEndTag = true;
      if (v.indexOf("< ") > -1)
        node.isEndTag = true;
      if (v.indexOf("<!doctype") > -1)
        node.isEndTag = true;
      if (v.indexOf("<img") > -1)
        node.isEndTag = true;
      if (v.indexOf("<br") > -1)
        node.isEndTag = true;
      if (v.indexOf("<meta") > -1)
        node.isEndTag = true;
      if (v.indexOf("<link") > -1)
        node.isEndTag = true;
    }
    if (node.isStartTag || node.isEndTag || node.isContent)
      node.isRoot = false;
    node.txt = value;

    if (node.isStartTag)
    {
      // <xxx> -> xxx / <xxx a="b"> -> xxx a="b"
      node.tag = node.txt.strip.replace("<", "").replace(">", "").split(" ")[0];
      // if ()
      auto atts = node.txt.strip.replace("<", "").replace(">", "").split(" ");
/*      if (atts.length > 1)
        foreach (a; atts[1 ..$])  node.attribute(a);
 * /    }
    else if (node.isEndTag)
      node.tag = node.txt.strip.replace("</", "").replace(">", "");

    newNodes ~= node;
  }

  int counter = 0;
  foreach (ref node; newNodes) {
    if (node.isContent)
    {
      node.level = counter;
      continue;
    }
    else if ((node.isStartTag) && (node.isEndTag))
    {
      node.level = counter;
      continue;
    }
    else if (node.isStartTag)
    {
      node.level = counter;
      counter++;
      continue;
    }
    else if (node.isEndTag)
    {
      counter--;
      node.level = counter;
      continue;
    }
  }

  rootNode.setNodes(newNodes);
  return rootNode;
}

unittest
{
  // // writeln(DH5Node(`<thead><tr><th width="1%">Product</th><th>Quantity</th><th>Price</th></tr><tr><th width="1%">Product</th><th>Quantity</th><th>Price</th></tr></thead>`));
  // // writeln(DH5Node(`<tr><th width="1%">Product</th><th>Quantity</th><th>Price</th></tr><tr><th width="1%">Product</th><th>Quantity</th><th>Price</th></tr>`));
  //// writeln(DH5Node(`<thead><tr><th width="1%">Product</th><th>Quantity</th><th>Price</th></tr><tr><th width="1%">Product</th><th>Quantity</th><th>Price</th></tr></thead>`).toH5.toPretty);

}
*/
auto parse2(string html) {
  auto startComment = "<!--";
  auto endComment = "-->";

  // Step 0: Delete End of Lines
  auto hLines = html.split("\n");
  string[] newLines;
  foreach (ref line; hLines) {
    line = line.strip;
    if (line.length > 0)
      newLines ~= line;
  }
  auto htmlBase = newLines.join(""); // Step 1: Cut out comments
  debug writeln("Step 1: Cut out comments");
  size_t commentPos;
  while (htmlBase.indexOf(startComment, commentPos) > -1) { // has comment <!--
    auto startCPos = htmlBase.indexOf(startComment, commentPos);
    if (htmlBase.indexOf(endComment, startCPos + startComment
        .length) > -1) {
      auto endCPos = htmlBase.indexOf(endComment, startCPos + startComment
          .length);
      htmlBase = htmlBase[0 .. startCPos] ~ htmlBase[endCPos + endComment
        .length .. $];
    } else {
      htmlBase = htmlBase[0 .. startCPos];
      break;
    }
    commentPos = startCPos;
  }

  // Step 2: Read quotes
  string htmlMask = htmlBase;
  debug writeln(
    "Step 2: Read quotes");
  writeln("1");
  htmlMask = htmlMask.replace(`\"`, "ss"); // Replace "false" quotes with chars;
  writeln("2");
  auto stringIndicators = htmlMask.posOfAll(
    `"`); // Now we have all quotes
  writeln("3");
  for (size_t i = 0; i < stringIndicators.length - 1; i += 2) {
    htmlMask = htmlMask.fillWith("s", stringIndicators[i] + 1, stringIndicators[i + 1]);
  }

  // Step 3: Looking for tag limiter every < has a > if well-formed
  debug writeln("Step 3: Looking for tag limiter");
  auto ltIndicators = htmlMask.posOfAll(`<`); // All <
  auto gtIndicators = htmlMask.posOfAll(`>`); // All >

  // Step 4: Set Nodes and level 
  DH5Node[] nodes;
  DH5Node rootNode = H5Node;
  size_t[string] tagLevels;
  size_t level;
  DH5Node fokusNode;
  foreach (index, value; ltIndicators) {
    DH5Node node = H5Node(rootNode);
    node.isRoot = false;
    if (
      index >= gtIndicators.length) { // Not well-formed :-(
      break;
    }

    string tag = htmlMask[ltIndicators[index] .. gtIndicators[index] + 1]; // Should be <tag> or </tag> or <tag/>
    auto tagSpaces = posOfAll(htmlMask, " ", ltIndicators[index], gtIndicators[index] - 1);
    writeln("tag;", tag);
    writeln(tagSpaces);

    auto spacesSeparated = tag.split(" "); // separate in spaces if exists 
    auto tagName = "";
    node.level = level;
    if (tag.indexOf("</") == 0) { // is EndTag
      node.isEndTag = true;
      tagName = spacesSeparated[0].replace(
        "</", "").replace(">", "").strip;
      rootNode = rootNode.rootNode;
      if (level > 0)
        level--;
    } else {
      node.isStartTag = true;
      tagName = spacesSeparated[0].replace(
        "<", "").replace(">", "").strip;
      switch (tagName) {
      case "link", "meta", "img", "input", "br":
        rootNode.nodes ~= node;
        break; // same level
      default:
        rootNode.nodes ~= node;
        rootNode = node;
        level++;
        break;
      }

      string[] parameters;
      STRINGAA attributes;
      if (tagSpaces) {
        writeln("T:", htmlBase[ltIndicators[index] + 1 .. tagSpaces[0]]);
        for (size_t spaceI = 0; spaceI < tagSpaces.length - 1; spaceI += 2) {
          parameters ~= htmlBase[tagSpaces[spaceI] .. tagSpaces[spaceI + 1]]
            .strip;
        }
        parameters ~= htmlBase[tagSpaces[-1] .. gtIndicators[index]]
          .strip;
        writeln(parameters);

        foreach (para; parameters) {
          if (para.indexOf("=") == -1) {
            attributes[para] = para;
          } else {
            auto pos = para.indexOf(
              "=");
            attributes[para[0 .. pos]] = para[pos + 2 .. -1];
          }
        }
        writeln(attributes);
        if ("id" in attributes) {
          node.id(attributes["id"]);
          attributes.removeKey(
            "id");
        }
        if ("class" in attributes) {
          node.classes(
            attributes["class"]);
          attributes.removeKey(
            "class");
        }
        node.attributes = attributes;
      }
      node.level = level;
    }
    node.tag(tagName);
    if ((index < gtIndicators.length) && (
        index < ltIndicators.length - 1)) {
      auto content = htmlBase[gtIndicators[index] + 1 .. ltIndicators[index + 1]];
      if (content) {
        DH5Node sNode = H5Node(rootNode);
        sNode.isRoot = false;
        sNode.isContent = true;
        sNode.txt = content;
        sNode.level = level;

        rootNode.nodes ~= sNode;
      }
    }
  }

  return rootNode;
}

unittest {
  /*  // writeln(`<tag a d>`);
  // writeln(parse2(`<tag a d>`));
  // writeln(`<tag a="b" d="c">`);
  // writeln(parse2(`<tag a="b" d="c">`));
  // writeln(`<tag>`);
  // writeln(parse2(`<tag>`));
 */
  // auto nodes = parse2(readText("html.txt"));
  // writeln(nodeToH5(nodes.nodes,0));

  // auto f = File("h5.txt", "w"); // open for writing
  // f.write(nodeToH5(nodes.nodes,0));
}

void writelnNodes(DH5Node[] nodes) {
  foreach (node; nodes) {
    // writeln(mul("    ", node.level), "\t", node.level, ":", node.tagToH5, "(", "H5String(\"" ~ node.txt.strip ~ "\")");
    if (node.nodes)
      writelnNodes(node.nodes);
  }
}

string intender(string txt, size_t multiple, size_t step = 2) {
  string result = txt;
  for (auto i = 0; i < multiple * step; i++)
    result = " " ~ result;

  return result;
}

string nodeToH5(DH5Node[] nodes, size_t level) {
  string[] results;

  if ((nodes.length == 1) && nodes[0]
    .isContent) {
    results ~= ((nodes[0].txt.length > 0) ? "\"%s\""
        .format(nodes[0].txt) : "");
    nodes = null;
  } else {
    foreach (node; nodes) {
      auto result = node.isContent && node.txt.length > 0
        ? nodeToH5(node, level) : nodeToH5(node, level);

      if (result.length > 0)
        results ~= intender("\n" ~ result, level);
    }
  }
  return results.join(",").replace(",)", ")")
    .replace(",]", "]").replace("\"\",", ",");
  /*  auto xxxLines = xxx.split("\n"); 
  string[] newLines;
  foreach(line; xxxLines) if (line.strip.length > 0) newLines ~= line; // use only not empty lines
  return newLines.join("\n");
 */
}

string nodeToH5(DH5Node node, size_t level) {
  string result;
  if (node.isStartTag) {
    string[] vals;
    if (
      node.id.strip.length > 0)
      vals ~= node.idToH5;
    if (node.classes.length > 0)
      vals ~= node
        .classesToH5;
    if (
      node.attributes) {
      string[] ats = node.attributes.byKeyValue
        .map!(kv => "\"%s\":\"%s\"".format(
            kv.key.strip, kv.value
            .strip)).array;
      if (ats)
        vals ~= "[" ~ ats.join(
          ",") ~ "]";
    }
    if (node.nodes)
      vals ~= nodeToH5(node.nodes, level + 1);
    else if (node.txt.length > 0)
      vals ~= "\"" ~ node.txt ~ "\"";

    result ~= intender("H5" ~ capitalize(
        node.tag) ~ "(%s\n".format(vals.join(",")) ~ ")", to!size_t(
        level));
  } else if ((node.isContent) && (
      node.txt.length > 0)) {
    result ~= intender(node.txt.length > 0 ? "H5String(\"%s\")".format(node.txt) : "", to!size_t(
        level));
  }

  return result;
}
