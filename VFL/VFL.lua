-- VFL.lua
-- VFL
-- (C)2005-2006 Bill Johnson and the VFL Project
--

--- The root World of Warcraft event dispatcher
WoWEvents = CreateFrame("Frame"); WoWEvents:Show();
DispatchTable:SubsumeFrame(WoWEvents);

--- The VFL root event dispatcher.
VFLEvents = DispatchTable:new();
VFLEvents.name = "VFLEvents";

