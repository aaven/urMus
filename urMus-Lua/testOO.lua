FreeAllRegions()

function Account.deposit (self, v)
	self.balance = self.balance + v
end

a1 = Account; Account = nil
a1.deposit(a1, 100.00)  

DPrint(a1);