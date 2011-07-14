-- urStick.lua
-- by Aaven, Jun 2011
-- based on urMenu.lua and urPlayground.lua

MIN_WIDTH_MENU = 100
MAX_WIDTH_MENU = 200
MAX_NUM_MENU_OPT = 20
HEIGHT_MENU_OPT = 30
NUM_MENU_OPTION = 7 -- MenuCancel is not needed anymore
INDEX_STICK_MENU = 5

STICK_MARGIN = 20
HEIGHT_LINE = 30

FreeAllRegions()

local regions = {}

recycledregions = {}

anchorTap = {setAnchorTR,setAnchorTL,setAnchorLT,setAnchorLB,setAnchorBL,setAnchorBR,setAnchorRB,setAnchorRT,setAnchorCancel}
Anchors = {"TOPRIGHT","TOPLEFT","LEFTTOP","LEFTBOTTOM","BOTTOMLEFT","BOTTOMRIGHT","RIGHTBOTTOM","RIGHTTOP","CANCEL"}
anchor_position = Anchors[9]
rel_anchor_position = Anchors[9]
sticky = 0 
sticker = -1 -- store the id of an object
menu_opened = 0
menu_caller_id = -1

function CreateorRecycleregion(ftype, name, parent)
    local region
    if #recycledregions > 0 then
        region = recycledregions[#recycledregions]
        table.remove(recycledregions)
        regions[region.id].usable = 1
    else
        region = Region(ftype, name, parent)
        region.t = region:Texture()
        table.insert(regions,region)
        region.id = #regions
        region.usable = 1
    end
    
    region.t:SetTexture(255,255,255,255)
    region:SetWidth(200)
    region:SetHeight(200)
    region:Show()
    region:EnableMoving(true)
    region:EnableResizing(true)
    region:EnableInput(true)
    region.bkg = {}
    region.position = {"right",0}
    region.stickee = {} -- store the ids of objects that sticks to it
    region.sticker = -1 -- store the ids of objects it sticks to
    
    x,y = InputPosition()
    DPrint("R#"..region.id.." created, centered at "..x.." "..y)
    return region
end


DPrint("Welcome to urMenu =)")

function MenuAbout(self)
    output = "R#"..self.parent.caller.id..", sticker #"..self.parent.caller.sticker..", stickees"
    if #self.parent.caller.stickee == 0 then
        output = output.." #-1"
    else
        for k,ee in pairs (self.parent.caller.stickee) do
            output = output.." #"..ee
        end
    end
    DPrint(output)
    MenuClose(self)
end

function MenuPictureRandomly(self)
    self.parent.caller.bkg = pics[math.random(1,5)]
    self.parent.caller.t:SetTexture(self.parent.caller.bkg)
    DPrint("R#"..self.parent.caller.id.." background pic: "..self.parent.caller.bkg)
end

function MenuColorRandomly(self)
    DPrint("R#"..self.parent.caller.id.." change color")
    self.parent.caller.t:SetSolidColor(math.random(0,255),math.random(0,255),math.random(0,255),255)
end

function MenuClearToWhite(self)
    DPrint("R#"..self.parent.caller.id.." clear to white")
    self.parent.caller.t:SetTexture(255,255,255,255) -- TODO original texture not removed
    self.parent.caller.t:SetSolidColor(255,255,255,255)
    MenuClose(self)
end

function OpenMenu(menu) -- call by menu
    for i = 1,menu.num do
        menu[i]:Show()
        menu[i]:EnableInput(true)
        menu[i]:MoveToTop()
    end
    menu.open = 1
    menu_opened =  1
    menu_caller_id = menu.caller.id
end

function CloseMenu(menu) -- call by menu
    for i = 1,menu.num do
        menu[i]:Hide()
        menu[i]:EnableInput(false)
        if menu[i].menu ~= "" then
            if menu[i].menu.open == 1 then
                CloseMenu(menu[i].menu)
            end
        end
    end
    menu.open = 0
    menu_opened = 0
    menu_caller_id = -1
end

function MenuClose(self) -- call by menu option
    CloseMenu(self.parent)
end

function SetDefaultRegion(r)
    r.bkg = {}
    r.t:SetTexture(255,255,255,255)
    r.t:SetSolidColor(255,255,255,255)
    r.sticker = -1
    r.stickee = {}
    r.menu.open = 0
    r.usable = 0
end

function MenuRecycleSelf(self) -- remove object    
    MenuUnstick(self)
    
    self.parent.caller:EnableInput(false)
    self.parent.caller:EnableMoving(false)
    self.parent.caller:EnableResizing(false)
    self.parent.caller:Hide()
    SetDefaultRegion(self.parent.caller)

    table.insert(recycledregions, self.parent.caller)
    for k,v in pairs(regions) do
        if v == self.parent.caller then
       --     regions[k].usable = 0
        end
    end
    
    DPrint("R#"..self.parent.caller.id.." removed")
    MenuClose(self)
end

function checkOpenMenu(id)
    if menu_opened ~= 0 then
        if menu_caller_id ~= id and sticky ~= -1 then
            CloseMenu(regions[menu_caller_id].menu)
        end
    end
end

function StickHelper(self)
    sticky = 1
    
    MenuClose(self)
    MenuClose(self.parent.caller)
    DPrint("Please select an object to stick to R#"..sticker)
end

function setAnchorTR(self)
    anchor_position = "BOTTOMRIGHT"
    rel_anchor_position = "TOPRIGHT"
    StickHelper(self)
end

function setAnchorTL(self)
    anchor_position = "BOTTOMLEFT"
    rel_anchor_position = "TOPLEFT"
    StickHelper(self)
end

function setAnchorLT(self)
    anchor_position = "TOPRIGHT"
    rel_anchor_position = "TOPLEFT"
    StickHelper(self)
end

function setAnchorLB(self)
    anchor_position = "BOTTOMRIGHT"
    rel_anchor_position = "BOTTOMLEFT"
    StickHelper(self)
end

function setAnchorBL(self)
    anchor_position = "TOPLEFT"
    rel_anchor_position = "BOTTOMLEFT"
    StickHelper(self)
end

function setAnchorBR(self)
    anchor_position = "TOPRIGHT"
    rel_anchor_position = "BOTTOMRIGHT"
    StickHelper(self)
end

function setAnchorRB(self)
    anchor_position = "BOTTOMLEFT"
    rel_anchor_position = "BOTTOMRIGHT"
    StickHelper(self)
end

function setAnchorRT(self)
    anchor_position = "TOPLEFT"
    rel_anchor_position = "TOPRIGHT"
    StickHelper(self)
end

function setAnchorCancel(self)
    anchor_position = Anchors[9]
    rel_anchor_position = Anchors[9]
    StickHelper(self)
    sticker = -1
    sticky = 0
end

function MenuStick(self)
    DPrint("R#"..self.parent.caller.id.." wait to stick")
    
    if table.getn(regions)-table.getn(recycledregions) <= 1 then
        DPrint("R#"..self.parent.caller.id.." Stick Fail: No other object to enable stick.")
        if self.parent.open == 1 then
            CloseMenu(self.parent)
        end
    else 
        if self.menu.open == 0 then
            sticker = self.parent.caller.id
            DPrint("R#"..self.parent.caller.id.." Please select an anchor position for #R "..sticker)
            OpenMenu(self.menu) --open sub menu
        else 
            CloseMenu(self.menu) --close sub menu
        end
    end
    
end

function MenuUnstick(self)
    output = ""
    local er = self.parent.caller.sticker
    local id = self.parent.caller.id
    local flag = 0
    if er ~= -1 then -- it is sticked to other
        output = output.."a: R#"..er.." releases R#"..id..". "
        for k,ee in pairs(regions[er].stickee) do
            if ee == id then
                table.remove(regions[er].stickee,k)
            end
        end
        self.parent.caller.sticker = -1
        self.parent.caller:SetAnchor("BOTTOMLEFT",UIParent,"BOTTOMLEFT",0,0)
        self.parent.caller:EnableMoving(true)
        self.parent.caller:EnableInput(true)
        self.parent.caller:EnableResizing(true)
        self.parent.caller.group = id
        flag = 1
    end
    if (#self.parent.caller.stickee > 0) then
        output = output.."b: R#"..id.." releases"
        flag = 1
        for k,ee in pairs(self.parent.caller.stickee) do -- other is sticked to it
            output = output.." R#"..ee
            regions[ee].sticker = -1
            regions[ee]:SetAnchor("BOTTOMLEFT",UIParent,"BOTTOMLEFT",0,0)
            regions[ee]:EnableMoving(true)
            regions[ee]:EnableInput(true)
            regions[ee]:EnableResizing(true)
            regions[ee].group = regions[ee].id
        end
        while #self.parent.caller.stickee > 0 do
            table.remove(self.parent.caller.stickee,1)
        end
    end
    
    if flag == 0 then
        DPrint("R#"..id.." nothing to unstick")
    else
        DPrint(output)
    end
    MenuClose(self)
end

function DoStick(stickee)
    -- stick id(sticker and its stickee list)
    if anchor_position == Anchors[9] or rel_anchor_position == Anchors[9] then
        DPrint("R#"..sticker.." cancel Stick")
    else
        table.insert(regions[sticker].stickee,stickee)
        regions[stickee].sticker = sticker
        regions[stickee]:SetAnchor(anchor_position,regions[sticker],rel_anchor_position,0,0)
        regions[stickee]:EnableMoving(false)
        output = "sticker R#"..sticker.." now has stickees: "
        for k,ee in pairs(regions[sticker].stickee) do
            output = output.." R#"..ee
        end
        DPrint(output)
    end
end

function MoveMenuToTop(menu) 
    if menu.open == 1 then
        for i = 1,menu.num do
            menu[i]:MoveToTop()
            if menu[i].menu ~= "" then
                if menu[i].menu.open == 1 then
                    MoveMenuToTop(menu[i].menu)
                end
            end
        end
    end
end

function SelectObj(self)
    DPrint("R#"..self.id.." selected")
    self:MoveToTop()
    checkOpenMenu(self.id)
    MoveMenuToTop(self.menu)
    
    if sticky == 1 then
        if sticker == self.stickee and sticker ~= -1 then
            DPrint("R#"..self.id..". Sticke Fail: Cannot stick to stickee. R#"..sticker.." is already R#"..self.id.."'s stickee.")
        elseif self.sticker == sticker and sticker ~= -1 then
            DPrint("R#"..self.id..". Sticke Fail: Duplicate."..sticker.." is already R#"..self.id.."'s sticker.")
        elseif sticker == -1 then
            DPrint("R#"..self.id..". Error: this is impossible")
        elseif self.sticker ~= -1 then
            DPrint("R#"..self.id..". Stick Fail: R#"..self.id.." is already sticked to R#"..self.sticker)
        elseif sticker == self.id then
            DPrint("R#"..self.id..". Stick Fail: Cannot stick to itself.")
        else
            DoStick(self.id)
        end 
        sticker = -1
        sticky = 0
    end
end

------Menu Class------
Menu = {}
Menu.__index = Menu
function Menu:CreateOption(name,background,func)
    local opt = Region() 
    opt.parent = self
    opt.type = name
    opt.menu = ""
    opt.tl = opt:TextLabel()
    opt.tl:SetLabel(name)
    opt.tl:SetFontHeight(14)
    opt.tl:SetColor(0,0,0,255) 
    opt.tl:SetHorizontalAlign("JUSTIFY")
    opt.tl:SetShadowColor(255,255,255,255)
    opt.tl:SetShadowOffset(1,1)
    opt.tl:SetShadowBlur(1)
    opt:SetWidth(self.w)
    opt:SetHeight(self.h)
    opt.t = opt:Texture()
    opt.t:SetTexture(background) -- TODO how to fill rgb value
    opt.t:SetBlendMode("BLEND")
    opt:Handle("OnTouchDown",func)
    
    return opt
end

function OpenOrCloseMenu(self) -- open/close menu, call by region
    if self.menu.open == 0 then
    	DPrint("open menu")
        OpenMenu(self.menu)
    else 
    	DPrint("close menu")
        CloseMenu(self.menu)
    end
end

function AnchorMenu(menu)
	if menu.position[1] == "right" then
		--DPrint("menu to the right")
		menu[1]:SetAnchor("TOPLEFT",menu.caller,"TOPRIGHT",menu.position[2],menu.position[3])
	else 
		--DPrint("menu to the left")
		menu[1]:SetAnchor("TOPRIGHT",menu.caller,"TOPLEFT",menu.position[2],menu.position[3])
	end
end

function Menu.Create(region,background,optionList,funcionList,numOptions,side,offsetx,offsety)
-- side:left or right. offsets are for menu position
    
    if numOptions > MAX_NUM_MENU_OPT or numOptions <= 0 then
        return -1
    end
    
    local menu = {}
    setmetatable(menu,Menu)
    local len = 0
    menu.h = HEIGHT_MENU_OPT
    menu.caller = region
    menu.num = numOptions
    menu.bkg = background
    menu.position = {side,offsetx,offsety} -- first parameter: left/right. second parameter: offset
	menu.open = 0
    
    for i = 1,numOptions do
        if len < string.len(optionList[i]) then
            len = string.len(optionList[i])
        end
    end
    
    if len <= 10 then
        menu.w = MIN_WIDTH_MENU
    elseif len >= 20 then -- TODO too long name cant be displayed
        menu.w = MAX_WIDTH_MENU
    else
        menu.w = len*10
    end
	
	topOpt = menu:CreateOption(optionList[1],background,funcionList[1])
	topOpt.parent[1] = topOpt
    for i = 2,numOptions do
        -- create an option
        local prev = menu[i-1]
        local opt = menu:CreateOption(optionList[i],background,funcionList[i])
        opt:SetAnchor("TOPLEFT",prev,"BOTTOMLEFT")
        opt.parent[i] = opt
        opt:Hide()
    end
    AnchorMenu(menu)
    topOpt:Hide()
    
    return menu
end
    
txt = {"About","Random pic","Random color","Clear","Stick","Unstick","Remove","Cancel"}
pics = {"vinyl.png","Ornament1.png","Pirate1.png","Play.png","Right.png"}
tap = {MenuAbout,MenuPictureRandomly, MenuColorRandomly, MenuClearToWhite, MenuStick, MenuUnstick, MenuRecycleSelf, MenuClose}

function StartMove(self)
    DPrint("in startmove")
    self:MoveToTop()
    if self.menu.open == 1 then
        DPrint("startmove w menu")
        CloseMenu(self.menu)
    end
end

function StopMove(self)
--    DPrint("stopmove")
end

SixteenPositions = {} -- SixteenPositions[p1][p2]: ee:SetAnchor(p2,er,p1)
function InitializeUrStick() -- 
	local k = 1
	for i = 1,4 do
		SixteenPositions[i] = {}
	end
	SixteenPositions[1][4] = {"TOPLEFT","BOTTOMRIGHT"}
	SixteenPositions[2][4] = {"TOPLEFT","BOTTOMLEFT"}
	SixteenPositions[3][4] = {"TOPRIGHT","BOTTOMRIGHT"}
	SixteenPositions[4][4] = {"TOPRIGHT","BOTTOMLEFT"}
	SixteenPositions[1][3] = {"TOPLEFT","TOPRIGHT"}
	SixteenPositions[2][3] = {"TOPLEFT","TOPLEFT"}
	SixteenPositions[3][3] = {"TOPRIGHT","TOPRIGHT"}
	SixteenPositions[4][3] = {"TOPRIGHT","TOPLEFT"}
	SixteenPositions[1][2] = {"BOTTOMLEFT","BOTTOMRIGHT"}
	SixteenPositions[2][2] = {"BOTTOMLEFT","BOTTOMLEFT"}
	SixteenPositions[3][2] = {"BOTTOMRIGHT","BOTTOMRIGHT"}
	SixteenPositions[4][2] = {"BOTTOMRIGHT","BOTTOMLEFT"}
	SixteenPositions[1][1] = {"BOTTOMLEFT","TOPRIGHT"}
	SixteenPositions[2][1] = {"BOTTOMLEFT","TOPLEFT"}
	SixteenPositions[3][1] = {"BOTTOMRIGHT","TOPRIGHT"}
	SixteenPositions[4][1] = {"BOTTOMRIGHT","TOPLEFT"}
end

InitializeUrStick()

function StickToClosestAnchorPoint(ee,er)
	local hw = er:Width()/2
	local hh = er:Height()/2
	local eex,eey = ee:Center()
	local erx = er:Left()
	local ery = er:Bottom()
	local dx = math.ceil((eex - erx)/hw) + 1
	local dy = math.ceil((eey - ery)/hh) + 1
	if dx > 4 then dx = 4 end
	if dx < 1 then dx = 1 end
	if dy > 4 then dy = 4 end
	if dy < 1 then dy = 1 end

	ee:SetAnchor(SixteenPositions[dx][dy][2],er,SixteenPositions[dx][dy][1])
	table.insert(er.stickee,ee.id)
    ee.sticker = er.id
    ee:EnableMoving(false)

	output = SixteenPositions[dx][dy][1].."+"..SixteenPositions[dx][dy][2].." new stickee R#"..ee.id.."! sticker R#"..sticker.." now has stickees: "
    for k,i in pairs(er.stickee) do
        output = output.." R#"..i
    end
    DPrint(output)
end

function AutoCheckStick(self)
	DPrint("in AutoCheckStick")
	local large = Region()
	local x = self:Left() - STICK_MARGIN
	local y = self:Top() + STICK_MARGIN
	large:SetWidth(self:Width() + STICK_MARGIN * 2)
	large:SetHeight(self:Height() + STICK_MARGIN * 2)
	large:SetAnchor("TOPLEFT",x,y)
	
	for k,v in pairs (regions) do -- v is sticker, self is stickee
		if v ~= self and v.usable == 1 then
			DPrint("there are other regions")
			if v.sticker ~= self.id and self.sticker ~= v.id and v.group ~= self.group then
				DPrint("there are other regions to stick to")
				if v:RegionOverlap(large) then
					DPrint("they overlap")
					if	not v:RegionOverlap(self) then
						StickToClosestAnchorPoint(self,v)
						self.group = v.group
					end
				end
			end
		end
	end
end

function UpdateMenuPosition(self)
	if self:Right() + self.menu.w > ScreenWidth() then
		self.menu.position[1] = "left"
	else
		self.menu.position[1] = "right"
	end
	
	if self:Top() > ScreenHeight() then
		self.menu.position[3] = ScreenHeight() - self:Top()
	elseif self:Top() < self.menu.num * self.menu.h then
		self.menu.position[3] = self.menu.num * self.menu.h - self:Top()
	else
		self.menu.position[3] = 0
	end
	
	AnchorMenu(self.menu)
end

function RegionTouchUp(self)
	UpdateMenuPosition(self)
	AutoCheckStick(self)
end

function TouchDown(self)
    checkOpenMenu(0)
    
    local region = CreateorRecycleregion('region', 'backdrop', UIParent)
    local x,y = InputPosition()
    region:SetAnchor("CENTER",x,y)
    txt[1] = "R#"..region.id.." About"
    region.menu = Menu.Create(region,"Sequence 01026.png",txt,tap,NUM_MENU_OPTION,"right",0,0)
    -- child menu for Stick
    
    region.menu[INDEX_STICK_MENU].menu = Menu.Create(region.menu[INDEX_STICK_MENU],"Sequence 01008.png",Anchors,anchorTap,9,"right",0,0)
    region.menu[INDEX_STICK_MENU].menu.open = 0 -- open is 1, close is 0
    region.menu[INDEX_STICK_MENU].bkg = {}
    region.tl = region:TextLabel()
    region.tl:SetLabel("R#"..region.id)
    region.tl:SetFontHeight(16)
    region.tl:SetColor(0,0,0,255) 
    region.tl:SetHorizontalAlign("JUSTIFY")
    region.tl:SetShadowColor(255,255,255,255)
    region.tl:SetShadowOffset(1,1)
    region.tl:SetShadowBlur(1)
    region.group = region.id
    region:Handle("OnDoubleTap",OpenOrCloseMenu)
    region:Handle("OnTouchDown",SelectObj)
    region:Handle("OnDragStart",StartMove)
    region:Handle("OnDragStop",StopMove)
    region:Handle("OnTouchUp",RegionTouchUp)
end

function TouchUp(self)
--    DPrint("MU")
end

function DoubleTap(self)
--    DPrint("DT")
end

function Enter(self)
--    DPrint("EN")
end

function Leave(self)
--    DPrint("LV")
end

backdrop = Region('region', 'backdrop', UIParent)
backdrop:SetWidth(ScreenWidth())
backdrop:SetHeight(ScreenHeight())
backdrop:SetLayer("BACKGROUND")
backdrop:SetAnchor('BOTTOMLEFT',0,0)
backdrop:Handle("OnTouchDown", TouchDown)
backdrop:Handle("OnTouchUp", TouchUp)
backdrop:Handle("OnDoubleTap", DoubleTap)
backdrop:Handle("OnEnter", Enter)
backdrop:Handle("OnLeave", Leave)
backdrop:EnableInput(true)
backdrop:SetClipRegion(0,0,ScreenWidth(),ScreenHeight()-HEIGHT_LINE)
backdrop:EnableClipping(true)

function SlideOpenMenu(self)
	self.menu.open = 1
	for i = 1,self.menu.num do
        self.menu[i]:Show()
        self.menu[i]:EnableInput(true)
        self.menu[i]:MoveToTop()
    end
    self.menu.open = 1
end

modetxt = {"mode1","mode2","mode3"}
modefunc = {f1,f1,f1}
function f1()
end
space = Region()
space:SetWidth(ScreenWidth())
space:SetHeight(HEIGHT_LINE)
space:SetAnchor("TOPLEFT",UIParent,"TOPLEFT")
space.tl = space:TextLabel()
space.tl:SetLabel("Mode")
space.tl:SetFontHeight(16)
space.tl:SetColor(0,0,0,255) 
space.tl:SetHorizontalAlign("JUSTIFY")
space.tl:SetShadowColor(255,255,255,255)
space.tl:SetShadowOffset(1,1)
space.tl:SetShadowBlur(1)
space.t = space:Texture()
space.t:SetTexture(200,200,200,255)
space:Show()
space.menu = Menu.Create(space,"",modetxt,modefunc,3,"right",-1*ScreenWidth(),0)
space:EnableInput(true)
space:Handle("OnTouchDown",SlideOpenMenu)
--space:Handle("OnTouchUp",SlideCloseMenu)

function HoldToTrigger(self, elapsed)
	self.holdtime = self.holdtime - elapsed
	if self.holdtime <= 0 then
		-- trigger
		DPrint("trigger!")
	end
end

function HoldTrigger(self)
       self.holdtime = 3
       self:Handle("OnUpdate", HoldToTrigger)
end

function DeTrigger(self)
       self:Handle("OnUpdate",nil)
end

space:Handle("OnTouchDown",HoldTrigger)
space:Handle("OnTouchUp", DeTrigger)

------------------------------------------------------------------
pagebutton=Region('region', 'pagebutton', UIParent);
pagebutton:SetWidth(pagersize);
pagebutton:SetHeight(pagersize);
pagebutton:SetLayer("TOOLTIP");
pagebutton:SetAnchor('BOTTOMLEFT',ScreenWidth()-pagersize-4,ScreenHeight()-pagersize-4); 
pagebutton:EnableClamping(true)
pagebutton:Handle("OnTouchDown", FlipPage)
pagebutton.texture = pagebutton:Texture("circlebutton-16.png");
pagebutton.texture:SetGradientColor("TOP",255,255,255,255,255,255,255,255);
pagebutton.texture:SetGradientColor("BOTTOM",255,255,255,255,255,255,255,255);
pagebutton.texture:SetBlendMode("BLEND")
pagebutton.texture:SetTexCoord(0,1.0,0,1.0);
pagebutton:EnableInput(true);
pagebutton:Show();