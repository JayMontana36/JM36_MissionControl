local DummyCmdTbl = {};_G2.DummyCmdTbl=DummyCmdTbl
local MenuLayout = {};Info.MenuLayout=MenuLayout



local MenuMain = menu.my_root()
MenuLayout.Main = MenuMain



MenuLayout.World = MenuMain:list("World Related Options", DummyCmdTbl, "")
