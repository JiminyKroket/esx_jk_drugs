Config = {}

--Client Stuff--
Config.MarkerType   = 1
Config.DrawDistance = 100.0
Config.ZoneSize     = {x = 1.0, y = 1.0, z = -1.0}
Config.MarkerColor  = {r = 100, g = 204, b = 100}
Config.ShowBlips	= true -- Ehh, hopefully self explanatory... but if not it shows the pictures on the map for you
Config.ShowMarkers 	= false -- Ehh, hopefully self explanatory... but if not it shows the circles on the ground for you

--Cop Stuff--
Config.GiveBlack = true -- Disable to give regular cash when selling drugs
Config.ForceMulti	= false -- Force sellers to have to open the menu after every deal (chance to send notification)
Config.EnableCops   = false -- Set true to send police notification (uses esx_phone)
Config.RequireCops	= false -- Requires Police online to sell drugs
Config.RequiredCopsCoke  = 1
Config.RequiredCopsMeth  = 1
Config.RequiredCopsWeed  = 1
Config.RequiredCopsOpium = 1
Config.RequiredCopsHerin = 1
Config.RequiredCopsCrack = 1

--Language--
Config.Locale = 'en' -- Only fully supported for English

--Script Stuff--
Config.Delays = {
	WeedProcessing = 1000 * 10,
	CocaineProcessing = 2000 * 10,
	EphedrineProcessing = 2000 * 10,
	MethProcessing = 2000 * 10,
	PoppyProcessing = 2000 * 10,
	CrackProcessing = 2000 * 10,
	HeroineProcessing = 1000 * 10
}

Config.WeedDumpItems = {
	marijuana = 25,
	cannabis  = 1,
	dabs	  = 120,
}

Config.CocaineDumpItems = {
	cocaine = 95,
	coca	= 5,
}

Config.MethDumpItems = {
	meth = 135,
	ephedra = 10,
	ephedrine = 25,
}

Config.CrackDumpItems = {
	crack = 135,
}

Config.OpiumDumpItems = {
	opium = 75,
	poppy = 10,
}

Config.HeroineDumpItems = {
	heroine = 165
}

Config.FieldZones = {
	WeedField = {coords = vector3(2224.2, 5566.53, 54.06)},	
	CocaineField = {coords = vector3(1849.8, 4914.2, 44.92)},	
	EphedrineField = {coords = vector3(1591.18, -1982.81, 95.12)},
	PoppyField = {coords = vector3(-1815.83, 1972.43, 132.71)},
}

Config.ProcessZones = {
	WeedProcessing = {coords = vector3(2329.02, 2571.29, 46.68), name = 'Hippy Hangout', color = 25, sprite = 496, radius = 1.0},
	CocaineProcessing = {coords = vector3(-2083.58, -1011.96, 5.88), name = 'Yacht', color = 4, sprite = 455, radius = 1.0},
	EphedrineProcessing = {coords = vector3(-1078.62, -1679.62, 4.58), name = 'Vagos Garage', color = 62, sprite = 310, radius = 1.0},
	MethProcessing = {coords = vector3(1391.94, 3605.94, 38.94), name = 'Liquor Ace', color = 25, sprite = 93, radius = 1.0},
	CrackProcessing = {coords = vector3(974.72, -100.91, 74.87), name = 'Lost MC Clubhouse', color = 72, sprite = 226, radius = 1.0},
	PoppyProcessing ={coords = vector3(3559.76, 3674.54, 28.12), name = 'Humane Labs', color = 38, sprite = 499, radius = 1.0},
	HeroineProcessing = {coords = vector3(1976.76, 3819.58, 33.45), name = 'Trevor\'s', color = 59, sprite = 388, radius = 1.0},
}

Config.DumpZones = {
	WeedDump = {coords = vector3(-1172.02, -1571.98, 4.66), name = 'Smoke On The Water', color = 25, sprite = 140, radius = 1},
	CocaineDump = {coords = vector3(-1366.66, 56.67, 54.1), name = 'Golf Club', color = 62, sprite = 109, radius = 1.0},
	MethDump = {coords = vector3(-56.31, 6521.97, 31.49), name = 'Willie\'s Pharmacy', color = 49, sprite = 403, radius = 1.0},
	HeroineDump = {coords = vector3(-431.3, -2442.74, 26.88), name = 'Frederick\'s Crane', color = 25, sprite = 68, radius = 1.0},
	OpiumDump = {coords = vector3(2454.94, 4980.58, 46.82), name = 'O\'Neil Farm', color = 59, sprite = 387, radius = 1.0},
	CrackDump = {coords = vector3(-4.88, -1227.61, 29.3), name = 'Homeless Hostel', color = 49, sprite = 456, radius = 1.0},
}

Config.Peds = {
	WeedProcess =		{ ped = -264140789, x = 2328.29, y = 2569.61,	z = 45.68, 	h = 325.04 },
	CokeProcess =		{ ped = -264140789, x = -2084.48, y = -1011.68,	z = 4.88,	h = 252.42 },
	EphedrineProcess =	{ ped = 516505552, x = -1079.49, y = -1679.92,	z = 3.58,	h = 181.96 },
	MethProcess =		{ ped = 516505552, x = 1976.83,	y = 3819.67,	z = 32.45,	h = 120.83 },
	OpiumProcess =		{ ped = -730659924, x = 3559.03, y = 3674.78,	z = 27.12,	h = 224.32 },
	CrackProcess =		{ ped = -730659924, x = 973.68, y = -100.35,	z = 73.85,	h = 277.73 },
}