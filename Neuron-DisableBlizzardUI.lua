-- Neuron is a World of Warcraft® user interface addon.
-- Copyright (c) 2017-2021 Britt W. Yazel
-- Copyright (c) 2006-2014 Connor H. Chenoweth
-- This code is licensed under the MIT license (see LICENSE for details)

-- Hidden parent frame
local UIHider = CreateFrame("Frame")
UIHider:Hide()


local function disableBarFrame(frame)
	if frame then
		frame:UnregisterAllEvents()
		frame:SetParent(UIHider)
		frame:Hide()
	end
end

local function disableButtonFrame(frame)
	if frame then
		frame:UnregisterAllEvents()
		frame:SetAttribute("statehidden", true)
		frame:Hide()
	end
end

function Neuron:HideBlizzardUI()
	----------------------------
	----- Disable Buttons ------
	----------------------------
	--Hide and disable the individual buttons on most of our bars
	for i=1,12 do
		disableButtonFrame(_G["ActionButton"..i])
		disableButtonFrame(_G["MultiBarBottomLeftButton"..i])
		disableButtonFrame(_G["MultiBarBottomRightButton"..i])
		disableButtonFrame(_G["MultiBarRightButton"..i])
		disableButtonFrame(_G["MultiBarLeftButton"..i])
	end

	for i=1,6 do
		disableButtonFrame(_G["OverrideActionBarButton"..i])
	end

	disableButtonFrame(_G["ExtraActionButton1"])

	----------------------------
	------- Disable Bars -------
	----------------------------
	--disable main blizzard bar and graphics
	disableBarFrame(MainMenuBar)
	disableBarFrame(MainMenuBarArtFrame)
	disableBarFrame(MainMenuBarArtFrameBackground)

	--disable bottom bonus bars
	disableBarFrame(MultiBarBottomLeft)
	disableBarFrame(MultiBarBottomRight)

	--disable side bonus bars
	disableBarFrame(MultiBarLeft)
	disableBarFrame(MultiBarRight)
	disableBarFrame(MultiBar5)
	disableBarFrame(MultiBar6)
	disableBarFrame(MultiBar7)

	--disable all other action bars
	disableBarFrame(MicroButtonAndBagsBar)
	disableBarFrame(StanceBar)
	disableBarFrame(StanceBarFrame)
	disableBarFrame(PossessBar)
	disableBarFrame(PossessBarFrame)
	disableBarFrame(MultiCastActionBarFrame)
	disableBarFrame(PetActionBar)
	disableBarFrame(PetActionBarFrame)
	disableBarFrame(ZoneAbilityFrame)
	disableBarFrame(ExtraAbilityContainer)
	disableBarFrame(ExtraActionBarFrame)
	disableBarFrame(MainMenuBarVehicleLeaveButton)

	--disable status bars
	disableBarFrame(MainMenuExpBar)
	disableBarFrame(ReputationWatchBar)
	disableBarFrame(MainMenuBarMaxLevelBar)

	--disable override action bars
	disableBarFrame(OverrideActionBar)

	----------------------------
	------- Disable Misc -------
	----------------------------
	--disable the ActionBarController to avoid potential for taint
	ActionBarController:UnregisterAllEvents()

	--disable the controller for status bars as we're going to handle this ourselves
	if StatusTrackingBarManager then
		StatusTrackingBarManager:Hide()
		StatusTrackingBarManager:UnregisterAllEvents()
	end

	--these two get called when opening the spellbook so it's best to just silence them ahead of time
	if not Neuron:IsHooked("MultiActionBar_ShowAllGrids") then
		Neuron:RawHook("MultiActionBar_ShowAllGrids", function() end, true)
	end
	if not Neuron:IsHooked("MultiActionBar_HideAllGrids") then
		Neuron:RawHook("MultiActionBar_HideAllGrids", function() end, true)
	end


	----------------------------
	----- Disable Tutorial -----
	----------------------------
	--it's important we shut down the tutorial or we will get a ton of errors
	--this cleanly shuts down the tutorial and returns visibility to all UI elements hidden
	if Tutorials then --the Tutorials table is only available during the tutorial scenario, ignore if otherwise
		Tutorials:Shutdown()
	end
end

function Neuron:ToggleBlizzUI()
	local DB = Neuron.db.profile

	if InCombatLockdown() then
		return
	end

	if DB.blizzbar == true then
		DB.blizzbar = false
		Neuron:HideBlizzardUI()
		StaticPopup_Hide("ReloadUI")
	else
		DB.blizzbar = true
		StaticPopup_Show("ReloadUI")
	end
end

function Neuron:Overrides()
	local DB = Neuron.db.profile

	--bag bar overrides
	if DB.blizzbar == false then
		--hide the weird color border around bag bars
		CharacterBag0Slot.IconBorder:Hide()
		CharacterBag1Slot.IconBorder:Hide()
		CharacterBag2Slot.IconBorder:Hide()
		CharacterBag3Slot.IconBorder:Hide()

		--overwrite the Show function with a null function because it keeps coming back and won't stay hidden
		if not Neuron:IsHooked(CharacterBag0Slot.IconBorder, "Show") then
			Neuron:RawHook(CharacterBag0Slot.IconBorder, "Show", function() end, true)
		end
		if not Neuron:IsHooked(CharacterBag1Slot.IconBorder, "Show") then
			Neuron:RawHook(CharacterBag1Slot.IconBorder, "Show", function() end, true)
		end
		if not Neuron:IsHooked(CharacterBag2Slot.IconBorder, "Show") then
			Neuron:RawHook(CharacterBag2Slot.IconBorder, "Show", function() end, true)
		end
		if not Neuron:IsHooked(CharacterBag3Slot.IconBorder, "Show") then
			Neuron:RawHook(CharacterBag3Slot.IconBorder, "Show", function() end, true)
		end
	end

	--status bar overrides
	local disableDefaultCast = false
	local disableDefaultMirror = false

	for _,v in ipairs(Neuron.BARIndex) do

		if v.barType == "StatusBar" then
			for _, button in ipairs(v.buttons) do
				if button.config.sbType == "cast" then
					disableDefaultCast = true
				elseif button.config.sbType == "mirror" then
					disableDefaultMirror = true
				end
			end
		end
	end

	if disableDefaultCast then
		disableBarFrame(CastingBarFrame)
	end

	if disableDefaultMirror then
		UIParent:UnregisterEvent("MIRROR_TIMER_START")
		disableBarFrame(MirrorTimer1)
		disableBarFrame(MirrorTimer2)
		disableBarFrame(MirrorTimer3)
	end

end