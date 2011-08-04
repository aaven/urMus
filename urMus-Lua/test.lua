
FreeAllRegions()
DPrint("welcome testing")

r = Region()
r.t = r:Texture()
r:Show()
r.t:SetTexture(255,0,0,100)
r.t:SetBlendMode("BLEND") -- "DISABLED", "BLEND", "ALPHAKEY", "ADD", "MOD", or "SUB".

r:SetAnchor("BOTTOMLEFT",100,100)

rr = Region()
rr.t = rr:Texture()
rr:Show()
rr.t:SetTexture(0,255,0,100)
rr.t:SetBlendMode("ADD") -- "DISABLED", "BLEND", "ALPHAKEY", "ADD", "MOD", or "SUB".

rr:SetAnchor("BOTTOMLEFT",200,200)
​