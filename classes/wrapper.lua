QhunUnitTest.Wrapper = {}

-- constructor
--[[
    {
        -- any wrappable instance
        -- should be a class or at least a table
        instance: {? extends {}}
    }
]]
function QhunUnitTest.Wrapper.new(instance)
    -- private properties
    local instance = {
        _instance = instance,
        --[[
            {
                [functionName: string]: {
                    parameter: {...}
                }[]
            }
        ]]
        _calledFunctions = {}
    }

    setmetatable(instance, QhunUnitTest.Wrapper)
    return instance
end

-- wrapp every function call and record the calls
function QhunUnitTest.Wrapper:__index(calledFunctionName, ...)
    -- include wrapper class specific functions here
    local wrapperFunctions = {
        -- get the amount of calls to the given method
        --[[
            {
                methodName: string
            }
            returns number
        ]]
        __unittest_getMethodCallAmount = function(_, methodName)
            if type(self._calledFunctions[methodName]) ~= "table" then
                return 0
            end
            return #self._calledFunctions[methodName]
        end,
        -- get all function calls to the given method name
        --[[
            {
                methodName: string
            }
            returns {
                parameter: {...}
            }[]
        ]]
        __unittest_getAllMethodCalls = function(_, methodName)
            return self._calledFunctions[methodName]
        end
    }

    local fktnAccessor = wrapperFunctions[calledFunctionName]

    -- if the method is available at wrapper level call it,
    -- if not, look for the method in the wrapped instance
    if type(fktnAccessor) == "function" then
        return fktnAccessor
    end

    -- return the wrapped function
    local destination = self._instance[calledFunctionName]

    if type(destination) == "function" then
        return function(object, ...)
            -- record the call and all parameter
            if type(self._calledFunctions[calledFunctionName]) ~= "table" then
                self._calledFunctions[calledFunctionName] = {}
            end

            table.insert(
                self._calledFunctions[calledFunctionName],
                {
                    parameter = {...}
                }
            )

            -- pass the parameters to the destination function
            return self._instance[calledFunctionName](object, ...)
        end
    else
        -- it is a property, return it
        return destination
    end
end
