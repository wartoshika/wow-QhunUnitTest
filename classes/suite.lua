QhunUnitTest.Suite = {}
QhunUnitTest.Suite.__index = QhunUnitTest.Suite

-- private static vars
local testSuites = {}
local testColors = {
    RED = "|c00ff0000",
    YELLOW = "|c00ffff00",
    GREEN = "|c0000ff00",
    WHITE = "|c00ffffff",
    GREY = "|c00bbbbbb",
    BLACK = "|c00000000"
}

-- constructor
--[[
    {
        -- the name of the testsuite
        name: string
    }
]]
function QhunUnitTest.Suite.new(name)
    -- private properties
    local instance = {
        _name = name,
        _classes = {}
    }

    setmetatable(instance, QhunUnitTest.Suite)

    return instance
end

--[[
    PUBLIC STATIC FUNCTIONS
]]
-- get all suites that are registered for slash commands
function QhunUnitTest.Suite.getAllSlashCommandSuites()
    return testSuites
end

--[[
    PUBLIC FUNCTIONS
]]
--[[
    {
        -- the name of the class for a better result output
        className: string
        class: {? extends QhunUnitTest.Base}
    }
]]
function QhunUnitTest.Suite:registerClass(className, class)
    -- type check first
    if not (getmetatable(getmetatable(class).__index).__index == QhunUnitTest.Base) then
        self:printError("QhunUnitTest.Suite:registerClass() the given class does not derived from QhunUnitTest.Base")
        return
    end

    table.insert(self._classes, {name = className, class = class})
end

-- registers the test suite for the slash command api
--[[
    {
        -- define a different name for accessing the test suite rather than
        -- the name of the testsuite itself
        otherName?: string
    }
]]
function QhunUnitTest.Suite:registerForSlashCommand(otherName)
    testSuites[otherName or self._name] = self
end

-- run all tests defined in the suite
function QhunUnitTest.Suite:run()
    -- define a test result storage
    local testResult = {}

    -- set global test identifyer
    QhunIsOnUnitTest = true

    -- iterate over every registered class
    for _, testClass in pairs(self._classes) do
        local testMethods = {}

        -- get the correct order
        local order = testClass.class.__methodOrder
        if type(order) ~= "table" then
            -- initialise
            order = {}

            -- get all available functions from the metatable
            local meta = getmetatable(testClass.class)
            for method, _ in pairs(meta) do
                table.insert(order, method)
            end
        end

        -- get every public method from the class
        for _, methodName in pairs(order) do
            -- add test methods that does not start with a _ character and
            -- also exclude the constructor, setup and teardown function
            if
                methodName:sub(1, 1) ~= "_" and methodName ~= "new" and methodName:sub(1, 5) ~= "setup" and
                    methodName:sub(1, 8) ~= "teardown"
             then
                table.insert(testMethods, {name = methodName})
            end
        end

        -- need to global the class for the loadstring function
        QhunUnitTest_CurrentGlobalClass = testClass.class

        -- execute classwide setup
        testClass.class:setupClass()

        -- iterare over every test
        for _, test in pairs(testMethods) do
            -- run setup for each test
            testClass.class:setup(test.name)

            -- run the test itself with pcall to get the exceptions
            local status, err = pcall(loadstring("return QhunUnitTest_CurrentGlobalClass:" .. test.name .. "()"))

            -- set the result
            test.result = status
            test.errorMessage = err

            -- run the teardown
            testClass.class:teardown(test.name)
        end

        -- get assert and error counts and reset them
        local asserts, assertErrors = QhunUnitTest_CurrentGlobalClass:getAssertCounts()
        QhunUnitTest_CurrentGlobalClass:resetAssertCounts()

        -- after all tests run the class teardown
        testClass.class:teardownClass()

        -- store the result
        testResult[testClass.name] = {
            result = testMethods,
            asserts = asserts,
            assertErrors = assertErrors
        }
    end

    -- set global test identifyer
    QhunIsOnUnitTest = false

    -- empty the global class
    QhunUnitTest_CurrentGlobalClass = nil

    return testResult
end

--[[
    PRIVATE FUNCTIONS
]]
function QhunUnitTest.Suite:printError(text)
    print("|c00ff0000[QhunUnitTest] " .. text)
    error(text)
end

-- print the result of a test suite run to the console
--[[
    {
        {
            [className: string]: {
                -- the number of made asserts
                asserts: number,
                -- the number of assert errors during the test
                assertErrors: number,
                result: {
                    name: string,
                    result: boolean,
                    errorMessage?: string | nil
                }
            }[]
        }[]
    }
]]
function QhunUnitTest.Suite:printResult(result)
    print(testColors.BLACK .. "------------------------------------------------------------------")
    print(testColors.WHITE .. '[QhunUnitTest] Running the suite "' .. self._name .. '"|r')
    print(testColors.BLACK .. "------------------------------------------------------------------")
    print()

    local finalResultColor = testColors.GREEN
    local hasOneError = false
    local hasOneSuccess = false
    local amountOfTests = 0
    local amountOfAsserts = 0
    local amountOfSuccess = 0
    local amountOfErrors = 0

    -- printing each test result
    for className, tests in pairs(result) do
        -- sum up the asserts
        amountOfAsserts = amountOfAsserts + tests.asserts

        -- print the class name
        print(
            testColors.GREY ..
                "|--- " ..
                    self:getClassResultColor(tests.result) ..
                        className ..
                            testColors.GREY ..
                                " (" .. tests.asserts .. " Asserts, " .. tests.assertErrors .. " Errors)|r"
        )

        -- iterate over every method result
        for _, method in pairs(tests.result) do
            -- print the result with function name
            local resultColor = testColors.GREEN
            local line = method.name
            amountOfTests = amountOfTests + 1

            -- add color and error message
            if not method.result then
                -- set the final result flag
                hasOneError = true
                amountOfErrors = amountOfErrors + 1

                resultColor = testColors.RED
                line = line .. " (" .. testColors.GREY .. tostring(method.errorMessage) .. testColors.RED .. ")"
            else
                hasOneSuccess = true
                amountOfSuccess = amountOfSuccess + 1
            end
            print(testColors.GREY .. "     |--- " .. resultColor .. line)
        end
    end

    -- define the final color
    if hasOneError and hasOneSuccess then
        finalResultColor = testColors.YELLOW
    elseif hasOneError and not hasOneSuccess then
        finalResultColor = testColors.RED
    end

    -- print a final status
    print()
    print(testColors.BLACK .. "------------------------------------------------------------------")
    print(
        finalResultColor ..
            "Result: " ..
                amountOfTests ..
                    " Tests (" ..
                        amountOfSuccess .. " OK, " .. amountOfErrors .. " Error, " .. amountOfAsserts .. " Asserts)"
    )
    print(testColors.BLACK .. "------------------------------------------------------------------")
end

-- get the console color string for the given class test
function QhunUnitTest.Suite:getClassResultColor(classTest)
    -- asume everything went well :)
    -- color green
    local color = testColors.GREEN
    local hasOneError = false
    local hasOneSuccess = false

    for _, test in pairs(classTest) do
        if test.result then
            hasOneSuccess = true
        else
            hasOneError = true
        end
    end

    -- now check if there are errors
    if hasOneError and not hasOneSuccess then
        -- all tests failed
        -- color red
        color = testColors.RED
    elseif hasOneError then
        -- at least one test is ok
        -- color yellow
        color = testColors.YELLOW
    end

    return color
end
