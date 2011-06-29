FreeAllRegions()

r = Region()
r.t = r:Texture(255,255,255,255)
r:EnableInput(true)
r:EnableMoving(true)
r:EnableResizing(true)
r:Show()

function Start(self)
    DPrint("start")
    self.t:SetSolidColor(math.random(0,255),math.random(0,255),math.random(0,255),255)
end

function Stop(self)
    DPrint("stop")
    self.t:SetSolidColor(math.random(0,255),math.random(0,255),math.random(0,255),255)
end

r:Handle("OnDragStart",Start)
r:Handle("OnDragStop",Stop)​