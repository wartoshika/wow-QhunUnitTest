QhunUnitTest.Base = {}
QhunUnitTest.Base.__index = QhunUnitTest.Base

-- constructor
function QhunUnitTest.Base.new()
    -- private properties
    local instance = {
        _lastAssertCount = 0,
        _lastErrorCount = 0
    }

    setmetatable(instance, QhunUnitTest.Base)

    return instance
end

--[[
    PUBLIC FUNCTIONS
]]
-- a setup function that will be executed once before the class tests run
function QhunUnitTest.Base:setupClass()
end

-- a teardown function that will be executed one after all tests of the class as been run
function QhunUnitTest.Base:teardownClass()
end

-- a setup function that will be executed before each test
function QhunUnitTest.Base:setup(methodName)
end

-- a teardown function that will be executed after each test has been run
function QhunUnitTest.Base:teardown(methodName)
end

-- reset the assert counts for the next test run
function QhunUnitTest.Base:resetAssertCounts()
    self._lastAssertCount = 0
    self._lastErrorCount = 0
end

-- get the assert counts for the last test run
-- returns numberOkAsserts, numberOfErrors
function QhunUnitTest.Base:getAssertCounts()
    return self._lastAssertCount, self._lastErrorCount
end

-- tests if the given value is an instance of expectedClass
--[[
    {
        value: {},
        expectedClass: {},
        message?: string
    }
    returns boolean
]]
function QhunUnitTest.Base:assertClassOf(value, expectedClass, message)
    self._lastAssertCount = self._lastAssertCount + 1

    -- make the assertion
    local assertion = value.__index == expectedClass

    -- write an error
    if not assertion then
        self:_assertError(message or "Expected value to be an instanceof class")
    end
    return assertion
end

-- tests if the given value is derived from the expected class
--[[
    {
        value: {},
        expectedClass: {},
        message?: string
    }
    returns boolean
]]
function QhunUnitTest.Base:assertDerivedFrom(value, expectedClass, message)
    self._lastAssertCount = self._lastAssertCount + 1

    -- make the assertion
    local assertion = getmetatable(getmetatable(value).__index).__index == expectedClass

    -- write an error
    if not assertion then
        self:_assertError(message or "Expected value to be a derived class")
    end
    return assertion
end

-- tests if the given table has a size of the expected size
--[[
    {
        table: {},
        expectedSize: number,
        message?: string
    }
    returns boolean
]]
function QhunUnitTest.Base:assertTableSize(table, expectedSize, message)
    self._lastAssertCount = self._lastAssertCount + 1
    local size = 0
    for _, _ in pairs(table) do
        size = size + 1
    end

    if size ~= expectedSize then
        self:_assertError(message or "The given table size is " .. size .. " but expected was " .. expectedSize)
    end

    return size == expectedSize
end

-- tests if a given value is true (typesafe)
--[[
    {
        booleanValue: boolean,
        message?: string
    }
    returns boolean
]]
function QhunUnitTest.Base:assertTrue(booleanValue, message)
    self._lastAssertCount = self._lastAssertCount + 1
    if type(booleanValue) ~= "boolean" or not booleanValue then
        self:_assertError(message or "The given boolean value was FALSE but expected to be TRUE")
    end

    return booleanValue == true
end

-- tests if a given value is false (typesafe)
--[[
    {
        booleanValue: boolean,
        message?: string
    }
    returns boolean
]]
function QhunUnitTest.Base:assertFalse(booleanValue, message)
    self._lastAssertCount = self._lastAssertCount + 1
    if type(booleanValue) ~= "boolean" or booleanValue then
        self:_assertError(message or "The given boolean value was TRUE but expected to be FALSE")
    end

    return booleanValue == false
end

-- tests if a given value is nill
--[[
    {
        value: nil,
        message?: string
    }
    returns boolean
]]
function QhunUnitTest.Base:assertNil(value, message)
    self._lastAssertCount = self._lastAssertCount + 1
    if value ~= nil then
        self:_assertError(message or "The given value was expected to be NIL. Current value is typeof " .. type(value))
    end
    return value == nil
end

-- tests if the two objects are equal using == operator
--[[
    {
        value1: any,
        value2: any,
        message?: string
    }
    returns boolean
]]
function QhunUnitTest.Base:assertEqual(value1, value2, message)
    self._lastAssertCount = self._lastAssertCount + 1
    local match = value1 == value2
    if not match then
        self:_assertError(
            message or "The two values are not equal. Type 1 is " .. type(value1) .. " and type 2 is " .. type(value2)
        )
    end
    return match
end

-- tests if the two tables have the save key and values but different links
-- NOTE: this is used for tables with the save content but there the == operator does not work
--[[
    {
        o1: table,
        p2: table,
        ignoreMetatable?: boolean = true,
        message?: string
    }
    returns boolean
]]
function QhunUnitTest.Base:assertTableSimilar(o1, o2, ignoreMetatable, message)
    local msg = self:_similarTable(o1, o2, ignoreMetatable)
    if msg ~= true then
        self:_assertError(message or msg)
    end

    return true
end

-- tests if the two objects are unequal using ~= operator
--[[
    {
        value1: any,
        value2: any,
        message?: string
    }
    returns boolean
]]
function QhunUnitTest.Base:assertNotEqual(value1, value2, message)
    self._lastAssertCount = self._lastAssertCount + 1
    local match = value1 ~= value2
    if not match then
        self:_assertError(message or "The two values are equal. They should not be")
    end
    return match
end

-- tests if a given variable has a expected type
--[[
    {
        variable: any,
        expectedType: string,
        message?: string
    }
    returns boolean
]]
function QhunUnitTest.Base:assertTypeof(variable, expectedType, message)
    self._lastAssertCount = self._lastAssertCount + 1
    local match = type(variable) == expectedType
    if not match then
        self:_assertError(
            message or
                'The given variable\'s type ("' ..
                    type(variable) .. '") does not match with the expected ("' .. expectedType .. '").'
        )
    end

    return match
end

-- tests if a given number is greater than or equal to the expected number
--[[
    {
        variable: number,
        expectedNumber: number,
        message?: string
    }
    returns boolean
]]
function QhunUnitTest.Base:assertNumberGreaterThanEqual(variable, expectedNumber, message)
    self._lastAssertCount = self._lastAssertCount + 1

    if type(variable) == "number" then
        if not (variable >= expectedNumber) then
            self:_assertError(
                message or "the number " .. variable .. " expected to be greater then or equal to " .. expectedNumber
            )
        end
    else
        self:_assertError("the variable should be a number but typeof " .. type(variable) .. " given")
    end

    return true
end

-- tests if a given string has the expected length
--[[
    {
        variable: string,
        expectedLength: number,
        message?: string
    }
    returns boolean
]]
function QhunUnitTest.Base:assertStringLength(variable, expectedLength, message)
    self._lastAssertCount = self._lastAssertCount + 1

    if type(variable) == "string" then
        local currentLength = variable:len()
        if currentLength ~= expectedLength then
            self:_assertError(
                message or "the length of the string was " .. currentLength .. " but expected to be " .. expectedLength
            )
        end
    else
        self:_assertError("the variable should be a string but typeof " .. type(variable) .. " given")
    end

    return true
end

-- tests if a method was invoked at least one time
--[[
    {
        wrappedInstance: {QhunUnitTest.Wrapper},
        methodName: string,
        message?: string
    }
    returns boolean
]]
function QhunUnitTest.Base:assertMethodCalled(wrappedInstance, methodName, message)
    self._lastAssertCount = self._lastAssertCount + 1

    local actualCalls = wrappedInstance:__unittest_getMethodCallAmount(methodName)

    if actualCalls < 1 then
        self:_assertError(
            message or 'the wrapped instance does not make any calls to the given method "' .. methodName '"'
        )
    end

    return true
end

-- tests if a method was invoked at least one time
--[[
    {
        wrappedInstance: {QhunUnitTest.Wrapper},
        methodName: string,
        -- the amount of calls to the given method
        expectedCalls: number,
        message?: string
    }
    returns boolean
]]
function QhunUnitTest.Base:assertMethodCalledTimes(wrappedInstance, methodName, expectedCalls, message)
    self._lastAssertCount = self._lastAssertCount + 1

    local actualCalls = wrappedInstance:__unittest_getMethodCallAmount(methodName)

    if actualCalls ~= expectedCalls then
        self:_assertError(
            message or
                "the wrapped instance done " ..
                    actualCalls .. ' to the given method "' .. methodName '" but expected are ' .. expectedCalls
        )
    end

    return true
end

-- tests if a method was invoked with the given arguments
--[[
    {
        wrappedInstance: {QhunUnitTest.Wrapper},
        methodName: string,
        -- the amount of calls to the given method
        arguments: {...},
        message?: string
    }
    returns boolean
]]
function QhunUnitTest.Base:assertMethodCalledWith(wrappedInstance, methodName, arguments, message)
    self._lastAssertCount = self._lastAssertCount + 1

    local calls = wrappedInstance:__unittest_getAllMethodCalls(methodName)

    -- check if the method was called with the given arguments
    for _, call in pairs(calls) do
        if self:_similarTable(arguments, call.parameter, true) == true then
            return true
        end
    end

    self:_assertError(message or 'the method "' .. methodName .. '" was not called with the given arguments.')
end

-- tests if a given method was not called
--[[
    {
        wrappedInstance: {QhunUnitTest.Wrapper},
        methodName: string,
        message?: string
    }
    returns boolean
]]
function QhunUnitTest.Base:assertMethodNotCalled(wrappedInstance, methodName, message)
    self._lastAssertCount = self._lastAssertCount + 1

    local actualCalls = wrappedInstance:__unittest_getMethodCallAmount(methodName)

    if actualCalls ~= 0 then
        self:_assertError(message or 'the wrapped instance has made calls to "' .. methodName '". this was unexpected')
    end

    return true
end

-- tests if a given method was not called with the given arguments
--[[
    {
        wrappedInstance: {QhunUnitTest.Wrapper},
        methodName: string,
        arguments: {...},
        message?: string
    }
    returns boolean
]]
function QhunUnitTest.Base:assertMethodNotCalledWith(wrappedInstance, methodName, arguments, message)
    self._lastAssertCount = self._lastAssertCount + 1

    local calls = wrappedInstance:__unittest_getAllMethodCalls(methodName)

    -- check if the method was called with the given arguments
    for _, call in pairs(calls) do
        if self:_similarTable(arguments, call.parameter, true) == true then
            self:_assertError(
                message or 'the method "' .. methodName .. '" was called with the given arguments. this was unexpected.'
            )
        end
    end

    return true
end

-- test if a callback function throws a lua error
--[[
    {
        callback: function,
        -- arguments will be passed to the callback in that order
        -- NOTE: because of using pcall, the current function context will be lost
        arguments: {...},
        message?: string
    }
]]
function QhunUnitTest.Base:assertError(callback, arguments, message)
    self._lastAssertCount = self._lastAssertCount + 1

    local status, error = pcall(callback, unpack(arguments))
    if status then
        self:_assertError(message or error)
    end
    return status
end

--[[
    PRIVATE FUNCTIONS
]]
function QhunUnitTest.Base:_assertError(message)
    self._lastErrorCount = self._lastErrorCount + 1
    error(message)
end

function QhunUnitTest.Base:_similarTable(o1, o2, ignoreMetatable)
    -- default value check
    if type(ignoreMetatable) ~= "boolean" then
        ignoreMetatable = true
    end

    if o1 == o2 then
        return true
    end
    local o1Type = type(o1)
    local o2Type = type(o2)
    if o1Type ~= o2Type then
        return false
    end
    if o1Type ~= "table" then
        return "type missmatch for table 1. expected table but got " .. o1Type
    end

    if not ignoreMetatable then
        local mt1 = getmetatable(o1)
        if mt1 and mt1.__eq then
            --compare using built in method
            local result = o1 == o2
            if not result then
                return "the two tables are not equal using == operator and metatableSearch"
            end
            return result
        end
    end

    local keySet = {}

    for key1, value1 in pairs(o1) do
        local value2 = o2[key1]
        if value2 == nil or self:_similarTable(value1, value2, ignoreMetatable) ~= true then
            return "some values differ in the two tables"
        end
        keySet[key1] = true
    end

    for key2, _ in pairs(o2) do
        if not keySet[key2] then
            return "some keys differ in the two tables"
        end
    end
    return true
end
