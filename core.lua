-- make the slash command api available to the wow ui
SLASH_qhunUnitTest1 = "/test"
SLASH_qhunUnitTest2 = "/qut"
SLASH_qhunUnitTest3 = "/qhununittest"

-- the event handler for slash commands
function SlashCmdList.qhunUnitTest(message)
    local suite = message:match("^(%S*)%s*(.-)$")

    -- get all suites
    local suites = QhunUnitTest.Suite.getAllSlashCommandSuites()

    -- check if the suite is available
    if suites[suite] ~= nil then
        local result = suites[suite]:run()

        -- print the result to the console
        return suites[suite]:printResult(result)
    end

    print('|c00ff0000The given TestSuite with name "' .. suite .. '" is not available or registered!')
end
