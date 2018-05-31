-- create a test suite
local suite = QhunUnitTest.Suite.new("QhunUnitTest")

-- register all known unit tests
suite:registerClass("Base", QhunUnitTest.Test.Base.new())
suite:registerClass("BaseAssert", QhunUnitTest.Test.BaseAssert.new())

-- register for slash
suite:registerForSlashCommand()