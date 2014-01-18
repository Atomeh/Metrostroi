--------------------------------------------------------------------------------
-- Тяговый электродвигатель постоянного тока (ДК-117ДМ)
--------------------------------------------------------------------------------
Metrostroi.DefineSystem("DK_117DM")

function TRAIN_SYSTEM:Initialize()
	self.Name = "DK_117DM"
	
	-- Winding resistance
	self.Rw = 0.600 -- Ohms
	
	-- Voltage generated by engine
	self.E13 = 0.0 -- Volts
	self.E24 = 0.0 -- Volts
	
	-- Rotation rate
	self.RotationRate = 0.0
	
	-- Magnetic flux in the engine
	self.MagneticFlux13 = 0.0
	self.MagneticFlux24 = 0.0
	
	-- Moment generated by the engine
	self.Moment13 = 0.0
	self.Moment24 = 0.0
end

function TRAIN_SYSTEM:Inputs()
	return { }
end

function TRAIN_SYSTEM:Outputs()
	return { "MagneticFlux13", "MagneticFlux24", "RotationRate", 
			"E13", "E24", "Moment13", "Moment24" }
end

function TRAIN_SYSTEM:Think(dT)
	local Train = self.Train

	-- Calculate magnetic flux factor in the engine
	self.MagneticFlux13 = 0.35 + 0.65*(Train.Electric.Shunt1Resistance/1.6)
	self.MagneticFlux24 = 0.35 + 0.65*(Train.Electric.Shunt2Resistance/1.6)
	
	-- Get rate of engine rotation
	local currentRotationRate = 4000 * ((Train.FrontBogey.Speed + Train.RearBogey.Speed)/90) / 2
	self.RotationRate = self.RotationRate + 5.0 * (currentRotationRate - self.RotationRate) * dT
	
	-- Calculate voltage generated by engines from magnetic flux
	self.E13 = 0.11 * self.RotationRate * (1.5 + 0.5*self.MagneticFlux13)
	self.E24 = 0.11 * self.RotationRate * (1.5 + 0.5*self.MagneticFlux24)
	
	-- Calculate engine force (moment)
	self.Moment13 = (1.0/35000.0) * (Train.Electric.I13^2)
	self.Moment24 = (1.0/35000.0) * (Train.Electric.I24^2)
	if Train.Electric.I13 < 0.0 then self.Moment13 = - self.Moment13 end
	if Train.Electric.I24 < 0.0 then self.Moment24 = - self.Moment24 end
	
	-- Reverser switch
	local reverse = (Train.RR.Value > 0.5)
	
	-- Apply moment
	Train.FrontBogey.MotorForce = 40000
	Train.FrontBogey.Reversed = (Train.RR.Value > 0.5)
	Train.RearBogey.MotorForce  = 40000
	Train.RearBogey.Reversed = (Train.RR.Value < 0.5)
	
	if (math.abs(Train.Electric.I13) > 1.0) or (math.abs(Train.Electric.I24) > 1.0) then
		Train.RearBogey.MotorPower  = (self.Moment13 + self.Moment24) / 2
		Train.FrontBogey.MotorPower = (self.Moment13 + self.Moment24) / 2
	else
		Train.RearBogey.MotorPower  = 0.0
		Train.FrontBogey.MotorPower = 0.0
	end
	
	-- Output things
	self:TriggerOutput("MagneticFlux13",self.MagneticFlux13)
	self:TriggerOutput("MagneticFlux24",self.MagneticFlux24)
	self:TriggerOutput("RotationRate",self.RotationRate)
	self:TriggerOutput("E13",self.E13)
	self:TriggerOutput("E24",self.E24)
	self:TriggerOutput("Moment13",self.Moment13)
	self:TriggerOutput("Moment24",self.Moment24)
end