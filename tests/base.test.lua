QhunUnitTest.Test.Base = {}
QhunUnitTest.Test.Base.__index = QhunUnitTest.Test.Base

-- constructor
function QhunUnitTest.Test.Base.new()
    -- the method run order
    local order = {
        "testClassSetup",
        "testMethodSetup",
        "testMethodOrder",
        "testMethodTeardown",
        "testAssertCountAndReset"
    }

    -- call super class
    local instance = QhunUnitTest.Base.new(order)

    -- private vars
    instance._classSetupTest = 0
    instance._classTeardownTest = 0
    instance._methodSetupTest = 0
    instance._methodTeardownTest = 0
    instance._baseClassWrapper = nil
    instance._methodOrderTestObject = {}

    -- bind current values
    setmetatable(instance, QhunUnitTest.Test.Base)

    return instance
end

-- set inheritance
setmetatable(QhunUnitTest.Test.Base, {__index = QhunUnitTest.Base})

--[[
    SETUP and TEARDOWN
]]
function QhunUnitTest.Test.Base:setupClass()
    -- increment the var to test if this function will only be
    -- called once
    self._classSetupTest = self._classSetupTest + 1
end

function QhunUnitTest.Test.Base:teardownClass()
    -- increment the var to test if this function will only be
    -- called once
    self._classTeardownTest = self._classTeardownTest + 1
end

function QhunUnitTest.Test.Base:setup()
    -- increment the var to test how many setups made
    self._methodSetupTest = self._methodSetupTest + 1
end

function QhunUnitTest.Test.Base:teardown()
    -- increment the var to test how many teardowns made
    self._methodTeardownTest = self._methodTeardownTest + 1
end

--[[
    TESTS
]]
function QhunUnitTest.Test.Base:testClassSetup()
    -- insert to order test table
    table.insert(self._methodOrderTestObject, "testClassSetup")

    -- the class setup must be completed before this function is called
    self:assertEqual(self._classSetupTest, 1, "class setup function call counter is wrong!")

    -- all teardown counters must be 0
    self:assertEqual(self._classTeardownTest, 0, "class teardown should not have been called")
    self:assertEqual(self._methodTeardownTest, 0, "method teardown should not have been called")
end

function QhunUnitTest.Test.Base:testMethodSetup()
    -- insert to order test table
    table.insert(self._methodOrderTestObject, "testMethodSetup")

    -- method setup must be completed before this function is called
    self:assertNumberGreaterThanEqual(self._methodSetupTest, 1, "method setup should have been called")
end

function QhunUnitTest.Test.Base:testMethodTeardown()
    -- this function will ran in 4th place. method teardown
    -- counter should be 3
    self:assertEqual(self._methodTeardownTest, 3, "method teardown counter wrong!")
end

function QhunUnitTest.Test.Base:testMethodOrder()
    -- this function MUST be run in third place.
    -- check if the other functions ran
    self:assertTableSimilar(
        self._methodOrderTestObject,
        {
            "testClassSetup",
            "testMethodSetup"
        },
        true,
        "method order does not work properly"
    )
end

function QhunUnitTest.Test.Base:testAssertCountAndReset()
    -- this function will run at 5th place. some asserts have
    -- been made. Test the counter!
    self:assertNumberGreaterThanEqual(self.__lastAssertCount, 1, "assert counter wrong!")

    -- tmp save the assert and error counter
    local tmpAssertCount = self.__lastAssertCount
    local tmpErrorCount = self.__lastErrorCount

    -- test getAssertCounts function
    self.__lastAssertCount = 104
    self.__lastErrorCount = 3
    self:assertTableSimilar({self:getAssertCounts()}, {104, 3}, "getAssertCounts function does not work")

    -- test if the reset works
    self:resetAssertCounts()

    self:assertEqual(self.__lastAssertCount, 0, "assert count reset doesnt work")
    self:assertEqual(self.__lastErrorCount, 0, "error count reset doesnt work")

    -- restore the original values
    self.__lastAssertCount = tmpAssertCount + 2 -- (2 more assets made)
    self.__lastErrorCount = tmpErrorCount
end