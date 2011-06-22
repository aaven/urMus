-- urPlayground.lua
-- modified by Aaven
-- integrate with urMenu.lua
-- TODO overlap

FreeAllRegions()

local regions = {}

recycledregions = {}

function CreateorRecycleregion(ftype, name, parent)
    local region
    if #recycledregions > 0 then
        region = recycledregions[#recycledregions]
        table.remove(recycledregions)
    else
        region = Region('region', 'backdrop', UIParent)
        region.t = region:Texture()
    end
    return region
end



MIN_WIDTH_MENU = 100
MAX_WIDTH_MENU = 200
MAX_NUM_MENU_OPT = 20
HEIGHT_MENU_OPT = 30
NUM_MENU_OPTION = 6

DPrint("Welcome to urMenu!")

function MenuPictureRandomly(self)
    self.parent.caller.bkg = pics[math.random(1,5)]
    self.parent.caller.t:SetTexture(self.parent.caller.bkg)
    DPrint("background pic: "..self.parent.caller.bkg)
end

function MenuColorRandomly(self)
    DPrint("in MenuColorRandomly")
    self.parent.caller.t:SetSolidColor(math.random(0,255),math.random(0,255),math.random(0,255),255)
end

function MenuClearToWhite(self)
    DPrint("in MenuClearToWhite")
    self.parent.caller.t:SetTexture(255,255,255,255) -- TODO original texture not removed
    self.parent.caller.t:SetSolidColor(255,255,255,255)
end

function MenuClose(self) -- close menu
    DPrint("in MenuClose")
    self.parent.open = 0
    for i = 1,self.parent.num do
        self.parent[i]:EnableInput(false)
        self.parent[i]:Hide()
    end
end

function MenuRecycleSelf(self) -- remove object
    DPrint("in MenuRecycleSelf")
    self.parent.caller:EnableInput(false)
    self.parent.caller:EnableMoving(false)
    self.parent.caller:EnableResizing(false)
    self.parent.caller:Hide()

    table.insert(recycledregions, self)
    for k,v in pairs(regions) do
        if v == self then
            table.remove(regions,k)
        end
    end
    
    MenuClose(self)
end

Anchors = {"TOPRIGHT","TOPLEFT","LEFTTOP","LEFTBOTTOM","BOTTOMLEFT","BOTTOMRIGHT","RIGHTBOTTOM","RIGHTTOP","CANCEL"}
anchor_position = Anchors[9]
rel_anchor_position = Anchors[9]
sticky = 0 
sticker = -1 -- store the id of an object

function setAnchorTR(self)
    anchor_position = "BOTTOMRIGHT"
    rel_anchor_position = "TOPRIGHT"
    sticky = 1
    
    MenuClose(self)
    MenuClose(self.parent.caller)
    DPrint("Please select an object to stick")
end

function setAnchorTL(self)
    anchor_position = "BOTTOMLEFT"
    rel_anchor_position = "TOPLEFT"
    sticky = 1
    
    MenuClose(self)
    MenuClose(self.parent.caller)
    DPrint("Please select an object to stick")
end

function setAnchorLT(self)
    anchor_position = "TOPRIGHT"
    rel_anchor_position = "TOPLEFT"
    sticky = 1
    
    MenuClose(self)
    MenuClose(self.parent.caller)
    DPrint("Please select an object to stick")
end

function setAnchorLB(self)
    anchor_position = "BOTTOMRIGHT"
    rel_anchor_position = "BOTTOMLEFT"
    sticky = 1
    
    MenuClose(self)
    MenuClose(self.parent.caller)
    DPrint("Please select an object to stick")
end

function setAnchorBL(self)
    anchor_position = "TOPLEFT"
    rel_anchor_position = "BOTTOMLEFT"
    sticky = 1
    
    MenuClose(self)
    MenuClose(self.parent.caller)
    DPrint("Please select an object to stick")
end

function setAnchorBR(self)
    anchor_position = "TOPRIGHT"
    rel_anchor_position = "BOTTOMRIGHT"
    sticky = 1
    
    MenuClose(self)
    MenuClose(self.parent.caller)
    DPrint("Please select an object to stick")
end

function setAnchorRB(self)
    anchor_position = "BOTTOMLEFT"
    rel_anchor_position = "BOTTOMRIGHT"
    sticky = 1
    
    MenuClose(self)
    MenuClose(self.parent.caller)
    DPrint("Please select an object to stick")
end

function setAnchorRT(self)
    anchor_position = "TOPLEFT"
    rel_anchor_position = "TOPRIGHT"
    sticky = 1
    
    MenuClose(self)
    MenuClose(self.parent.caller)
    DPrint("Please select an object to stick")
end

function setAnchorCancel(self)
    anchor_position = Anchors[9]
    rel_anchor_position = Anchors[9]
    sticker = -1
    sticky = 0
    
    MenuClose(self)
    MenuClose(self.parent.caller)
    DPrint("Please select an object to stick")
end

function MenuStick(self)
    DPrint("in MenuStick")
    sticker = self.parent.caller.id
    
    DPrint("Please select an anchor position for object "..sticker)
end

function DoStick(stickee)
    -- stick id(sticker and its stickee list)
    if anchor_position == Anchors[9] or rel_anchor_position == Anchors[9] then
        -- do nothing
    else
        regions[sticker].stickee = stickee
        regions[stickee].sticker = sticker
        DPrint("sticker "..sticker.." stickee "..stickee.." are now sticked")
        regions[stickee]:SetAnchor(anchor_position,regions[sticker],rel_anchor_position,0,0)
    end
end

function SelectObj(self)
    DPrint("in SelectObj")
    if sticky == 1 then
        if sticker == self.stickee and sticker ~= -1 then
            DPrint(sticker.." and "..self.id.." are aleady sticked. Stick fails.")
        elseif sticker ~= -1 then
            DPrint("this in impossible")
        elseif self.sticker ~= -1 then
            DPrint("It is already sticked to other object. Stick fails.")
        else
            DoStick(self.id)
        end 
        sticker = -1
        sticky = 0
    end
end

Menu = {}
Menu.__index = Menu


function Menu:CreateOption(name,background,w,h,func)
    local opt = Region() 
    opt.parent = self
    opt.type = name
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
    opt:Handle("OnTouchUp",func)
    
    return opt
end

function OpenMenu(self)
    if self.menu.open == 0 then
        for i = 1,self.menu.num do
            self.menu[i]:Show()
            self.menu[i]:EnableInput(true)
        end
        self.menu.open = 1
    else 
        for i = 1,self.menu.num do
            self.menu[i]:Hide()
            self.menu[i]:EnableInput(false)
        end
        self.menu.open = 0
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
    end
    
    return menu
end

    
txt = {"Random pic","Random color","Clear","Stick","Remove","Cancel"}
pics = {"vinyl.png","Ornament1.png","Pirate1.png","Play.png","Right.png"}
tap = {MenuPictureRandomly, MenuColorRandomly, MenuClearToWhite, MenuStick, MenuRecycleSelf, MenuClose}

sequence = 1
function TouchDown(self)
    local region = CreateorRecycleregion('region', 'backdrop', UIParent)
    region.t:SetTexture(255,255,255,255)
    region:Show()
    region:EnableMoving(true)
    region:EnableResizing(true)
    region:EnableInput(true)
    local x,y = InputPosition()
    region:SetAnchor("CENTER",x,y)
    
    local menu = Menu.Create(region,"Sequence 01026.png",txt,tap,NUM_MENU_OPTION)
    menu.open = 0 -- open is 1, close is 0
    -- child menu for Stick
    local anchorTap = {setAnchorTR,setAnchorTL,setAnchorLT,setAnchorLB,setAnchorBL,setAnchorBR,setAnchorRB,setAnchorRT,setAnchorCancel}
    local childmenu = Menu.Create(menu[4],"Sequence 01008.png",Anchors,anchorTap,9)
    childmenu.open = 0 -- open is 1, close is 0
    menu[4].menu = childmenu
    menu[4].bkg = {}
    menu[4]:Handle("OnTouchDown",OpenMenu)

    region.menu = menu
    region.bkg = {}
    region.id = sequence
    region.stickee = -1 -- store the ids of objects that sticks to it
    region.sticker = -1 -- store the ids of objects it sticks to
    region:Handle("OnDoubleTap",OpenMenu)
    region:Handle("OnTouchDown",SelectObj)
    
    table.insert(regions, region)
    sequence = sequence + 1
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

--[[function FlipPage(self)
--    SetPage(1)
--    return
    if not recorderloaded then
        SetPage(14)
        dofile(SystemPath("urRecorder.lua"))
        Recorderloaded = true
    else
        SetPage(14);
    end
end--]]



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