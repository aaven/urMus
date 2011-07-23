-- urVen2.lua
-- by Aaven, Jul 2011
-- based on urVen.lua
-- p.s. menu becomes global

FreeAllRegions()
DPrint("Welcome to urVen =)")

---------------- constant -------------------
MIN_WIDTH_MENU = 100
MAX_WIDTH_MENU = 200
MAX_NUM_MENU_OPT = 20
HEIGHT_MENU_OPT = 30
NUM_MENU_OPTION = 7 -- MenuCancel is not needed anymore
INDEX_STICK_MENU = 6

STICK_MARGIN = 20
HEIGHT_LINE = 30

regions = {}
recycledregions = {}

SixteenPositions = {} -- SixteenPositions(p1)(p2): ee:SetAnchor(p2,er,p1)
function InitializeUrStick()  
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

------------------- events --------------------
function CloseMenuBar()
    if menubar.show == 1 then
        for i = 1,#menubar do
            menubar[i]:Hide()
            menubar[i]:EnableInput(false)
        end
        menubar.show = 0
    end
end

function CloseGlobalMenu(self)
    --if menubar.v ~= self then
        if menubar.openmenu ~= -1 then
            menubar[menubar.openmenu].menu:CloseMenu()
            menubar.openmenu = -1 
            menubar.v = nil
        end
        CloseMenuBar()
    --end
end

function OpenGlobalMenu(self)
    if menubar.show == 0 then
        for i = 1,#menubar do
            menubar[i]:Show()
            menubar[i]:EnableInput(true)
        end
        menubar.v = self
        menubar.show = 1
    end
end

function OpenOrCloseMenu(self)
    if self.menu.open == 0 then
        DPrint("open option")
        self.menu:OpenMenu()
    else 
        DPrint("close option")
        self.menu:CloseMenu()
    end
end

function OpenOrCloseMenubarItem(self) -- call by menubar(i)
    if self.menu.open == 0 then
        DPrint("open menu item")
        menubar.openmenu = self.k
        self.menu:OpenMenu()
    else 
        DPrint("close menu item")
        menubar.openmenu = -1
        self.menu:CloseMenu()
    end
end


function HoldToTrigger(self, elapsed)
    self.holdtime = self.holdtime - elapsed
    x,y = self:Center()
    if self.x ~= x or self.y ~= y then
        self:Handle("OnUpdate",nil)
    else
        self.x = x 
        self.y = y
        if self.holdtime <= 0 then
            DPrint("Menu Opened")
            OpenGlobalMenu(self)
            CloseColorWheel(self)
        end
    end
end

function HoldTrigger(self)
    self.holdtime = 1
    self.x,self.y = self:Center()
    self:Handle("OnUpdate",HoldToTrigger)
end

function DeTrigger(self)
    self:Handle("OnUpdate",nil)
end

function PlainVRegion(r)
    -- initialize for events and signals
    r.eventlist = {}
    r.eventlist["OnTouchDown"] = {HoldTrigger,CloseGlobalMenu,SelectObj}
    r.eventlist["OnTouchUp"] = {DeTrigger,AutoCheckStick}
    r.eventlist["OnDoubleTap"] = {ChangeColor}
    r.eventlist["OnUpdate"] = {} -- TODO: not needed??
    r.eventlist["OnMove"] = {}
    r.eventlist["OnShow"] = {}
    r.eventlist["OnHide"] = {}
    r.eventlist["OnLongTap"] = {OpeneGlobalMenu}
    r.signallist = {} -- customized signal
    
    -- initialize for stick
    r.group = r.id
    r.sticker = -1
    r.stickee = {}
    
    -- initialize for moving
    r.vlist_through = {}
    r.vlist_bounce_nochange = {}
    r.vlist_bounce_hide = {}
    r.bound_through = {}
    r.bound_bounce_nochange = {}
    r.bound_bounce_hide = {}
    r.moving = 0
    r.dx = 0
    r.dy = 0
    
    -- initialize texture, label and size
    r.t:SetTexture(255,255,255,255)
    r.tl:SetLabel("R#"..r.id)
    r.tl:SetFontHeight(16)
    r.tl:SetColor(0,0,0,255) 
    r.tl:SetHorizontalAlign("JUSTIFY")
    r.tl:SetShadowColor(255,255,255,255)
    r.tl:SetShadowOffset(1,1)
    r.tl:SetShadowBlur(1)
    r:SetWidth(200)
    r:SetHeight(200)
end

------------------- VRegion ------------------
function VRegion(ttype,name,parent,id)
    local r = Region(ttype,name,parent)
    r.tl = r:TextLabel()
    r.t = r:Texture()
    
    -- initialize for regions{} and recycledregions{}
    r.usable = 1
    r.id = id
    PlainVRegion(r)
    
    r:EnableMoving(true)
    r:EnableResizing(true)
    r:EnableInput(true)
    
    return r
end

------------------- user customized data/functions ------------------
pics = {"vinyl.png","Ornament1.png","Pirate1.png","Play.png","Right.png"}
                            
function_list = {{"about",MenuAbout,{}},
                    {"rand pic",MenuPictureRandomly,{}},
                    {"rand color",MenuColorRandomly,{}},
                    {"clear bkg",MenuClearToWhite,{}},
                    {"remove v",MenuRecycleSelf,{}},
                    {"unstick",MenuUnstick,{}}}


------------ Menu Class -------------
Menu = {}
Menu.__index = Menu
function Menu:OpenMenu() 
    if self.open == 0 then
        for i = 1,self.num do
            self[i]:EnableInput(true)
            self[i]:MoveToTop()
            self[i]:Show()
        end
        self.open = 1
    end
end

function Menu:CloseMenu() 
    if self.open == 1 then
        for i = 1,self.num do
            self[i]:Hide()
            self[i]:EnableInput(false)
            if self[i].menu ~= {} then
                if self[i].menu.open == 1 then
                    self[i].menu:CloseMenu()
                end
            end
        end
        self.open = 0
    end
end

function Menu:MoveMenuToTop() 
    if self.open == 1 then
        for i = 1,self.num do
            self[i]:MoveToTop()
            if self[i].menu ~= {} then
                if self[i].menu.open == 1 then
                    self[i].menu:MoveMenuToTop()
                end
            end
        end
    end
end

function Menu:CreateOption(pair)
    local opt = Region() 
    opt.parent = self
    opt.menu = {}
    opt.tl = opt:TextLabel()
    opt.tl:SetLabel(pair[1])
    opt.tl:SetFontHeight(14)
    opt.tl:SetColor(0,0,0,255) 
    opt.tl:SetHorizontalAlign("JUSTIFY")
    opt.tl:SetShadowColor(255,255,255,255)
    opt.tl:SetShadowOffset(1,1)
    opt.tl:SetShadowBlur(1)
    opt:SetWidth(self.w)
    opt:SetHeight(self.h)
    opt.t = opt:Texture()
    opt.t:SetTexture(self.bkg) -- TODO how to fill rgb value
    opt.t:SetBlendMode("BLEND")
    opt:Handle("OnTouchDown",pair[2])
    
    if #pair[3] ~= 0 then
        opt.menu = Menu.Create(opt,"Sequence 01026.png",pair[3],"TOPLEFT","TOPRIGHT")
        opt:Handle("OnTouchDown",OpenOrCloseMenu)
    end
    
    return opt
end

function Menu.Create(region,background,list,anchor,relanchor)
-- side:left or right or inside. offsets are for menu position
    
    local menu = {}
    setmetatable(menu,Menu)
    menu.w = MIN_WIDTH_MENU
    menu.h = HEIGHT_MENU_OPT
    menu.caller = region
    menu.ancestor = -1
    menu.bkg = background
    menu.open = 0
    menu.list = list
    menu.num = #list
    
    local len = 0
    for i = 1,menu.num do
        if len < string.len(list[i][1]) then
            len = string.len(list[i][1])
        end
    end
    
    if len >= 20 then -- TODO too long name cant be displayed
        menu.w = MAX_WIDTH_MENU
    elseif len > 10 then
        menu.w = len*10
    end
    
    menu[1] = menu:CreateOption(list[1])
    menu[1]:SetAnchor(anchor,menu.caller,relanchor)
    menu[1]:Hide()
    
    for i = 2,menu.num do
        menu[i] = menu:CreateOption(list[i])
        menu[i]:SetAnchor("BOTTOMLEFT",menu[i-1],"TOPLEFT")
        menu[i]:Hide()
    end
    
    return menu
end

------------- menu functions, call by menu option --------------
function MenuAbout(self)
    output = "R#"..menubar.v.id..", sticker #"..menubar.v.sticker..", stickees"
    if #menubar.v.stickee == 0 then
        output = output.." #-1"
    else
        for k,ee in pairs (menubar.v.stickee) do
            output = output.." #"..ee
        end
    end
    DPrint(output)
end

function MenuPictureRandomly(self)
    menubar.v.bkg = pics[math.random(1,5)]
    menubar.v.t:SetTexture(menubar.v.bkg)
    DPrint("R#"..menubar.v.id.." background pic: "..menubar.v.bkg)
end

function MenuColorRandomly(self)
    DPrint("R#"..menubar.v.id.." change color")
    menubar.v.t:SetSolidColor(math.random(0,255),math.random(0,255),math.random(0,255),255)
end

function MenuClearToWhite(self)
    DPrint("R#"..menubar.v.id.." clear to white")
    menubar.v.t:SetTexture(255,255,255,255) -- TODO original texture not removed
    menubar.v.t:SetSolidColor(255,255,255,255)
end

function MenuClose(self) -- call by menu option
    self.parent:CloseMenu()
    CloseMenuBar()
end

function MenuRecycleSelf(self) -- remove v
    MenuUnstick(self)
    
    PlainVRegion(menubar.v)
    menubar.v:EnableInput(false)
    menubar.v:EnableMoving(false)
    menubar.v:EnableResizing(false)
    menubar.v:Hide()
    menubar.v.usable = 0
    menubar.openmenu = -1

    table.insert(recycledregions, menubar.v.id)
    DPrint("R#"..menubar.v.id.." removed")
    menubar.v = nil
    
    MenuClose(self)
end

function MenuUnstick(self)
    output = ""
    local er = menubar.v.sticker
    local id = menubar.v.id
    local flag = 0
    if er ~= -1 then -- it is sticked to other
        output = output.."a: R#"..er.." releases R#"..id..". "
        for k,ee in pairs(regions[er].stickee) do
            if ee == id then
                table.remove(regions[er].stickee,k)
            end
        end
        menubar.v.sticker = -1
        menubar.v:SetAnchor("BOTTOMLEFT",UIParent,"BOTTOMLEFT",0,0)
        menubar.v:EnableMoving(true)
        menubar.v:EnableInput(true)
        menubar.v:EnableResizing(true)
        menubar.v.group = id
        flag = 1
    end
    if (#menubar.v.stickee > 0) then
        output = output.."b: R#"..id.." releases"
        flag = 1
        for k,ee in pairs(menubar.v.stickee) do -- other is sticked to it
            output = output.." R#"..ee
            regions[ee].sticker = -1
            regions[ee]:SetAnchor("BOTTOMLEFT",UIParent,"BOTTOMLEFT",0,0)
            regions[ee]:EnableMoving(true)
            regions[ee]:EnableInput(true)
            regions[ee]:EnableResizing(true)
            regions[ee].group = regions[ee].id
        end
        while #menubar.v.stickee > 0 do
            table.remove(menubar.v.stickee,1)
        end
    end
    
    if flag == 0 then
        DPrint("R#"..id.." nothing to unstick")
    else
        DPrint(output)
    end
    MenuClose(self)
end

------------ notification component set --------------
------------ add ShowNotification(note) to wanted event --------------
function FadeNotification(self, elapsed)
    if self.staytime > 0 then
        self.staytime = self.staytime - elapsed
        return
    end
    if self.fadetime > 0 then
        self.fadetime = self.fadetime - elapsed
        self.alpha = self.alpha - self.alphaslope * elapsed
        self:SetAlpha(self.alpha)
    else
        self:Hide()
        self:Handle("OnUpdate", nil)
    end
end

function ShowNotification(note)
    notificationregion.textlabel:SetLabel(note)
    notificationregion.staytime = 1.5
    notificationregion.fadetime = 2.0
    notificationregion.alpha = 1
    notificationregion.alphaslope = 2
    notificationregion:Handle("OnUpdate", FadeNotification)
    notificationregion:SetAlpha(1.0)
    notificationregion:Show()
end

notificationregion=Region('region', 'notificationregion', UIParent)
notificationregion:SetWidth(ScreenWidth())
notificationregion:SetHeight(48*2)
notificationregion:SetLayer("TOOLTIP")
notificationregion:SetAnchor('BOTTOMLEFT',0,ScreenHeight()/2-24) 
notificationregion:EnableClamping(true)
notificationregion:Show()
notificationregion.textlabel=notificationregion:TextLabel()
notificationregion.textlabel:SetFont("Trebuchet MS")
notificationregion.textlabel:SetHorizontalAlign("CENTER")
notificationregion.textlabel:SetLabel("")
notificationregion.textlabel:SetFontHeight(48)
notificationregion.textlabel:SetColor(255,255,255,190)

------------- event functions for V --------------
function DoStick(stickee)
    -- stick id(sticker and its stickee list)
    if anchor_position == function_name_list_stick[9] or rel_anchor_position == function_name_list_stick[9] then
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

function SelectObj(self)
    DPrint("R#"..self.id.." selected")
    self:MoveToTop()
end

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

    output = SixteenPositions[dx][dy][1].."+"..SixteenPositions[dx][dy][2].." new stickee R#"..ee.id.."! sticker R#"..er.id.." now has stickees: "
    for k,i in pairs(er.stickee) do
        output = output.." R#"..i
    end
    DPrint(output)
end

function AutoCheckStick(self)
  --  DPrint("in AutoCheckStick")
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
                    if not v:RegionOverlap(self) then
                        if self.sticker == -1 then
                            StickToClosestAnchorPoint(self,v)
                            self.group = v.group
                        end
                    end
                end
            end
        end
    end
end

function UpdateMenuPosition(self)
    if self:Right() + self.menu.w > ScreenWidth() and self:Left() - self.menu.w < 0 then
        self.menu.position[1] = "inside"
        if self:Left() < 0 then
            self.menu.position[2] = 0 - self:Left()
        else
            self.menu.position[2] = 0
        end
    elseif self:Right() + self.menu.w > ScreenWidth() then
        self.menu.position[1] = "left"
        self.menu.position[2] = 0
    else
        self.menu.position[1] = "right"
        self.menu.position[2] = 0
    end
    
    if self:Top() > ScreenHeight() then
        self.menu.position[3] = ScreenHeight() - self:Top()
    elseif self:Top() < self.menu.num * self.menu.h then
        self.menu.position[3] = self.menu.num * self.menu.h - self:Top()
    else
        self.menu.position[3] = 0
    end
    
    self.menu:AnchorMenu()
end

function StartMove(self) -- event: close menu when starting to move
    DPrint("in startmove")
    self:MoveToTop()
    if self.menu.open == 1 then
        DPrint("startmove w menu")
        self.menu:CloseMenu()
    end
end

function VDoubleTap(self)
    --ChangeColor(self)
    for i = 1,#self.eventlist["OnDoubleTap"] do
        self.eventlist["OnDoubleTap"][i](self)
    end
end

function VTouchUp(self)
    for i = 1,#self.eventlist["OnTouchUp"] do
        self.eventlist["OnTouchUp"][i](self)
    end
end

function VTouchDown(self)
    for i = 1,#self.eventlist["OnTouchDown"] do
        self.eventlist["OnTouchDown"][i](self)
    end
end

----------- background region -----------
function CreateorRecycleregion(ftype, name, parent)
    local region
    if #recycledregions > 0 then
        region = regions[recycledregions[#recycledregions]]
        table.remove(recycledregions)
        region:EnableMoving(true)
        region:EnableResizing(true)
        region:EnableInput(true)
        region.usable = 1
    else
        region = VRegion(ftype, name, parent, #regions+1)
        table.insert(regions,region)
    end
    return region
end

function TouchDown(self)
    CloseGlobalMenu()
    
    local region = CreateorRecycleregion('region', 'backdrop', UIParent)
    local x,y = InputPosition()
    region:Show()
    region:SetAnchor("CENTER",x,y)
    DPrint("R#"..region.id.." created, centered at "..x..", "..y)
    
    region:Handle("OnDoubleTap",VDoubleTap)
    region:Handle("OnTouchDown",VTouchDown)
    region:Handle("OnTouchUp",VTouchUp)
end

function TouchUp(self)
--    DPrint("MU")
end

function DoubleTap(self)
--      DPrint("DT")
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
backdrop:SetClipRegion(0,HEIGHT_LINE,ScreenWidth(),ScreenHeight())
backdrop:EnableClipping(true)


------------- global menu ---------------

menubar = {}
menubar.menus = {{"Edit",function_list}}
menubar.v = nil -- caller v
menubar.openmenu = -1
menubar.show = 0

for k,name in pairs (menubar.menus) do
    local r = Region('region','menu',UIParent)
    r.tl = r:TextLabel()
    r.tl:SetLabel(menubar.menus[k][1])
    r.tl:SetFontHeight(16)
    r.tl:SetColor(0,0,0,255) 
    r.tl:SetHorizontalAlign("JUSTIFY")
    r.tl:SetShadowColor(255,255,255,255)
    r.tl:SetShadowOffset(1,1)
    r.tl:SetShadowBlur(1)
    r.t = r:Texture(200,200,200,255)
    r.k = k
    r.menu = Menu.Create(r,"Sequence 01026.png",menubar.menus[k][2],"BOTTOMLEFT","TOPLEFT")
    r:SetWidth(ScreenWidth()/#menubar.menus)
    r:SetHeight(HEIGHT_LINE)
    r:EnableInput(false)
    r:EnableMoving(false)
    r:EnableResizing(false)
    r:Handle("OnTouchDown",OpenOrCloseMenubarItem)
    menubar[k] = r
end

menubar[1]:SetAnchor("BOTTOMLEFT",UIParent,"BOTTOMLEFT")
for i=2,#menubar do
    menubar[i]:SetAnchor("LEFT",menubar[i-1],"RIGHT")
    menubar[i]:Hide()
end
menubar[1]:Hide()


------------  multiple functions -------------
color_w = 256
color_h = 256
color_wheel = Region('region','colorwheel',UIParent)
color_wheel.t = color_wheel:Texture()
color_wheel.t:SetTexture('color_map.png')--255,255,255,255
color_wheel:SetWidth(color_w)
color_wheel:SetHeight(color_h)
--color_wheel:SetAnchor("CENTER",backdrop,"CENTER")
color_wheel:MoveToTop()
color_wheel:EnableInput(false)
color_wheel:EnableMoving(false)
color_wheel:EnableResizing(false)
color_wheel:Handle("OnMove",UpdateColor)

function UpdateColor(self,x,y,dx,dy)
    xx = (x+dx-color_wheel:Left())*1530/color_w
    yy = y+dy-color_wheel:Bottom()*255/color_h
    local r=0
    local g=0
    local b=0
    local a=yy
    
    if xx < 255 then
        r = 255
        g = xx
        b = 0
    elseif xx < 510 then
        r = 510 - xx
        g = 255
        b = 0
    elseif xx < 765 then
        r = 0
        g = 255
        b = xx - 510
    elseif xx < 920 then
        r = 0 
        g = 920 - xx
        b = 255
    elseif xx < 1175 then
        r = xx - 920
        g = 0
        b = 255
    else
        r = 255
        g = 0
        b = 1530 - xx
    end
    
    r = r*a/255
    g = g*a/255
    b = b*a/255
    
    
    self.region.t:SetTexture(r,g,b,a)
    DPrint("x"..xx.." y"..yy.." r"..r.." g"..g.." b"..b.." a"..a)
end

function CloseColorWheel(self)
    color_wheel:Hide()
    color_wheel:EnableInput(false)
    self.eventlist["OnDoubleTap"] = {ChangeColor} -- TODO
end

function ChangeColor(self)
    color_wheel:Show()
    color_wheel.region = self
    color_wheel:EnableInput(true)
    self.eventlist["OnDoubleTap"] = {CloseColorWheel}
end

-- test area
function SlideOpenMenu(self)
    self.menu.open = 1
    for i = 1,self.menu.num do
        self.menu[i]:Show()
        self.menu[i]:EnableInput(true)
        self.menu[i]:MoveToTop()
    end
    self.menu.open = 1
end


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