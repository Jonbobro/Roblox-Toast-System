local TS = game:GetService("TweenService")

--==[HELPER FUNCTION]==--
local function DarkenColor(color)
	local factor = 1 - (20 / 100)
	return Color3.new(
		math.clamp(color.R * factor, 0, 1),
		math.clamp(color.G * factor, 0, 1),
		math.clamp(color.B * factor, 0, 1)
	)
end

--==[ACTUAL CLASS]==--
local Toasts = {}
Toasts.__index = Toasts

--==[CONSTRUCTOR]==--
function Toasts.new(Container: Frame)
	local self = setmetatable({}, Toasts)
	self.Container = Container
	self.HasBoarder = false
	self.HasTip = false
	self.HasProgressBar = false
	self.ToastSize = 30
	self.ToastSpacing = 5
	self.ToastLifetime = 5
	self.CurrentToasts = {}
	self.TotalToasts = 0
	self.MaxToasts = 5
	return self
end

--==[NOTIFIER : CORE FUNCTION]==--
--Pushes a notification box to the container and updates postitions of all toasts
--Will also return the toast gui to be modified in post
function Toasts:PushToast(message: string, color : Color3, Icon : string, HideToast : boolean)
	--A ton of typechecking and defaulting to make sure things will run
	if not color then color = Color3.fromRGB(math.random(0,255),math.random(0,255),math.random(0,255)) end
	if not message then message = "Test" end
	
	if self.Container.ClassName ~= "Frame" then warn("No container Assigned to toast object") return end
	if typeof(self.HasBoarder) ~= "boolean" then self.HasBoarder = false end
	if typeof(self.HasTip) ~= "boolean" then self.HasTip = false end
	if typeof(self.HasProgressBar) ~= "boolean" then self.HasProgressBar = true end
	if typeof(self.ToastSize) ~= "number" then self.ToastSize = 30 end
	if typeof(self.ToastSpacing) ~= "number" then self.ToastSpacing = 5 end
	if typeof(self.ToastLifetime) ~= "number" then self.ToastLifetime = 5 end
	
	--Just if debugging might be needed
	self.TotalToasts += 1
	
	local ContainerSize = self.Container.AbsoluteSize
	
	local xOffset = 0
	
	local Toast = Instance.new("Frame")
	Toast.AnchorPoint = Vector2.new(1,1)
	Toast.Size = UDim2.new(0, ContainerSize.X, 0, self.ToastSize)
	Toast.BackgroundColor3 = color
	Toast.Name = "Toast" .. self.TotalToasts
	Toast.Position = UDim2.new(1, 0, 1, 0)
	Toast.Parent = self.Container
	
	local Rounded = Instance.new("UICorner")
	Rounded.CornerRadius = UDim.new(0, 5)
	Rounded.Parent = Toast
	
	if self.HasBoarder then 
		local Boarder = Instance.new("UIStroke")
		Boarder.Thickness = 5
		Boarder.Color = DarkenColor(color)
		Boarder.Name = "Boarder"
		Boarder.Parent = Toast
	end
	
	if self.HasTip then
		local Tip = Instance.new("Frame")
		Tip.Size = UDim2.new(0,5, 1, 0)
		Tip.BorderSizePixel = 0
		Tip.BackgroundColor3 = DarkenColor(color)
		Tip.Parent = Toast
		Tip.Name = "Tip"
		Tip.ZIndex = 3
		xOffset += 5
	end
	
	if self.HasProgressBar then 
		local ProgressBar = Instance.new("Frame")
		ProgressBar.BackgroundTransparency = .3
		ProgressBar.AnchorPoint = Vector2.new(0,1)
		ProgressBar.Size = UDim2.new(0,0,0,3)
		ProgressBar.Parent = Toast
		ProgressBar.Position = UDim2.new(0,xOffset,1,0)
		ProgressBar.Name = "ProgressBar"
		ProgressBar.BorderSizePixel = 0
		task.spawn(function()
			local TI = TweenInfo.new(
				self.ToastLifetime,
				Enum.EasingStyle.Linear,
				Enum.EasingDirection.InOut)

			local Tween = TS:Create(ProgressBar, TI, {Size = UDim2.new(1,-xOffset,0,3)})
			Tween:Play()
		end)


	end

	if Icon then
		local IconLabel = Instance.new("ImageLabel")
		IconLabel.Size = UDim2.new(0, self.ToastSize - 4, 0 , self.ToastSize - 4)
		IconLabel.Position = UDim2.new(0,xOffset,0,2)
		IconLabel.BackgroundTransparency = 1
		IconLabel.Name = "Icon"
		IconLabel.Parent = Toast
		IconLabel.Image = Icon
		IconLabel.ImageColor3 = Color3.new(1,1,1)
		IconLabel.ZIndex = 5
		
		xOffset += self.ToastSize
	end
	
	local MessageLabel = Instance.new("TextLabel")
	MessageLabel.BackgroundTransparency = 1
	MessageLabel.Name = "Message"
	MessageLabel.Text = message
	MessageLabel.TextScaled = true
	MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
	MessageLabel.ZIndex = 15
	MessageLabel.Font = Enum.Font.RobotoMono
	MessageLabel.Size = UDim2.new(1, -xOffset, .8, 0)
	MessageLabel.Position = UDim2.new(0, xOffset, 0.1, 0)
	MessageLabel.TextColor3 = Color3.new(1,1,1)
	
	MessageLabel.Parent = Toast
	

	task.delay(self.ToastLifetime, function()
		local index = table.find(self.CurrentToasts, Toast)
		if index then
			table.remove(self.CurrentToasts, index)
			if Toast and Toast.Parent then
				Toast:Destroy()
			end
			self:_RepositionToasts()
		end
	end)
	
	table.insert(self.CurrentToasts, Toast)
	
	self:_RepositionToasts()
	
	while #self.CurrentToasts > self.MaxToasts do
		local OldestToast = table.remove(self.CurrentToasts, 1)
		if OldestToast then
			OldestToast:Destroy()
		end
	end
	
	return Toast
end

--==[HELPER TO UPDATE TOAST POSITIONS]==--
function Toasts:_RepositionToasts()
	local total = #self.CurrentToasts
	for i, toast in ipairs(self.CurrentToasts) do
		local yOffset = (self.ToastSize + self.ToastSpacing) * (total - i)
		toast.Position = UDim2.new(1, 0, 1, -yOffset)
	end
end

return Toasts
