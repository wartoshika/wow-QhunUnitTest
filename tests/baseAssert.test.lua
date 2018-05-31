QhunUnitTest.Test.BaseAssert = {}
QhunUnitTest.Test.BaseAssert.__index = QhunUnitTest.Test.BaseAssert

-- constructor
function QhunUnitTest.Test.BaseAssert.new()
    -- call super class
    local instance = QhunUnitTest.Base.new()

    -- private vars
    instance._classSetupTest = 0
    instance._classTeardownTest = 0
    instance._methodSetupTest = 0
    instance._methodTeardownTest = 0
    instance._baseClassWrapper = nil
    instance._methodOrderTestObject = {}

    -- bind current values
    setmetatable(instance, QhunUnitTest.Test.BaseAssert)

    return instance
end

-- set inheritance
setmetatable(QhunUnitTest.Test.BaseAssert, {__index = QhunUnitTest.Base})

--[[
    TESTS
]]
function QhunUnitTest.Test.BaseAssert:testAssertClassOf()
    self:assertTrue(self:assertClassOf(self, QhunUnitTest.Test.BaseAssert))

    -- assertClassOf should only test the current class but not parent classes
    self:assertError(
        function()
            self:assertClassOf(self, QhunUnitTest.Base)
        end,
        {},
        "The parent class should not be true"
    )
end

function QhunUnitTest.Test.BaseAssert:testAssertDerivedFrom()
    self:assertTrue(self:assertDerivedFrom(self, QhunUnitTest.Base))

    -- assertDerivedFrom should only test the parent class but not the current
    self:assertError(
        function()
            self:assertDerivedFrom(self, QhunUnitTest.Test.BaseAssert)
        end,
        {},
        "The current class should not be true"
    )
end

function QhunUnitTest.Test.BaseAssert:testAssertTableSize()
    -- true tests
    self:assertTrue(self:assertTableSize({1, 2, 3, 4}, 4))
    self:assertTrue(self:assertTableSize({}, 0))
    self:assertTrue(
        self:assertTableSize(
            {
                TEST = {1, 2, 3},
                "hello",
                KEY = false
            },
            3
        )
    )

    -- false tests
    self:assertError(
        function()
            self:assertTableSize({}, 1)
        end
    )
end

function QhunUnitTest.Test.BaseAssert:testAssertTrue()
    self:assertTrue(true)
    self:assertError(
        function()
            self:assertTrue(false)
        end
    )
end

function QhunUnitTest.Test.BaseAssert:testAssertFalse()
    self:assertFalse(false)
    self:assertError(
        function()
            self:assertfalse(true)
        end
    )
end

function QhunUnitTest.Test.BaseAssert:testAssertNil()
    self:assertTrue(self:assertNil(nil))
    self:assertError(
        function()
            self:assertNil(true)
        end
    )
end

function QhunUnitTest.Test.BaseAssert:testAssertEqual()
    self:assertTrue(self:assertEqual(true, true))
    self:assertTrue(self:assertEqual("test", "test"))
    self:assertTrue(self:assertEqual(1.2345678, 1.2345678))
    self:assertTrue(self:assertEqual(nil, nil))

    -- table equal check
    local testTable = {"test", 1, 2, 3}
    self:assertTrue(self:assertEqual(testTable, testTable))

    -- different table check
    self:assertError(
        function()
            self:assertEqual({}, {})
        end,
        {},
        "Two tables should should not be equal when not sharing the same link"
    )
end

function QhunUnitTest.Test.BaseAssert:testAssertTableSimilar()
    -- successfull tests
    local table1 = {1, 2, 3, 4}
    local table1_1 = {1, 2, 3, 4}
    local table2 = {KEY = {OTHER_KEY = "test"}, "value", true}
    local table2_1 = {KEY = {OTHER_KEY = "test"}, "value", true}
    local table2_2 = {KEY = {OTHER_KEY = "test"}, "value", false}

    self:assertTrue(self:assertTableSimilar(table1, table1_1))
    self:assertTrue(self:assertTableSimilar(table2, table2_1))

    -- identical link check
    self:assertTrue(self:assertTableSimilar(table2, table2))

    -- error tests
    self:assertError(
        function(table1, table2)
            self:assertTableSimilar(table1, table2)
        end,
        {table1, table2}
    )

    -- deep error test
    self:assertError(
        function(table1, table2_2)
            self:assertTableSimilar(table1, table2_2)
        end,
        {table1, table2_2}
    )
end

function QhunUnitTest.Test.BaseAssert:testAssertNotEqual()
    self:assertTrue(self:assertNotEqual(true, false))
    self:assertTrue(self:assertNotEqual("test1", "test"))
    self:assertTrue(self:assertNotEqual(1.2345678, 1.2345679))
    self:assertTrue(self:assertNotEqual(true, nil))
    self:assertTrue(self:assertNotEqual({}, {}))

    -- differt type check
    self:assertTrue(self:assertNotEqual("1", {}))

    -- table equal check
    local testTable = {"test", 1, 2, 3}
    self:assertError(
        function()
            self:assertNotEqual(testTable, testTable)
        end,
        {testtable, testtable}
    )
end

function QhunUnitTest.Test.BaseAssert:testAssertTypeof()
    self:assertTrue(self:assertTypeof("test", "string"))
    self:assertTrue(self:assertTypeof(1, "number"))
    self:assertTrue(self:assertTypeof(true, "boolean"))
    self:assertTrue(self:assertTypeof({}, "table"))
    self:assertTrue(
        self:assertTypeof(
            function()
            end,
            "function"
        )
    )
    self:assertTrue(self:assertTypeof(nil, "nil"))

    self:assertError(
        function()
            self:assertTypeof(1, "string")
        end
    )
end

function QhunUnitTest.Test.BaseAssert:testAssertNumberGreaterThanEqual()
    self:assertTrue(self:assertNumberGreaterThanEqual(1, 1))
    self:assertTrue(self:assertNumberGreaterThanEqual(2, 1))
    self:assertTrue(self:assertNumberGreaterThanEqual(2.0000000001, 2))
    self:assertTrue(self:assertNumberGreaterThanEqual(-10, -10))
    self:assertTrue(self:assertNumberGreaterThanEqual(-10, -11))

    self:assertError(
        function()
            self:assertNumberGreaterThanEqual(1.99999999, 2)
        end
    )
    self:assertError(
        function()
            self:assertNumberGreaterThanEqual(-12, -10)
        end
    )
end

function QhunUnitTest.Test.BaseAssert:testAssertStringLength()
    self:assertTrue(self:assertStringLength("12345", 5))
    self:assertTrue(self:assertStringLength("..........", 10))
    self:assertTrue(self:assertStringLength("\r\n", 2))

    self:assertError(
        function()
            self:assertStringLength("12345", 6)
        end
    )

    self:assertError(
        function()
            self:assertStringLength(nil, 6)
        end
    )

    self:assertError(
        function()
            self:assertStringLength(12, 6)
        end
    )
end

function QhunUnitTest.Test.BaseAssert:testAllAssertMethodCalls()
    local wrapper =
        QhunUnitTest.Wrapper.new(
        {
            test = function(arg1, arg2, arg3)
            end
        }
    )

    -- method should not have been called
    self:assertTrue(self:assertMethodNotCalled(wrapper, "test"))
    self:assertTrue(self:assertMethodCalledTimes(wrapper, "test", 0))
    self:assertError(
        function(wrapper)
            self:assertMethodCalled(wrapper, "test")
        end,
        {wrapper}
    )

    -- call the method
    wrapper:test()

    -- test called
    self:assertTrue(self:assertMethodCalled(wrapper, "test"))
    self:assertTrue(self:assertMethodCalledTimes(wrapper, "test", 1))
    self:assertError(
        function(wrapper)
            self:assertMethodNotCalled(wrapper, "test")
        end,
        {wrapper}
    )

    -- times test
    wrapper:test()
    wrapper:test()
    wrapper:test()
    wrapper:test()
    self:assertTrue(self:assertMethodCalledTimes(wrapper, "test", 5))

    -- argument test
    self:assertTrue(self:assertMethodCalledWith(wrapper, "test", {}))
    self:assertTrue(self:assertMethodNotCalledWith(wrapper, "test", {true, false}))

    -- call with args
    wrapper:test("test", true, {1, 2, 3, "4"})
    self:assertTrue(
        self:assertMethodCalledWith(
            wrapper,
            "test",
            {
                "test",
                true,
                {1, 2, 3, "4"}
            }
        )
    )

    self:assertTrue(
        self:assertMethodNotCalledWith(
            wrapper,
            "test",
            {
                "test",
                true,
                {1, 2, 1000000, "4"}
            }
        )
    )
end