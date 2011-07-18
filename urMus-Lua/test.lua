-- test
-- by Aaven, Jul 2011

FreeAllRegions()
DPrint("welcome to urTydping")
r = Region()
r.t = r:Texture()
r:Show()
r.t:SetTexture(255,0,0,255)

r:SetAnchor("BOTTOMLEFT",100,100)

r2 = Region()
r2.t = r2:Texture()
r2:SetWidth(r:Width()/2)
r2:SetHeight(r:Height()/2)


r2:SetAnchor("CENTER",r,"CENTER",0,0)
r2.t:SetTexture(0,255,0,255)
r2:Show()

-- Here is the inherited move
r:SetAnchor("BOTTOMLEFT", 200,200)

function ColorRandomly(self)
self.t:SetSolidColor(math.random(0,255),math.random(0,255),math.random(0,255),255)
end

-- We add the "OnTouchUp" event to region r. The function ColorRandomly will be called when this occurs
r:Handle("OnTouchUp",ColorRandomly)

r:EnableInput(true)

function TouchDown(self)
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
