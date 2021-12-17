local xml = require "pl.xml"

describe("xml", function()

  describe("creating", function()

    describe("new()", function()

      it("creates a new xml-document", function()
        local doc = xml.new("main")
        assert.equal("<main/>", doc:tostring())
      end)


      it("fails without a tag", function()
        assert.has.error(function()
          xml.new()
        end, "expected 'tag' to be a string value, got: nil")
      end)


      it("adds attributes if given", function()
        local doc = xml.new("main", { hello = "world" })
        assert.equal("<main hello='world'/>", doc:tostring())
      end)

    end)



    describe("parse()", function()

      pending("todo", function()
        -- TODO: implement
      end)

    end)



    describe("add_direct_child", function()

      it("adds a child node", function()
        local doc = xml.new("main")
        doc:add_direct_child(xml.new("child"))
        assert.equal("<main><child/></main>", doc:tostring())

        doc:add_direct_child(xml.new("child"))
        assert.equal("<main><child/><child/></main>", doc:tostring())
      end)


      it("adds a text node", function()
        local doc = xml.new("main")
        doc:add_direct_child("child")
        assert.equal("<main>child</main>", doc:tostring())

        doc:add_direct_child("child")
        assert.equal("<main>childchild</main>", doc:tostring())
      end)

    end)



    describe("addtag()", function()

      it("adds a Node", function()
        local doc = xml.new("main")
        doc:addtag("penlight", { hello = "world" })
        assert.equal("<main><penlight hello='world'/></main>", doc:tostring())

        -- moves position
        doc:addtag("expat")
        assert.equal("<main><penlight hello='world'><expat/></penlight></main>", doc:tostring())
      end)

    end)



    describe("text()", function()

      it("adds text", function()
        local doc = xml.new("main")
        doc:text("penlight")
        assert.equal("<main>penlight</main>", doc:tostring())

        -- moves position
        doc:text("expat")
        assert.equal("<main>penlightexpat</main>", doc:tostring())
      end)

    end)



    describe("up()", function()

      it("moves position up 1 level", function()
        local doc = xml.new("main")
        doc:addtag("one")
        doc:addtag("two-a")
        doc:up()
        doc:addtag("two-b")
        assert.equal("<main><one><two-a/><two-b/></one></main>", doc:tostring())

        -- doesn't move beyond top level
        for i = 1, 10 do
          doc:up()
        end
        doc:addtag("solong")
        assert.equal("<main><one><two-a/><two-b/></one><solong/></main>", doc:tostring())
      end)

    end)



    describe("reset()", function()

      it("resets position to top Node", function()
        local doc = xml.new("main")
        doc:addtag("one")
        doc:addtag("two")
        doc:addtag("three")
        doc:reset()
        doc:addtag("solong")
        assert.equal("<main><one><two><three/></two></one><solong/></main>", doc:tostring())
      end)

    end)



    describe("add_child()", function()

      it("adds a child at the current position", function()
        local doc = xml.new("main")
        doc:addtag("one")
        doc:add_child(xml.new("item1"))
        doc:add_child(xml.new("item2"))
        doc:add_child(xml.new("item3"))
        assert.equal("<main><one><item1/><item2/><item3/></one></main>", doc:tostring())
      end)

    end)



    describe("set_attribs()", function()

      it("sets attributes on the Node", function()
        local doc = xml.new("main")
        doc:addtag("one") -- moves position


        doc:set_attribs( { one = "a" })
        assert.equal("<main one='a'><one/></main>", doc:tostring())

        -- overwrites and adds
        doc:set_attribs( { one = "1", two = "2" })
        assert.matches("one='1'", doc:tostring())
        assert.matches("two='2'", doc:tostring())

        -- 'two' doesn't get removed
        doc:set_attribs( { one = "a" })
        assert.matches("one='a'", doc:tostring())
        assert.matches("two='2'", doc:tostring())
      end)

    end)



    describe("set_attrib()", function()

      it("sets/deletes a single attribute on the Node", function()
        local doc = xml.new("main")
        doc:addtag("one") -- moves position


        doc:set_attrib("one", "a")
        assert.equal("<main one='a'><one/></main>", doc:tostring())

        -- deletes
        doc:set_attrib("one", nil)
        assert.equal("<main><one/></main>", doc:tostring())
      end)

    end)



    describe("get_attribs()", function()

      it("gets attributes on the Node", function()
        local doc = xml.new("main")
        doc:addtag("one") -- moves position

        doc:set_attribs( { one = "1", two = "2" })
        assert.same({ one = "1", two = "2" }, doc:get_attribs())
      end)

    end)



    describe("elem()", function()

      it("creates a node", function()
        local doc = xml.elem("main")
        assert.equal("<main/>", doc:tostring())
      end)


      it("creates a node, with single text element", function()
        local doc = xml.elem("main", "oh my")
        assert.equal("<main>oh my</main>", doc:tostring())
      end)


      it("creates a node, with single child tag/Node", function()
        local doc = xml.elem("main", xml.new("child"))
        assert.equal("<main><child/></main>", doc:tostring())
      end)


      it("creates a node, with multiple text elements", function()
        local doc = xml.elem("main", { "this ", "is ", "nice" })
        assert.equal("<main>this is nice</main>", doc:tostring())
      end)


      it("creates a node, with multiple child tags/Nodes", function()
        local doc = xml.elem("main", { xml.new "this", xml.new "is", xml.new "nice" })
        assert.equal("<main><this/><is/><nice/></main>", doc:tostring())
      end)


      it("creates a node, with attributes", function()
        local doc = xml.elem("main", { hello = "world" })
        assert.equal("<main hello='world'/>", doc:tostring())
      end)


      it("creates a node, with text/Node children and attributes", function()
        local doc = xml.elem("main", {
          "prefix",
          xml.elem("child", { "this ", "is ", "nice"}),
          "postfix",
          attrib = "value"
        })
        assert.equal("<main attrib='value'>prefix<child>this is nice</child>postfix</main>", doc:tostring())
      end)

    end)



    describe("tags()", function()

      it("creates constructors", function()
        local parent, child = xml.tags({ "mom" , "kid" })
        local doc = parent {child 'Bob', child 'Annie'}
        assert.equal("<mom><kid>Bob</kid><kid>Annie</kid></mom>", doc:tostring())
      end)


      it("creates constructors from CSV values", function()
        local parent, child = xml.tags("mom,kid" )
        local doc = parent {child 'Bob', child 'Annie'}
        assert.equal("<mom><kid>Bob</kid><kid>Annie</kid></mom>", doc:tostring())
      end)


      it("creates constructors from CSV values, ignores surrounding whitespace", function()
        local parent, child = xml.tags(" mom , kid " )
        local doc = parent {child 'Bob', child 'Annie'}
        assert.equal("<mom><kid>Bob</kid><kid>Annie</kid></mom>", doc:tostring())
      end)

    end)



    describe("subst()", function()

      pending("todo", function()
        -- TODO: implement
      end)

    end)



    describe("child_with_name()", function()

      it("returns the first child", function()
        local doc = xml.new("main")
        doc:add_child(xml.elem "one")
        doc:text("hello")
        doc:add_child(xml.elem "two")
        doc:text("goodbye")
        doc:add_child(xml.elem "three")

        local child = doc:child_with_name("two")
        assert.not_nil(child)
        assert.equal(doc[3], child)
      end)

    end)



    describe("get_elements_with_name()", function()

      it("returns matching nodes", function()
        local doc = assert(xml.parse[[
          <person>
            <name>John</name>
            <children>
              <person>
                <name>Bob</name>
                <children>
                  <person>
                    <name>Bob junior</name>
                  </person>
                </children>
              </person>
              <person>
                <name>Annie</name>
                <children>
                  <person>
                    <name>Melissa</name>
                  </person>
                  <person>
                    <name>Noel</name>
                  </person>
                </children>
              </person>
            </children>
          </person>
        ]])

        local list = doc:get_elements_with_name("name")
        for i, entry in ipairs(list) do
          list[i] = entry:get_text()
        end
        assert.same({"John", "Bob", "Bob junior", "Annie", "Melissa", "Noel"}, list)

        -- if tag not found, returns empty table
        local list = doc:get_elements_with_name("unknown")
        assert.same({}, list)
      end)

    end)



    describe("children()", function()

      it("iterates over all children", function()
        local doc = xml.elem("main", {
          "prefix",
          xml.elem("child"),
          "postfix",
          attrib = "value"
        })

        local lst = {}
        for node in doc:children() do
          lst[#lst+1] = tostring(node)
        end
        assert.same({ "prefix", "<child/>", "postfix"}, lst)
      end)


      it("doesn't fail on empty node", function()
        local doc = xml.elem("main")
        local lst = {}
        for node in doc:children() do
          lst[#lst+1] = tostring(node)
        end
        assert.same({}, lst)
      end)

    end)



    describe("first_childtag()", function()

      it("returns first non-text tag", function()
        local doc = xml.elem("main", {
          "prefix",
          xml.elem("child"),
          "postfix",
          attrib = "value"
        })

        local node = doc:first_childtag()
        assert.same("<child/>", tostring(node))
      end)


      it("returns nil if there is none", function()
        local doc = xml.elem("main", {
          "prefix",
          "postfix",
          attrib = "value"
        })

        local node = doc:first_childtag()
        assert.is_nil(node)
      end)

    end)



    describe("matching_tags()", function()

      local _ = [[
        <root xmlns:h="http://www.w3.org/TR/html4/"
              xmlns:f="https://www.w3schools.com/furniture">

        <h:table>
          <h:tr>
            <h:td>Apples</h:td>
            <h:td>Bananas</h:td>
          </h:tr>
        </h:table>

        <f:table>
          <f:name>African Coffee Table</f:name>
          <f:width>80</f:width>
          <f:length>120</f:length>
        </f:table>

        </root>
      ]]

      pending("xmlns is weird...", function()
        -- the xmlns stuff doesn't make sense
      end)

    end)



    describe("childtags()", function()

      it("returns the first child", function()
        local doc = xml.new("main")
        doc:add_child(xml.elem "one")
        doc:text("hello")
        doc:add_child(xml.elem "two")
        doc:text("goodbye")
        doc:add_child(xml.elem "three")

        local lst = {}
        for node in doc:childtags() do
          lst[#lst+1] = tostring(node)
        end
        assert.same({"<one/>", "<two/>", "<three/>"},lst)
      end)

    end)



    describe("maptags()", function()

      it("updates nodes", function()
        local doc = xml.new("main")
        doc:add_child(xml.elem "one")
        doc:text("hello")
        doc:add_child(xml.elem "two")
        doc:text("goodbye")
        doc:add_child(xml.elem "three")

        doc:maptags(function(node)
          if node.tag then
            -- return a new object so we know it got replaced
            return xml.new(node.tag:upper())
          end
          return node
        end)
        assert.same("<main><ONE/>hello<TWO/>goodbye<THREE/></main>", doc:tostring())
      end)

    end)

  end)

end)
