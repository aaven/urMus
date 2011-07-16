-- urTyping.lua
-- by Aaven, Jul 2011

FreeAllRegions()
DPrint("welcome to urTyping")


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
pagebutton:Handle("OnTouchDown", FlipPage)
pagebutton.texture = pagebutton:Texture("circlebutton-16.png");
pagebutton.texture:SetGradientColor("TOP",255,255,255,255,255,255,255,255);
pagebutton.texture:SetGradientColor("BOTTOM",255,255,255,255,255,255,255,255);
pagebutton.texture:SetBlendMode("BLEND")
pagebutton.texture:SetTexCoord(0,1.0,0,1.0);
pagebutton:EnableInput(true);
pagebutton:Show()

------------ typing component set --------------

------------ Keyboard Class --------------
key_margin = 10
key_w = 40
key_h = 45

Keyboard = {}
Keyboard.__index = Keyboard

function KeyTouchDown(self)
    DPrint(self.faces[self.parent.face])
    self.parent.typingarea.tl:SetLabel(self.faces[self.parent.face])
end

function Keyboard:CreateKey(ch1,ch2,ch3,w)
    local key = Region('region', 'key', UIParent)
    key.parent = self
    key.faces = {ch1,ch2,ch3} -- 1: low case, 2: upper case, 3: back number
    key.t = key:Texture(200,200,200,255)
    key.tl = key:TextLabel()
    key.tl:SetLabel(ch1)
    key.tl:SetFontHeight(16)
    key.tl:SetColor(0,0,0,255) 
    key.tl:SetHorizontalAlign("JUSTIFY")
    key.tl:SetShadowColor(255,255,255,255)
    key.tl:SetShadowOffset(1,1)
    key.tl:SetShadowBlur(1)
    key:SetHeight(key_h)
    key:SetWidth(w)
    key:Handle("OnTouchDown",KeyTouchDown)
    return key
end

function Keyboard:CreateKBLine(str1,str2,str3,line,w) -- as a private function, do not use outside class, only called by Keyboard.Create
    self[line] = {}
    self[line].num = string.len(str1)
    self[line][1] = self:CreateKey(string.char(str1:byte(1)),string.char(str2:byte(1)),string.char(str3:byte(1)),w)
    
    for i=2,self[line].num do
        self[line][i] = self:CreateKey(string.char(str1:byte(i)),string.char(str2:byte(i)),string.char(str2:byte(i)),w)
        self[line][i]:SetAnchor("TOPLEFT",self[line][i-1],"TOPRIGHT",key_margin,0)
    end
end

function Keyboard.Create(area)
    local kb = {}
    setmetatable(kb, Keyboard)
    kb.open = 0
    kb.typingarea = area
    kb.w = ScreenWidth()
    kb.h = ScreenWidth()/3
    kb.face = 1 -- 1: low case, 2: upper case, 3: back number
    kb:CreateKBLine("qwertyuiop","QWERTYUIOP","1234567890",1,key_w)
    kb:CreateKBLine("asdfghjkl","ASDFGHJKL","-/:;()$&@",2,key_w)
    kb:CreateKBLine("zxcvbnm,.","ZXCVBNM!?","_\|~<>+='",3,key_w)
    -- kb(3) has SHIFT key
    kb[3][10] = kb:CreateKey("shift","shift","disable",key_w+10)
    kb[3][10]:SetAnchor("TOPLEFT",kb[3][9],"TOPRIGHT",key_margin,0)
    kb[3].num = kb[3].num + 1
    kb[4] = {}
    kb[4].num = 3
    kb[4][1] = kb:CreateKey("123","123","abc",key_w*2)
    kb[4][2] = kb:CreateKey("","","",key_w*8)
    kb[4][3] = kb:CreateKey("<=","<=","<=",key_w*2)
    kb[4][2]:SetAnchor("TOPLEFT",kb[4][1],"TOPRIGHT",key_margin,0)
    kb[4][3]:SetAnchor("TOPLEFT",kb[4][2],"TOPRIGHT",key_margin,0)
    
    kb[4][1]:SetAnchor("BOTTOMLEFT",key_margin,key_margin)
    kb[3][1]:SetAnchor("BOTTOMLEFT",kb[4][1],"TOPLEFT",0,key_margin)
    kb[2][1]:SetAnchor("BOTTOMLEFT",kb[3][1],"TOPLEFT",key_w/2,key_margin)
    kb[1][1]:SetAnchor("BOTTOMLEFT",kb[2][1],"TOPLEFT",0-key_w/2,key_margin)
    
    return kb
end

function Keyboard:Show()
    for i = 1,4 do
        for j = 1,#self[i] do
            self[i][j]:EnableInput(true)
            self[i][j]:Show()
        end
    end
    self.open = 1
end

function Keyboard:Hide()
    for i = 1,4 do
        for j = 1,#self[i] do
            self[i][j]:EnableInput(true)
            self[i][j]:Hide()
        end
    end
    self.open = 0
end

mykb = Keyboard.Create(area)

function OpenOrCloseKeyboard(self)
    if mykb.open == 0 then 
        mykb.typingarea = self
        DPrint("to open")
        mykb:Show()
    else 
        DPrint("to close")
        mykb:Hide()
    end
end

function show(self)
    DPrint("UP")
end

myarea = Region()
myarea.t=myarea:Texture(255,255,255,255)
myarea.tl = myarea:TextLabel()
myarea.tl:SetLabel("Please type with keyboard...")
myarea.tl:SetFontHeight(16)
myarea.tl:SetColor(0,0,0,255) 
myarea.tl:SetHorizontalAlign("JUSTIFY")
myarea.tl:SetShadowColor(255,255,255,255)
myarea.tl:SetShadowOffset(1,1)
myarea.tl:SetShadowBlur(1)
myarea:SetAnchor("CENTER",400,400)
myarea:Show()
myarea:EnableInput(true)
myarea:Handle("OnDoubleTap",OpenOrCloseKeyboard)

------------------------------------------------
function TouchDown(self)
  --  DPrint("touchdown")
  --  OpenOrCloseKeyboard()
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
end​