﻿#Include <toml\test\Test>

class RealWorldTest
{
    should_parse_example(){
        _toml := Toml().read(getResourceAsStream("example.toml"))
        assertEquals("TOML Example", _toml.getString("title"))
        owner := _toml.getTable("owner")
        assertEquals("Tom Preston-Werner", owner.getString("name"))
        assertEquals("GitHub", owner.getString("organization"))
        assertEquals("GitHub Cofounder & CEO`nLikes tater tots and beer.", owner.getString("bio"))
        database := _toml.getTable("database")
        assertEquals("192.168.1.1", database.getString("server"))
        assertEquals(5000, database.getLong("connection_max"))
        assertTrue(database.getBoolean("enabled"))
        assertEquals(Arrays.asList(8001, 8001, 8002), database.getList("ports"))
        servers := _toml.getTable("servers")
        alphaServers := servers.getTable("alpha")
        assertEquals("10.0.0.1", alphaServers.getString("ip"))
        assertEquals("eqdc10", alphaServers.getString("dc"))
        betaServers := servers.getTable("beta")
        assertEquals("10.0.0.2", betaServers.getString("ip"))
        assertEquals("eqdc10", betaServers.getString("dc"))
        assertEquals("中国", betaServers.getString("country"))
        clients := _toml.getTable("clients")
        assertEquals(asList(asList("gamma", "delta"), asList(1, 2)), clients.getList("data"))
        assertEquals(asList("alpha", "omega"), clients.getList("hosts"))
    }

    should_parse_hard_example()
    {
        _toml := Toml().read(getResourceAsStream("hard_example.toml"))
        assertEquals("You'll hate me after this - #", _toml.getString("the.test_string"))
        assertEquals(asList("] ", " # "), _toml.getList("the.hard.test_array"))
        assertEquals(asList("Test #11 ]proved that", "Experiment #9 was a success"), _toml.getList("the.hard.test_array2"))
        assertEquals(" Same thing, but with a string #", _toml.getString("the.hard.another_test_string"))
        assertEquals(" And when `"'s are in the string, along with # `"", _toml.getString("the.hard.harder_test_string"))
        theHardBit := _toml.getTable("the.hard.`"bit#`"")
        assertEquals("You don't think some user won't do that?", theHardBit.getString("`"what?`""))
        assertEquals(asList("]"), theHardBit.getList("multi_line_array"))
    }

    should_parse_current_version_example()
    {
        _toml := Toml().read(getResourceAsStream("example-v0.4.0.toml"))
        assertEquals("value", _toml.getString("table.key"))
        assertEquals("another value", _toml.getString("table.subtable.key"))
        assertNotNull(_toml.getTable("x.y.z").getTable("w"))
        assertEquals("Tom", _toml.getString("table.inline.name.first"))
        assertEquals("Preston-Werner", _toml.getString("table.inline.name.last"))
        assertEquals(1, _toml.getLong("table.inline.point.x"))
        assertEquals(2, _toml.getLong("table.inline.point.y"))
        ; assertEquals("pug", _toml.getString("dog.tater.type"))
        assertEquals("I'm a string. `"You can quote me`". Name`tJosé`nLocation`tSF.", _toml.getString("string.basic.basic"))
        assertEquals("One`nTwo", _toml.getString("string.multiline.key3"))
        assertEquals(_toml.getString("string.multiline.key3"), _toml.getString("string.multiline.key1"))
        assertEquals(_toml.getString("string.multiline.key3"), _toml.getString("string.multiline.key2"))
        assertEquals("The quick brown fox jumps over the lazy dog.", _toml.getString("string.multiline.continued.key1"))
        assertEquals("The quick brown fox jumps over the lazy dog.", _toml.getString("string.multiline.continued.key2"))
        assertEquals(_toml.getString("string.multilined.singleline.key3"), _toml.getString("string.multilined.singleline.key1"))
        assertEquals(_toml.getString("string.multilined.singleline.key3"), _toml.getString("string.multilined.singleline.key2"))
        assertEquals("C:\Users\nodejs\templates", _toml.getString("string.literal.winpath"))
        assertEquals("\\ServerX\admin$\system32\", _toml.getString("string.literal.winpath2"))
        assertEquals("Tom `"Dubs`" Preston-Werner", _toml.getString("string.literal.quoted"))
        assertEquals("<\i\c*\s*>", _toml.getString("string.literal.regex"))
        assertEquals("I [dw]on't need \d{2} apples", _toml.getString("string.literal.multiline.regex2"))
        assertEquals("The first newline is`ntrimmed in raw strings.`n   All other whitespace`n   is preserved.`n", _toml.getString("string.literal.multiline.lines"))
        assertEquals(99, _toml.getLong("integer.key1"))
        assertEquals(42, _toml.getLong("integer.key2"))
        assertEquals(0, _toml.getLong("integer.key3"))
        assertEquals(-17, _toml.getLong("integer.key4"))
        assertEquals(1000, _toml.getLong("integer.underscores.key1"))
        assertEquals(5349221, _toml.getLong("integer.underscores.key2"))
        assertEquals(12345, _toml.getLong("integer.underscores.key3"))
        assertEquals(1.0, _toml.getDouble("float.fractional.key1"))
        assertEquals(3.1415, _toml.getDouble("float.fractional.key2"))
        assertEquals(-0.01, _toml.getDouble("float.fractional.key3"))
        assertEquals(5e+22, _toml.getDouble("float.exponent.key1"))
        assertEquals(1e6, _toml.getDouble("float.exponent.key2"))
        assertEquals(-2E-2, _toml.getDouble("float.exponent.key3"))
        assertEquals(6.626e-34, _toml.getDouble("float.both.key"))
        assertTrue(_toml.getBoolean("boolean.True"))
        assertFalse(_toml.getBoolean("boolean.False"))
        assertThat(_toml.getList("array.key1"), Matchers.contains(1, 2, 3))
        assertThat(_toml.getList("array.key2"), Matchers.contains("red", "yellow", "green"))
        assertEquals(asList(asList(1, 2), asList(3, 4, 5)), _toml.getList("array.key3"))
        assertEquals(asList(asList(1, 2), asList("a", "b", "c")), _toml.getList("array.key4"))
        assertThat(_toml.getList("array.key5"), Matchers.contains(1, 2, 3))
        assertThat(_toml.getList("array.key6"), Matchers.contains(1, 2))
        assertEquals("Hammer", _toml.getString("products[0].name"))
        assertEquals(738594937, _toml.getLong("products[0].sku"))
        assertNotNull(_toml.getTable("products[1]"))
        assertEquals("Nail", _toml.getString("products[2].name"))
        assertEquals(284758393, _toml.getLong("products[2].sku"))
        assertEquals("gray", _toml.getString("products[2].color"))
        assertEquals("apple", _toml.getString("fruit[0].name"))
        assertEquals("red", _toml.getString("fruit[0].physical.color"))
        assertEquals("round", _toml.getString("fruit[0].physical.shape"))
        assertEquals("red delicious", _toml.getString("fruit[0].variety[0].name"))
        assertEquals("granny smith", _toml.getString("fruit[0].variety[1].name"))
        assertEquals("banana", _toml.getString("fruit[1].name"))
        assertEquals("plantain", _toml.getString("fruit[1].variety[0].name"))
    }

    should_allow_keys_with_same_name_in_different_tables()
    {
        _toml := Toml().read(getResourceAsStream("should_allow_keys_with_same_name_in_different_tables.toml"))
        assertTrue(_toml.getTable("siteInfo.local.sh").getBoolean("enable"))
        assertFalse(_toml.getTable("siteInfo.localMobile.sh").getBoolean("enable"))
    }
    
    static testAll()
    {
        _test := RealWorldTest()
        _test.should_parse_example()
        _test.should_parse_hard_example()
        _test.should_parse_current_version_example()
        _test.should_allow_keys_with_same_name_in_different_tables()
    }
}
