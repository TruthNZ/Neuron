--Neuron, a World of Warcraft® user interface addon.

--This file is part of Neuron.
--
--Neuron is free software: you can redistribute it and/or modify
--it under the terms of the GNU General Public License as published by
--the Free Software Foundation, either version 3 of the License, or
--(at your option) any later version.
--
--Neuron is distributed in the hope that it will be useful,
--but WITHOUT ANY WARRANTY; without even the implied warranty of
--MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
--GNU General Public License for more details.
--
--You should have received a copy of the GNU General Public License
--along with Foobar.  If not, see <https://www.gnu.org/licenses/>.
--
--Copyright for portions of Neuron are held by Connor Chenoweth,
--a.k.a Maul, 2014 as part of his original project, Ion. All other
--copyrights for Neuron are held by Britt Yazel, 2017-2018.

---@class MENUBTN : BUTTON @define class MENUBTN inherits from class BUTTON
local MENUBTN = setmetatable({}, {__index = Neuron.BUTTON})
Neuron.MENUBTN = MENUBTN


---------------------------------------------------------

---Constructor: Create a new Neuron BUTTON object (this is the base object for all Neuron button types)
---@param bar BAR @Bar Object this button will be a child of
---@param buttonID number @Button ID that this button will be assigned
---@param defaults table @Default options table to be loaded onto the given button
---@return MENUBTN @ A newly created MENUBTN object
function MENUBTN:new(bar, buttonID, defaults)

	---call the parent object constructor with the provided information specific to this button type
	local newButton = Neuron.BUTTON:new(bar, buttonID, MENUBTN, "MenuBar", "MenuButton", "NeuronAnchorButtonTemplate")

	if (defaults) then
		newButton:SetDefaults(defaults)
	end
	newButton:LoadData(GetActiveSpecGroup(), "homestate")
	newButton:LoadAux()

	return newButton
end


---------------------------------------------------------

local menuElements = {
	CharacterMicroButton,
	SpellbookMicroButton,
	TalentMicroButton,
	AchievementMicroButton,
	QuestLogMicroButton,
	GuildMicroButton,
	LFDMicroButton,
	CollectionsMicroButton,
	EJMicroButton,
	StoreMicroButton,
	MainMenuMicroButton}


function MENUBTN:SetType()

	if not self:IsEventRegistered("PET_BATTLE_CLOSE") then --only run this code on the first SetType, not the reloads after pet battles and such
		self:RegisterEvent("PET_BATTLE_CLOSE")
	end

	if not Neuron:IsHooked("MoveMicroButtons") then --we need to intercept MoveMicroButtons for during pet battles
		Neuron:RawHook("MoveMicroButtons", function(...) MENUBTN.ModifiedMoveMicroButtons(...) end, true)
	end

	if (menuElements[self.id]) then

		self:SetWidth(menuElements[self.id]:GetWidth()-2)
		self:SetHeight(menuElements[self.id]:GetHeight()-2)

		self:SetHitRectInsets(self:GetWidth()/2, self:GetWidth()/2, self:GetHeight()/2, self:GetHeight()/2)

		self.element = menuElements[self.id]

		self.element:ClearAllPoints()
		self.element:SetParent(self)
		self.element:Show()
		self.element:SetPoint("CENTER", self, "CENTER")
		self.element:SetScale(1)
	end

end


function MENUBTN:SetData(bar)
	if (bar) then
		self.bar = bar
		self:SetFrameStrata(bar.data.objectStrata)
		self:SetScale(bar.data.scale)
	end

	self:SetFrameLevel(4)
end


function MENUBTN:PET_BATTLE_CLOSE()
	---we have to reload SetType to put the buttons back at the end of the pet battle
	self:SetType()
end


---this overwrites the default MoveMicroButtons and basically just extends it to reposition all the other buttons as well, not just the 1st and 6th.
---This is necessary for petbattles, otherwise there's no menubar
function MENUBTN.ModifiedMoveMicroButtons(anchor, anchorTo, relAnchor, x, y, isStacked)

	menuElements[1]:ClearAllPoints();
	menuElements[1]:SetPoint(anchor, anchorTo, relAnchor, x-5, y+4);

	for i=2,11 do
		menuElements[i]:ClearAllPoints();
		menuElements[i]:SetPoint("BOTTOMLEFT", menuElements[i-1], "BOTTOMRIGHT", -2,0)
		if isStacked and i == 6 then
			menuElements[6]:ClearAllPoints();
			menuElements[6]:SetPoint("TOPLEFT", menuElements[1], "BOTTOMLEFT", 0,2)
		end
	end

	MainMenuMicroButton_RepositionAlerts();
	UpdateMicroButtons();
end