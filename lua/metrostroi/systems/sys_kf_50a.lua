--------------------------------------------------------------------------------
-- Ящик резисторов силовых цепей (КФ-50А)
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("KF_50A")

function TRAIN_SYSTEM:Initialize()
	self.Resistors = {
		["L74-P37"]	= 0.296,
		["P37-P36"]	= 0.063,
		["P36-P35"]	= 0.028,
		
		["P35-K2"]	= 0.042,
		["L76-P31"]	= 0.296,
		["P31-P30"]	= 0.063,
		["P30-P29"]	= 0.028,
		["P29-P28"]	= 0.042,
	}
	
	for k,v in pairs(self.Resistors) do
		self[k] = v
	end
end