--[[
    DescriptionSummary
    by MistressNebula

    A simple summary menu that displays a custom description and nothing more.
    It's basically a discount "ItemSummary" with neither price nor rarity slot.
]]

--- Summary menu that displays a description box.
DescriptionSummary = Class("DescriptionSummary")

--- Generates a new DescriptionSummary object set in the provided coordinates.
--- @param left number the x coordinate of the left side of the window.
--- @param top number the y coordinate of the top side of the window.
--- @param right number the x coordinate of the right side of the window.
--- @param bottom number the y coordinate of the bottom side of the window.
function DescriptionSummary:initialize(left, top, right, bottom)
    self.window = RogueEssence.Menu.SummaryMenu(RogueElements.Rect.FromPoints(
            RogueElements.Loc(left, top), RogueElements.Loc(right, bottom)))

    local GraphicsManager = RogueEssence.Content.GraphicsManager
    self.description_box = RogueEssence.Menu.DialogueText("", RogueElements.Rect.FromPoints(
            RogueElements.Loc(GraphicsManager.MenuBG.TileWidth * 2, GraphicsManager.MenuBG.TileHeight),
            RogueElements.Loc(self.window.Bounds.Width - GraphicsManager.MenuBG.TileWidth * 4, self.window.Bounds.Height - GraphicsManager.MenuBG.TileHeight * 4)),
            12);
    self.window.Elements:Add(self.description_box);
end

--- sets the provided string as the currently displayed description.
--- @param description string the description to be set.
function DescriptionSummary:setDescription(description)
    self.description_box:SetAndFormatText(description);
end