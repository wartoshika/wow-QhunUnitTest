# QhunUnitTest - Documentation

## Installation

Just drop the content of the ZIP-File into your World of Warcraft addon folder. The addon should be automaticly enabled during a fresh start of the game client.

## Setup

Every addon should have at least one test suite. You can setup your suite by instantiate the `QhunUnitTest.Suite` class. When you get your instance, you can register all defined test classes. A test class should derived from the abstract `QhunUnitTest.Base` class.

### Setup example

This is an example of a testsuite with the name QhunCore.

```lua
-- check if the unit test addon is available
if IsAddOnLoaded("QhunUnitTest") then

    -- create a test suite
    local suite = QhunUnitTest.Suite.new("QhunCore")

    -- register all known unit tests
    suite:registerClass("EventEmitter", QhunCore.Test.EventEmitter.new())
    suite:registerClass("Translation", QhunCore.Test.Translation.new())
    suite:registerClass("Storage", QhunCore.Test.Storage.new())
    suite:registerClass("functions.lua", QhunCore.Test.Function.new())

    -- register for slash
    suite:registerForSlashCommand()
end

```

Setp by step:
1. Check if the unit test addon is available. The test files should be registered in the `.toc` file of your addon. To avoid accidentally loading the test classes in production mode, exsure that this is only the case when developing the addon.
2. Instantiate the `QhunUnitTest.Suite` and pass a good name as first parameter. This name will be used for the printed result and the command line interface.
3. Register all test classes. The test classes will **not** preserve the order. Every registered test class should inherit the `QhunUnitTest.Base` class.
4. Register the suite into the slash event handler context. When registered, you can run your suite by typing `/test YourSuiteName` while beeing ingame.


## A test class

The test class is used to specify a group of tests. If your addon is procedurally developed, you may use a class for a whole file. If you use the `QhunCore` library or any other object orientated library, you should use one test class for one of your addon classes.

A test class can have as many tests as you like and provides `setup` and `teardown` functionality for the whole class and each test itself.

### Example test file

This is a simple test class that uses a bunch of features:

```lua
if not IsAddOnLoaded("QhunUnitTest") then
    return
end

QhunCore.Test.Storage = {}
QhunCore.Test.Storage.__index = QhunCore.Test.Storage

-- constructor
function QhunCore.Test.Storage.new()
    -- call super class
    local instance = QhunUnitTest.Base.new()
    instance._wrappedEventEmitter = nil
    instance._originalEventEmitter = nil

    -- bind current values
    setmetatable(instance, QhunCore.Test.Storage)

    return instance
end

-- set inheritance
setmetatable(QhunCore.Test.Storage, {__index = QhunUnitTest.Base})

--[[
    SETUP
]]
function QhunCore.Test.Storage:setup()
    -- wrapp the event emitter to test if a event was emitted
    self._originalEventEmitter = QhunCore.EventEmitter.getCoreInstance()
    self._wrappedEventEmitter = QhunUnitTest.Wrapper.new(self._originalEventEmitter)
    QhunCore.EventEmitter.overrideCoreInstance(self._wrappedEventEmitter)
end

function QhunCore.Test.Storage:teardown()
    -- clear the global storage for every test
    QhunCoreGlobalStorage.unittest = {}
    QhunCoreCharacterStorage.unittest = {}

    -- restore event emitter
    QhunCore.EventEmitter.overrideCoreInstance(self._originalEventEmitter)
end

--[[
    TESTS
]]
function QhunCore.Test.Storage:getAndSet(storage)

    local storage = QhunCore.Storage.new("unittest", "test", true)

    -- get to an empty storage shoule result in a nil value
    self:assertNil(storage:get("TEST"), "a non existing value in the storage should be NIL")

    local testValue = {
        test = {
            t = 1
        },
        k = true
    }

    -- insert a value
    storage:set("TEST", testValue)
    self:assertEqual(
        storage:get("TEST"),
        testValue,
        "a simple get results in a different output of the original object"
    )

    -- test a dotted value and identifyer
    storage:set("TEST.k", false)
    self:assertTableSimilar(
        storage:get("TEST"),
        {
            test = {t = 1},
            k = false
        }
    )

    -- get test with dot for a deeper value
    self:assertEqual(storage:get("TEST.test.t"), 1, "deep storage get test failed")
end

function QhunCore.Test.Storage:commitTest(storage, commitedAccessor)

    local storage = QhunCore.Storage.new("unittest", "commitTest", true)
    local commitAccessor = QhunCoreCharacterStorage

    -- first add some values to the storage
    storage:set("TEST", true)

    -- the set call should not have commited and value
    self:assertTableSize(
        commitedAccessor["unittest"]["commitTest"],
        0,
        "storage set should not commit the values itself!"
    )

    -- a storage uncommit change event should have been called
    self:assertMethodCalledWith(
        self._wrappedEventEmitter,
        "emit",
        {
            "STORAGE_UNCOMMITTED_CHANGED",
            "TEST",
            true
        },
        "event emitter doesn't emit an event after setting a value"
    )

    -- commit event should not have been called
    self:assertMethodNotCalledWith(
        self._wrappedEventEmitter,
        "emit",
        {
            "STORAGE_COMMITTED",
            storage._uncommitedChanges
        },
        "storage should not call commit event them set but not commit the values"
    )

    -- temp save the uncommited values for later checks
    local uncommited = storage._uncommitedChanges

    -- now commit the values
    storage:commit()

    -- tests if the values are commited
    self:assertTableSize(commitedAccessor["unittest"]["commitTest"], 1, "the values are not commited!")

    -- the commit event should have been called
    self:assertMethodCalledWith(
        self._wrappedEventEmitter,
        "emit",
        {
            "STORAGE_COMMITTED",
            uncommited
        },
        "storage commit doesn't emit the commited event"
    )
end

```

Setp by step again:

1. Check if the unit test context is available
2. Define your class name. You can either make is globally accessable or use a more private. By setting the `QhunCore.Test.Storage` object to an empty table and also setup an `__index` metamethod, we ensure that LUA know that we have a class accessor.
3. I use a public static `new()` method for constructing my objects. LUA does not have built in class construction so using a common known pattern is a good way to start. In the object constructor you have to "instantiate the parent" class `QhunUnitTest.Base`. Again Lua does not know abstract classes. Whis this way i can do some parent class initialisation.
4. After setup the constructor the need to set the metatable inheritance is nessesary. By adding the `{__index = QhunUnitTest.Base}` to the class metatable, lua knows where to look for undefined class methods. In this case every `assert` methods (and some other things) are inherited from the parent class.
5. After finishing the class head, we can talk about `setup` and `teardown` methods. These two are used to setup and restore a specific context **before** and **after each test method**. Read more in the API documentation below.
6. With the test environment setup, everything is ready to do the first test. A class method defined **one** test *(See allowed names in the API below)*. The name of the method will be used for the result print.
7. In the body of a test method you can do `asserts` or make some preperation... whatever you like to do. I have done some get and set tests to the storage API of the `QhunCore` lib addon.

Things to kow:
- Every assert returns true if the condition was met.
- Every assert throws a silent LUA error when the condition was not met. The current test is aborted and the error was been recorded.
- All available `assert*` methods and their parameters can be review below in the API documentation.
- Hint: Use a good message in the assert method to do a better error lookup when using multiple asserts per method. The framework itself will do its best to provide a good generic error message.


# API

## **`QhunUnitTest.Suite`**

### **PUBLIC FUNCTIONS**

### ***static* QhunUnitTest.Suite `QhunUnitTest.Suite.new(name)`**

*Description: Creates a new test suite.*

*Parameters:*
- name (required, string) - A readable name of the testsuite

### **nil `registerClass(className, class)`**

*Description: Registers a class as a component of the test suite.*

*Parameters:*
- className (required, string) - A readable name of the class used for the result print
- class (required, ? extends `QhunUnitTest.Base`) - The class to register. Must be instantiated.

### **nil `registerForSlashCommand([otherName])`**

*Description: Registers the current test suite for the ingame command line api*

*Parameters:*
- otherName (string) - An other name than the test suite name. Used to access the suite for running the tests.

### **PRIVATE FUNCTIONS**

### TestResultObject `run()`

*Description: Runs every test from every registered test class and generated a test report*

### nil `printError(text)`

*Description: Prints an error onto the console in red color and throws a lua error*

*Parameters:*
- text (required, string) - The error message

### nil `printResult(result)`

*Description: Prints the test result onto the console using different colors for each class and method result*

*Parameters*:
- result (required, TestResultObject) - The test result object

### string `getClassResultColor(classTest)`

*Description: Returns the color for a test class that can either be green (all methods OK), yellow (at least one successfull and one failed test exists) or red (all tests failed)*

*Parameters*:
- classTest (required, ClassTestResultObject) - The class test result object