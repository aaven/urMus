-- urMenu.lua
-- Aaven Jin
-- June, 2011


NUM_MENU_OPT = 4
MENU_WIDTH = 100
MENU_HEIGHT = 130

FreeAllRegions()

r = Region()
r.t = r:Texture(255,255,255,255)
r:EnableInput(true)
r:EnableMoving(true)
r:EnableResizing(true)
r:Show()

txt = {"Random pic","Random color","Remove","Cancel"}

pics = {"1.jpg","2.gif","3.jpg","4.jpg","5.JPG"}

function PictureRandomly(self)
    DPrint("in PictureRandomly")
    self.caller.t:SetTexture(pics[math.random(1,5)])
end

function ColorRandomly(self)
    DPrint("in ColorRandomly")
    self.caller.t:SetSolidColor(math.random(0,255),math.random(0,255),math.random(0,255),255)
end

function RecycleSelf(self)
    DPrint("in RecycleSelf")
    self.caller:EnableInput(false)
    self.caller:EnableMoving(false)
    self.caller:EnableResizing(false)
    self.caller:Hide()

    CloseMenu(self)
    
end

function CloseMenu(self)
    DPrint("in CloseMenu")
    
    for i = 1,4 do
        self.parent[i]:EnableInput(false)
        self.parent[i]:EnableMoving(false)
        self.parent[i]:EnableResizing(false)
        self.parent[i]:Hide()
    end
end

tap = {PictureRandomly, ColorRandomly, RecycleSelf, CloseMenu}

menu = {}
menu.caller = r
locy = {}
for i = 1,NUM_MENU_OPT do
    opt = Region()
    opt.t = opt:Texture()
    opt.parent = menu
    opt.caller = menu.caller
    opt.type = txt[i]
    opt.tl = opt:TextLabel()
    opt.tl:SetLabel(txt[i])
    opt.tl:SetFontHeight(14)
    opt.tl:SetColor(0,0,0,255) 
    opt.tl:SetHorizontalAlign("JUSTIFY")
    opt.tl:SetShadowColor(255,255,255,255)
    opt.tl:SetShadowOffset(1,1)
    opt.tl:SetShadowBlur(1)
    opt:SetWidth(MENU_WIDTH)
    opt:SetHeight(MENU_HEIGHT/NUM_MENU_OPT)
    opt.t:SetTexture(0,i*50+50,0,200) -- green
    opt.t:SetBlendMode("BLEND")
    locy[i] = (1-i)*MENU_HEIGHT/NUM_MENU_OPT
    opt:SetAnchor("TOPLEFT",opt.caller,"TOPRIGHT",0,locy[i])
    opt.parent[i] = opt
    opt.parent[i]:Handle("OnTouchUp",tap[i])
end

function OpenMenu(self)
    for i = 1,NUM_MENU_OPT do
        menu[i]:Show()
        menu[i]:EnableInput(true)
        menu[i]:EnableMoving(true)
        menu[i]:EnableResizing(true)
    end
end

r:Handle("OnDoubleTap",OpenMenu)


local pagebutton=Region('region', 'pagebutton', UIParent)
pagebutton:SetWidth(pagersize)
pagebutton:SetHeight(pagersize)
pagebutton:SetLayer("TOOLTIP")
pagebutton:SetAnchor('BOTTOMLEFT',ScreenWidth()-pagersize-4,ScreenHeight()-pagersize-4)
pagebutton:EnableClamping(true)
pagebutton:Handle("OnTouchDown", FlipPage)
pagebutton.texture = pagebutton:Texture("circlebutton-16.png")
pagebutton.texture:SetGradientColor("TOP",255,255,255,255,255,255,255,255)
pagebutton.texture:SetGradientColor("BOTTOM",255,255,255,255,255,255,255,255)
pagebutton.texture:SetBlendMode("BLEND")
pagebutton.texture:SetTexCoord(0,1.0,0,1.0)
pagebutton:EnableInput(true)
pagebutton:Show()
​

