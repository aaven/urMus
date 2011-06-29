-- urPlayground.lua
-- modified by Aaven
-- integrate with urMenu.lua
-- TODO overlap

FreeAllRegions()

local regions = {}

recycledregions = {}

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
    region:Show()
    region:EnableMoving(true)
    region:EnableResizing(true)
    region:EnableInput(true)
    region.bkg = {}
    region.stickee = {} -- store the ids of objects that sticks to it
    region.sticker = -1 -- store the ids of objects it sticks to
    
    DPrint("R#"..region.id.." created")
    return region
end



MIN_WIDTH_MENU = 100
MAX_WIDTH_MENU = 200
MAX_NUM_MENU_OPT = 20
HEIGHT_MENU_OPT = 30
NUM_MENU_OPTION = 7 -- MenuCancel is not needed anymore
INDEX_STICK_MENU = 5

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

function MenuRecycleSelf(self) -- remove object    
    MenuUnstick(self)
    
    self.parent.caller:EnableInput(false)
    self.parent.caller:EnableMoving(false)
    self.parent.caller:EnableResizing(false)
    self.parent.caller:Hide()

    table.insert(recycledregions, self.parent.caller)
    for k,v in pairs(regions) do
        if v == self.parent.caller then
            regions[k].usable = 0
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
    local flag = 0
    if er ~= -1 then -- it is sticked to other
        output = output.."a: R#"..er.." releases R#"..self.parent.caller.id..". "
        regions[er].stickee = -1
        self.parent.caller.sticker = -1
        self.parent.caller:SetAnchor("BOTTOMLEFT",UIParent,"BOTTOMLEFT",0,0)
        self.parent.caller:EnableMoving(true)
        self.parent.caller:EnableInput(true)
        self.parent.caller:EnableResizing(true)
        flag = 1
    end
    if (#self.parent.caller.stickee > 0) then
        output = output.."b: R#"..self.parent.caller.id.." releases"
        flag = 1
        for k,ee in pairs(self.parent.caller.stickee) do -- other is sticked to it
            output = output.." R#"..ee
            regions[ee].sticker = -1
            regions[ee]:SetAnchor("BOTTOMLEFT",UIParent,"BOTTOMLEFT",0,0)
            regions[ee]:EnableMoving(true)
            regions[ee]:EnableInput(true)
            regions[ee]:EnableResizing(true)
        end
        while #self.parent.caller.stickee > 0 do
            table.remove(self.parent.caller.stickee,1)
        end
    end
    
    if flag == 0 then
        DPrint("R#"..self.parent.caller.id.." nothing to unstick")
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
function Menu:CreateOption(name,background,w,h,func)
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
    opt:SetWidth(w)
    opt:SetHeight(h)
    opt.t = opt:Texture()
    opt.t:SetTexture(background) -- TODO how to fill rgb value
    opt.t:SetBlendMode("BLEND")
    opt:Handle("OnTouchDown",func)
    
    return opt
end

function OpenOrCloseMenu(self) -- open/close menu
    if self.menu.open == 0 then
        OpenMenu(self.menu)
    else 
        CloseMenu(self.menu)
    end
    
end

-- caller has width and height
function Menu.Create(region,background,optionList,funcionList,numOptions)
    
    if numOptions > MAX_NUM_MENU_OPT or numOptions <= 0 then
        return -1
    end
    
    local menu = {}
    setmetatable(menu,Menu)
    local len = 0
    local w
    local h = HEIGHT_MENU_OPT
    menu.caller = region
    menu.num = numOptions
    menu.bkg = background
    
    for i = 1,numOptions do
        if len < string.len(optionList[i]) then
            len = string.len(optionList[i])
        end
    end
    
    if len <= 10 then
        w = MIN_WIDTH_MENU
    elseif len >= 20 then -- TODO too long name cant be displayed
        w = MAX_WIDTH_MENU
    else
        w = len*10
    end

    for i = 1,numOptions do
        -- create an option
        local opt = menu:CreateOption(optionList[i],background,w,h,funcionList[i])
        
        opt:SetAnchor("TOPLEFT",menu.caller,"TOPRIGHT",0,(1-i)*h)
        opt.parent[i] = opt
        opt:Hide()
    end
    
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

function TouchDown(self)
    checkOpenMenu(0)
    
    local region = CreateorRecycleregion('region', 'backdrop', UIParent)
    local x,y = InputPosition()
    region:SetAnchor("CENTER",x,y)
    
    region.menu = Menu.Create(region,"Sequence 01026.png",txt,tap,NUM_MENU_OPTION)
    region.menu.open = 0 -- open is 1, close is 0
    -- child menu for Stick
    local anchorTap = {setAnchorTR,setAnchorTL,setAnchorLT,setAnchorLB,setAnchorBL,setAnchorBR,setAnchorRB,setAnchorRT,setAnchorCancel}
    region.menu[INDEX_STICK_MENU].menu = Menu.Create(region.menu[INDEX_STICK_MENU],"Sequence 01008.png",Anchors,anchorTap,9)
    region.menu[INDEX_STICK_MENU].menu.open = 0 -- open is 1, close is 0
    region.menu[INDEX_STICK_MENU].bkg = {}
    region:Handle("OnDoubleTap",OpenOrCloseMenu)
    region:Handle("OnTouchDown",SelectObj)
    region:Handle("OnDragStart",StartMove)
    region:Handle("OnDragStop",StopMove)
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

------------------------------------------------------------------
pagebutton=Region('region', 'pagebutton', UIParent);
pagebutton:SetWidth(pagersize);
pagebutton:SetHeight(pagersize);
pagebutton:SetLayer("TOOLTIP");
pagebutton:SetAnchor('BOTTOMLEFT',ScreenWidth()-pagersize-4,ScreenHeight()-pagersize-4); 
pagebutton:EnableClamping(true)
--pagebutton:Handle("OnDoubleTap", FlipPage)
pagebutton:Handle("OnTouchDown", FlipPage)
pagebutton.texture = pagebutton:Texture("circlebutton-16.png");
pagebutton.texture:SetGradientColor("TOP",255,255,255,255,255,255,255,255);
pagebutton.texture:SetGradientColor("BOTTOM",255,255,255,255,255,255,255,255);
pagebutton.texture:SetBlendMode("BLEND")
pagebutton.texture:SetTexCoord(0,1.0,0,1.0);
pagebutton:EnableInput(true);
pagebutton:Show();
--pagebutton:Handle("OnPageEntered", nil)

​