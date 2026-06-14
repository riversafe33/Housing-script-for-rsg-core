
Config = {}

Config.DevMode = false
Config.Debug   = false

Config.Checkpoints = { rotate = false, size = 0.85, height = 0.14, rgba = {0, 255, 0, 50},}

Keys = { 
    ["ENTER"] = 0xC7B5340A ,["BACKSPACE"] = 0x156F7119, ["G"] = 0x760A9C6F, ["SPACEBAR"] = 0xD9D0E1C0, 
    ["A"] = 0x7065027D, ["D"] = 0xB4E465B4, ["S"] = 0xD27782E3, ["W"] = 0x8FD015D8,
    ["DOWN"] = 0x3C3DD371, ["UP"] = 0x446258B6, ["LEFT"] = 0xA65EBAB4, ["RIGHT"] = 0xDEB34313,
    ['R'] = 0xE30CD707, ['ZOOM_IN'] = 0x62800C92, ['ZOOM_OUT'] = 0x8BDE7443, ['B'] = 0x4CC0E2FE, 
    ['L'] = 0x80F28E95,
}    

Config.PromptKeys     = {
    ['SELL']      = { type = "PROPERTY_BUY_ACTIONS", key = "SPACEBAR",  label = "Sell Property To",    hold = 1000 },
    ['BUY']       = { type = "PROPERTY_BUY_ACTIONS", key = "G",         label = "Buy Property",        hold = 1000 },
    ['MENU_OPEN'] = { type = "MENU_ACTIONS",         key = "L",         label = "Press",               hold = 750 },
    ['STORAGE']   = { type = "MENU_ACTIONS",         key = "R",         label = "Open",                hold = 750 },
    ['WARDROBE']  = { type = "MENU_ACTIONS",         key = "SPACEBAR",  label = "Checkout",            hold = 750 },
    ['TELEPORT']  = { type = "TELEPORT",             key = "G",         label = "Property",            hold = 1000 },
}

-- If your server is receiving query errors and displaying that a property does not exist when it really does
-- the option below will fix your problem, this problem is for low-pc or servers in general but can also caused
-- through oxmysql.
Config.StartQueryDelay = 1 -- Time in seconds (5-10 will fix your problem)

-- The following option is saving all the data before server restart hours
-- (2-3 Minutes atleast before server restart is mostly preferred).
Config.RestartHours = { "7:57" , "13:57", "19:57", "1:57"}

-- As default, we save all data every 15 minutes to avoid data loss in case for server crashes.
-- Duration = Time in minutes.
Config.SaveDataRepeatingTimer = { Enabled = true, Duration = 15 }

-- How many houses should each player have on their character?
Config.MaxHouses = 2

-- How many players should have access to a property? 
Config.MaxHouseKeyHolders = 10

-- Config.RealEstateJob.Enabled Set to false if you don't want the properties to be sold from a job.
-- If not set to false, only the following job can sell properties to the players.
-- ReceivePercentage the percentage real estate job will receive when selling a property.
-- Ex. If a property costs $300, and ReceivePercentage is 5%, the seller will receive $15.
Config.RealEstateJob = { Enabled = false, Job = "realestate", ReceivePercentage = 5 }

-- Set it to false if you don't want the players to be teleported outside of their property after selecting a character.
-- We provide this system in case they bug inside or other players who left inside that property to be teleported outside.
Config.TeleportOutsideOnJoin = { Enabled = true, ClosestDistance = 10.0 }

-- to open their wardrobe, change the event trigger below.
Config.WardrobeEventTrigger = "rsg-appearance:client:openWardrobe"

-- Set to false if you want the storage to be set as "private", only owner and the keyholders with permission access will be able to open the storage
-- and not other players.
Config.StorageAllowPublicAccess = false

-- Options in the property management menu to display / not based on your personal and server preferences.
-- (!) DO NOT MODIFY THE TYPE NAMES.
Config.ManagementMenu = {
    { Type = 'MENU_WARDROBE_LOCATION', Enabled = true }, -- set wardrobe location menu option
    { Type = 'MENU_STORAGE_LOCATION',  Enabled = true }, -- set storage location menu option
    { Type = 'MENU_LEDGER_HOME',       Enabled = true }, -- deposit or withdraw money from the ledgerhome menu option
    { Type = 'MENU_SET_KEYHOLDERS',    Enabled = true }, -- set property keyholders (members to have access to the house) menu option
    { Type = 'MENU_TRANSFER',          Enabled = true }, -- transfer the property to another player menu option
    { Type = 'MENU_SELL',              Enabled = true }, -- sell the property menu option
}

Config.DoorKey = 0x760A9C6F

Config.keysPlace = {
    Create = 0x760A9C6F,
    Confirm = 0xC7B5340A,
    Cancel = 0x8F9F9E58,
}

Config.RenderDoorStateDistance = 30
Config.PropertyBlips = {
    Owned  = { Sprite = -235048253, Color = 0xF91DD38D },
    OnSale = { Sprite = 444204045, Color = 0xA5C4F725, DisplayPropertyId = true, DisplayThroughRenderingDistance = false },
    Keyholders = { Enabled = true, Sprite = -235048253 },
}

Config.TaxRepoSystem = {
    -- Enables or disables the system
    Enabled = false,

    -- MONTHLY REPO
    Monthly = false,          -- true = activate monthly repo
    Day     = 28,             -- day of the month
    Hour    = 21,             -- hour
    Minute  = 30,             -- minute

    -- WEEKLY REPO
    Weekly = true,                  -- true = activate weekly repo
    WeekDays = { 7, 17, 21 ,28  },  -- days of the week
    Hour     = 21,                  -- hour       
    Minute   = 30,                  -- minute
}

-- Distance at which the preview furniture appears in front of the player
Config.PreviewDistance = 5
-- Rotation speed of the preview furniture (degrees per tick)
Config.RotationSpeed = 1.0
-- Key used to open the shop menu
Config.ShopKey = 0x760A9C6F
-- Radius around the shop coords to show the interaction prompt
Config.PromptRadius = 2.0
Config.Locations = {
    [1] = { -- Valentine
        coords = vec3(-369.35, 734.49, 116.62),
        label  = "Furniture Store",
        camera = vec4(-368.88, 731.83, 116.15, 184.41),
        blip = {
            enabled = true,        -- true to show blip on map, false to hide it
            sprite  = -1954662204, -- blip icon hash
            scale   = 1.0,         -- blip size on the map
        },
    },
    [2] = { -- Rhodes
        coords = vec3(1267.54, -1299.75, 76.98),
        label  = "Furniture Store",
        camera = vec4(1270.55, -1300.11, 75.84, 235.01),
        blip = {
            enabled = true,
            sprite  = -1954662204,
            scale   = 1.0,
        },
    },
    -- add what you want
}

-- If any object appears stuck to the ground or sunk into the floor, put it here and add 1.0.
Config.PropOffset = {
    ["p_indiandream01x"] = 1.0,
    ["p_deerantchandelier01x"] = 1.0,
    ["p_lamp17x"] = 1.0,
    ["p_lamp03x"] = 1.0,
}

-- If Config.furnitureitems = true, the furniture shop is enabled and furniture can only be placed if you have the items.
-- If Config.furnitureitems = false, the shop is disabled and Furniture can only be placed from the house menu.
Config.furnitureitems = true  
Config.furniturelimit = 100    -- limit of furniture per player
Config.furnituresellrate = 0.6 -- 0.6 equals 60% of the item's original price when selling furniture
Config.furniture = {
    ["Chairs"] = {
        ["Outdoor Chair 1"] = { cost = 10, hash = `mp005_s_posse_trad_chair01x`, item = "furniture_31"},
        ["Outdoor Chair 2"] = { cost = 10, hash = `mp005_s_posse_col_chair01x`, item = "furniture_32"},
        ["Barber Chair"] = { cost = 10, hash = `p_barberchair03x`, item = "furniture_33"},
        ["Wood Chair 1"] = { cost = 10, hash = `p_chair07x`, item = "furniture_34"},
        ["Wood Chair 2"] = { cost = 10, hash = `p_chair15x`, item = "furniture_35"},
        ["Wood Chair 3"] = { cost = 10, hash = `p_windsorchair03x`, item = "furniture_37"},
        ["Wood Chair 4"] = { cost = 10, hash = `p_chair05x`, item = "furniture_38"},
        ["Wood Chair 5"] = { cost = 10, hash = `p_chair11x`, item = "furniture_39"},
        ["Wood Desk Chair"] = { cost = 10, hash = `p_woodendeskchair01x`, item = "furniture_40"},
        ["Wrought Iron Chair"] = { cost = 10, hash = `p_bistrochair01x`, item = "furniture_46"},
        ["White Fabric Wooden Chair"] = { cost = 10, hash = `p_chairdining01x`, item = "furniture_36"},
        ["Rocking Chair 1"] = { cost = 10, hash = `p_chairrocking03x`, item = "furniture_41"},
        ["Rocking Chair 2"] = { cost = 10, hash = `p_rockingchair01x`, item = "furniture_42"},
    },
    ["Armchairs"] = {
        ["Floral Fabric Armchair"] = { cost = 10, hash = `p_chaircomfy01x`, item = "furniture_01"},
        ["Grey Fabric Armchair"] = { cost = 10, hash = `p_chaircomfy02`, item = "furniture_02"},
        ["Red Pattern Armchair"] = { cost = 10, hash = `p_chaircomfy05x`, item = "furniture_03"},
        ["Red Armchair"] = { cost = 10, hash = `p_chaircomfy11x`, item = "furniture_04"},
        ["White Armchair"] = { cost = 10, hash = `p_chaircomfy12x`, item = "furniture_05"},
        ["Pink Armchair"] = { cost = 10, hash = `p_chaircomfy22x`, item = "furniture_06"},
        ["Brown Armchair"] = { cost = 10, hash = `p_chaircomfy23x`, item = "furniture_07"},
        ["Eagle Armchair"] = { cost = 10, hash = `p_chaireagle01x`, item = "furniture_23"},
        ["Leather Armchair"] = { cost = 10, hash = `p_chairdesk02x`, item = "furniture_24"},
        ["Wicker Cushion Armchair"] = { cost = 10, hash = `p_chairwicker03x`, item = "furniture_29"},
        ["Wicker Armchair"] = { cost = 10, hash = `p_chairwicker02x`, item = "furniture_30"},
    },
    ["Sofas"] = {
        ["White Fabric Sofa"] = { cost = 10, hash = `p_victoriansofa01x`, item = "furniture_08"},
        ["Red Fabric Sofa"] = { cost = 10, hash = `p_couch05x`, item = "furniture_09"},
        ["Leather Sofa"] = { cost = 10, hash = `p_couch10x`, item = "furniture_10"},
        ["Yellow Fabric Sofa"] = { cost = 10, hash = `p_sofa01x`, item = "furniture_11"},
        ["Yellow 3-Seater Sofa"] = { cost = 10, hash = `p_settee02x`, item = "furniture_25"},
        ["Yellow 2-Seater Sofa"] = { cost = 10, hash = `p_settee02bx`, item = "furniture_26"},
    },
    ["Benches"] = {
        ["Wicker Bench"] = { cost = 10, hash = `p_sit_chairwicker01a`, item = "furniture_12"},
        ["Wood Bench"] = { cost = 10, hash = `p_benchch01x`, item = "furniture_13"},
        ["Iron Bench"] = { cost = 10, hash = `p_benchironnbx01x`, item = "furniture_14"},
        ["Iron Bench 2"] = { cost = 10, hash = `p_benchironnbx02x`, item = "furniture_15"},
        ["Iron Bench 3"] = { cost = 10, hash = `p_benchnbx03x`, item = "furniture_28"},
        ["Backless Wooden Bench"] = { cost = 10, hash = `p_benchannsaloon01x`, item = "furniture_17"},
        ["Bear Bench"] = { cost = 10, hash = `p_benchbear01x`, item = "furniture_18"},
        ["Green Fabric Bench"] = { cost = 10, hash = `p_seatbench01x`, item = "furniture_19"},
        ["Log Bench"] = { cost = 10, hash = `p_bench_log03x`, item = "furniture_20"},
        ["Log Bench 3"] = { cost = 10, hash = `p_bench_log04x`, item = "furniture_22"},
        ["Piano Bench 1"] = { cost = 10, hash = `p_benchpiano02x`, item = "furniture_43"},
        ["Stool Piano"] = { cost = 10, hash = `p_stool02x`, item = "furniture_45"},
    },
    ["Tables"] = {
        ["Decorated Round Table"] = { cost = 20, hash = `p_group_man01x_tableround`, item = "furniture_48"},
        ["Small Side Table"] = { cost = 20, hash = `p_sawbucktable01x`, item = "furniture_49"},
        ["Square Wooden Table"] = { cost = 20, hash = `p_table06x`, item = "furniture_50"},
        ["Rectangular Table Cloth"] = { cost = 20, hash = `p_table10x`, item = "furniture_51"},
        ["Rustic Rectangular Table"] = { cost = 20, hash = `p_table11x`, item = "furniture_52"},
        ["Square Table Cloth"] = { cost = 20, hash = `p_table14x`, item = "furniture_53"},
        ["Light Rectangular Table"] = { cost = 20, hash = `p_table41x`, item = "furniture_54"},
        ["Rectangular Table 1"] = { cost = 20, hash = `p_table51x`, item = "furniture_55"},
        ["Wood Dining Table"] = { cost = 20, hash = `p_tabledining04x`, item = "furniture_56"},
        ["Dark Rectangular Table"] = { cost = 20, hash = `p_tabledining05x`, item = "furniture_57"},
        ["Medium Round Table"] = { cost = 20, hash = `p_tablemahogany01x`, item = "furniture_58"},
        ["Low Rectangular Table"] = { cost = 20, hash = `p_tableprep01x`, item = "furniture_59"},
        ["Rectangular Booth Table"] = { cost = 20, hash = `p_tablebooth01x`, item = "furniture_60"},
        ["Leather Coffee Table"] = { cost = 20, hash = `p_tablecoffee05x`, item = "furniture_61"},
        ["Office Desk 1"] = { cost = 20, hash = `p_bw_desk01x`, item = "furniture_62"},
        ["Office Desk 2"] = { cost = 20, hash = `p_desk09bx`, item = "furniture_63"},
        ["Office Desk 3"] = { cost = 20, hash = `p_desk13x`, item = "furniture_64"},
        ["Work Desk"] = { cost = 20, hash = `p_workbenchdesk01x`, item = "furniture_65"},
        ["Marble Entry Table"] = { cost = 20, hash = `p_plantstand01x`, item = "furniture_66"},
        ["Wood Entry Table"] = { cost = 20, hash = `p_sidetable02x`, item = "furniture_67"},
        ["Tall Entry Table"] = { cost = 20, hash = `p_sidetable10x`, item = "furniture_68"},
    },
    ["Beds"] = {
        ["Medical Bed"] = { cost = 10, hash = `p_medbed01x`, item = "furniture_47"},
        ["Marriage Bed 1"] = { cost = 10, hash = `p_bed20madex`, item = "furniture_69"},
        ["Marriage Bed 2"] = { cost = 20, hash = `p_bedking01x`, item = "furniture_71"},
        ["Marriage Bed 3"] = { cost = 30, hash = `p_bedking02x`, item = "furniture_74"},
        ["Marriage Bed 4"] = { cost = 50, hash = `p_bed10x`, item = "furniture_75"},
        ["Single Bed 1"] = { cost = 50, hash = `p_bed21x`, item = "furniture_70"},
        ["Single Bed 2"] = { cost = 50, hash = `p_bed03x`, item = "furniture_72"},
        ["Single Bed 3"] = { cost = 50, hash = `p_bed05x`, item = "furniture_73"},
        ["Single Bed 4"] = { cost = 50, hash = `s_bedarthur01x`, item = "furniture_76"},
    },
    ["Dressers"] = {
        ["Tall Mirror Dresser"] = { cost = 25, hash = `p_dresser09x`, item = "furniture_77"},
        ["Wide Mirror Dresser"] = { cost = 35, hash = `p_dresser07x`, item = "furniture_78"},
        ["3 Drawer Dresser"] = { cost = 20, hash = `p_chest02x`, item = "furniture_79"},
        ["4 Drawer Dresser"] = { cost = 15, hash = `p_commode01x`, item = "furniture_80"},
    },
    ["Nightstands"] = {
        ["Tall Nightstand"] = { cost = 25, hash = `p_commodini01x`, item = "furniture_81"},
        ["1 Drawer Nightstand"] = { cost = 25, hash = `p_tablework02x`, item = "furniture_82"},
        ["Cabinet Nightstand"] = { cost = 25, hash = `p_cabinet15x`, item = "furniture_83"},
        ["Cabinet Nightstand 2"] = { cost = 25, hash = `p_tablebedside02x`, item = "furniture_94"},
    },
    ["Wardrobes"] = {
        ["Mahogany Wardrobe"] = { cost = 25, hash = `p_cabinet03x`, item = "furniture_84"},
        ["Light Wood Wardrobe"] = { cost = 25, hash = `p_armoir04x`, item = "furniture_86"},
    },
    ["Shelves"] = {
        ["Kitchen Shelf 1"] = { cost = 25, hash = `p_kitchenhutch01x`, item = "furniture_87"},
        ["Corner Shelf"] = { cost = 25, hash = `p_cupboardcorner01x`, item = "furniture_88"},
        ["White Shelf"] = { cost = 25, hash = `p_hutchwhite01x`, item = "furniture_89"},
        ["Postal Cabinet Shelf"] = { cost = 25, hash = `p_cabinetpostal01x`, item = "furniture_90"},
        ["China Cabinet Shelf"] = { cost = 25, hash = `p_cabinetchina04x`, item = "furniture_91"},
        ["Doctor Cabinet Shelf"] = { cost = 25, hash = `p_cabinetdoctor01x`, item = "furniture_93"},
    },
    ["Bathroom"] = {
        ["Bathtub 1"] = { cost = 25, hash = `p_bath02bx`, item = "furniture_95"},
        ["Bathtub 2"] = { cost = 25, hash = `p_bath02x`, item = "furniture_96"},
        ["Bathtub 3"] = { cost = 25, hash = `p_bath03x`, item = "furniture_114"},
        ["Bathtub 4"] = { cost = 25, hash = `p_val_hotel_int_tub_01x`, item = "furniture_115"},
        ["Sink 1"] = { cost = 25, hash = `p_washbasndoctor01x`, item = "furniture_116"},
        ["Sink 2"] = { cost = 25, hash = `p_cs_sink03x`, item = "furniture_117"},
    },
    ["Lights"] = {
        ["Floor Lamp 1"] = { cost = 25, hash = `p_medlight02x`, item = "furniture_97"},
        ["Floor Lamp 2"] = { cost = 25, hash = `p_lampstanding09x`, item = "furniture_98"},
        ["Floor Lamp 3"] = { cost = 25, hash = `p_lampstanding03x`, item = "furniture_99"},
        ["Table Lamp 1"] = { cost = 25, hash = `p_lamp25x`, item = "furniture_100"},
        ["Table Lamp 2"] = { cost = 25, hash = `p_lamp32x`, item = "furniture_101"},
        ["Ceiling Lamp 1"] = { cost = 25, hash = `p_gnomeoillamp03x`, item = "furniture_102"},
        ["Ceiling Lamp 2"] = { cost = 25, hash = `p_lamp17x`, item = "furniture_103"},
        ["Ceiling Lamp 3"] = { cost = 25, hash = `p_lamp03x`, item = "furniture_104"},
        ["Ceiling Lamp 4"] = { cost = 25, hash = `p_deerantchandelier01x`, item = "furniture_118"},
        ["Wall Lamp 1"] = { cost = 25, hash = `p_lampexterior04x`, item = "furniture_105"},
        ["Wall Lamp 2"] = { cost = 25, hash = `p_sconcelight01x`, item = "furniture_106"},
        ["Wall Lamp 3"] = { cost = 25, hash = `p_lampwall08x`, item = "furniture_107"},
        ["Street Lamp"] = { cost = 25, hash = `p_nbdstreetlamp01x`, item = "furniture_108"},
        ["Lantern 1"] = { cost = 25, hash = `p_lantern05x`, item = "furniture_109"},
        ["Lantern 2"] = { cost = 25, hash = `p_lantern09x`, item = "furniture_110"},
        ["Candle Holder"] = { cost = 25, hash = `p_candlestick03x`, item = "furniture_111"},
        ["Burning Log"] = { cost = 25, hash = `s_splitfirelog02x`, item = "furniture_112"},
        ["Torch"] = { cost = 25, hash = `p_torchpostalwayson01x`, item = "furniture_113"},
    },
    ["Fires"] = {
        ["Fireplace Fire"] = { cost = 25, hash = `p_fireplacelogs03x_unlit`, item = "furniture_119"},
        ["Stove"] = { cost = 25, hash = `p_stove04x`, item = "furniture_120"},
        ["Campfire"] = { cost = 25, hash = `p_campfire03x_nofire`, item = "furniture_121"},
    },
    ["Decoration"] = {
        ["Water Pump"] = { cost = 10, hash = -40350080, item = "furniture_134"},
        ["Flower Boxes"] = { cost = 5, hash = 456717314, item = "furniture_128"},
        ["Deer Pelt"] = { cost = 10, hash = -944201792, item = "furniture_126"},
        ["Blanket Box"] = { cost = 5, hash = -542120195, item = "furniture_122"},
        ["Wash Tub"] = { cost = 5, hash = 768802576, item = "furniture_133"},
        ["Coyote Taxidermy"] = { cost = 25, hash = 755719297, item = "furniture_125"},
        ["Pheasant Taxidermy"] = { cost = 10, hash = -139659644, item = "furniture_130"},
        ["Deer Taxidermy"] = { cost = 15, hash = 270188936, item = "furniture_127"},
        ["Cougar Taxidermy"] = { cost = 30, hash = 106531847, item = "furniture_123"},
        ["Vulture Taxidermy"] = { cost = 10, hash = 1751914218, item = "furniture_132"},
        ["Coat Stand"] = { cost = 10, hash = `p_doc_coatstandrack01x`, item = "furniture_141"},
        ["Canvas Shade"] = { cost = 10, hash = `p_mptenttanner01x`, item = "furniture_138"},
        ["Hitching Post"] = { cost = 10, hash = `p_hitchingpost01x`, item = "furniture_135"},
        ["Native Basket 1"] = { cost = 10, hash = `p_basketindian02x`, item = "furniture_136"},
        ["Dreamcatcher"] = { cost = 10, hash = `p_indiandream01x`, item = "furniture_137"},
        ["Christmas Tree"] = { cost = 10, hash = `mp006_p_xmastree01x`, item = "furniture_139"},
        ["Native Arms"] = { cost = 10, hash = `p_spookynative05x`, item = "furniture_140"},
    },
}


-- (!) DO NOT SET THE PROPERTY NAMES AS INTEGERS (EX: [1] = {} ), Should be like ['1'] = {} Instead to become a STRING (TEXT).
Config.Properties = {
    ['1'] = {
        Locations = {
            PrimaryEntrance = vector4(2388.472167, -1216.280151, 46.159191,2388.82), -- Purchase prompt position
            SecondaryExit   = vector4(0,0,0, 0),                                     -- Only applies if the house uses teleportation, coordinates where you appear when exiting the house
            MenuActions     = vector3(2379.97, -1215.13, 47.17),                     -- Menu position to manage the house
            ActionDistance  = 1.8, -- Don´t touch
        },
        hasTeleportationEntrance = false, -- Set to true if the house uses teleportation
        doors = { 
            {
                [1] = { 
                    objCoords = vector3(2387.641845703125, -1217.3890380859375, 46.15700531005859),   -- Door coordinates copied from spooni_spooner
                    objYaw = 89.57536315917969,                                                       -- Door yaw
                },
                [2] = { 
                    objCoords = vector3(2387.64208984375, -1215.185302734375, 46.15700531005859), 
                    objYaw = -90.39845275878906,
                },
            },
            { 
                [1] = { 
                    objCoords = vector3(2367.3681640625, -1208.4288330078125, 46.15700912475586), 
                    objYaw = -0.39099755883216,
                },

                -- If there is only one door set the second one to false
                [2] = false,
            },
            {
                [1] = { 
                    objCoords = vector3(2361.443359375, -1215.186279296875, 46.15700149536133), 
                    objYaw = -90.00000762939453,
                },
                [2] = { 
                    objCoords = vector3(2361.443359375, -1217.39013671875, 46.15700149536133), 
                    objYaw = 89.99998474121094,
                },
            },
        },
        purchaseMethods = {
            -- House price
            dollars = { cost = 7000},  
        },

        -- Amount received when selling the house
        sell = { receive = 175 }, 

        -- If Config.TaxRepoSystem is true this is the amount charged for taxes and if Config.TaxRepoSystem
        -- is true the house menu will show the tax ledger that only allows depositing this amount
        tax = 25,
    
        -- Maximum amount of money allowed in the Home Ledger
        ledgerLimit = 5000,

        -- Inventory space 1000000 = 1000kg  100000 = 100kg  10000 = 10kg
        defaultStorageWeight = 1000000, -- = 1000 Kg
    
        -- Maximum distance from the house where you can place the inventory or wardrobe
        actionsRange = 15.0,  
    },
    ['2'] = {
        Locations = {
            PrimaryEntrance = vector4(-255.700, 741.5248, 117.46, 295.30194091797), 
            SecondaryExit   = vector4(-258.198, 735.8474, 117.48, 121.615913391), 
            MenuActions     = vector3(-259.524, 738.9733, 118.18), 
            ActionDistance  = 1.8, -- Don´t touch
        },
        hasTeleportationEntrance = true,
        doors = { },
        purchaseMethods = {
            dollars = { cost = 150},
        },
        sell = { receive = 75 }, 
        tax = 25,
        ledgerLimit = 5000,
        defaultStorageWeight = 1000000, -- = 1000 Kg
        actionsRange = 10.0,
    },
    ['3'] = {
        Locations = {
            PrimaryEntrance = vector4(2988.195, 2193.384, 165.74, 77.14215087890), 
            SecondaryExit   = vector4(0,0,0, 0), 
            MenuActions     = vector3(2990.161, 2188.243, 166.78), 
            ActionDistance  = 1.8, -- Don´t touch
        },
        hasTeleportationEntrance = false,
        doors = { 
            {
                [1] = { 
                    objCoords = vector3(2989.107666015625, 2193.74072265625, 165.73980712890625), 
                    objYaw = -109.74124145507812,
                },
                [2] = false, 
            },
            {
                [1] = { 
                    objCoords = vector3(2993.42431640625, 2188.4375, 165.73570251464844), 
                    objYaw = 69.9999771118164,
                },
    
                [2] = false, 
            },
        },
        purchaseMethods = {
            dollars = { cost = 500},
        },
        sell = { receive = 250 }, -- 500 / 2 = 250 = - 50% of default price.
        tax = 25,
        ledgerLimit = 5000,
        defaultStorageWeight = 1000000, -- = 1000 Kg
        actionsRange = 20.0,
    },
    ['4'] = {
        Locations = {
            PrimaryEntrance = vector4(3024.494, 1776.168, 83.179, 167.34350585938), 
            SecondaryExit   = vector4(0,0,0, 0), 
            MenuActions     = vector3(3032.382, 1779.709, 84.132), 
            ActionDistance  = 1.8, -- Don´t touch
        },
        hasTeleportationEntrance = false,
        doors = { 
            {
                [1] = { 
                    objCoords = vector3(3024.12109375, 1777.0723876953125, 83.16913604736328), 
                    objYaw = -20.69721603393554,
                },
                [2] = false, 
            },
        },
        purchaseMethods = {
            dollars = { cost = 250},
        },
        sell = { receive = 125 },
        tax = 25,
        ledgerLimit = 5000,
        defaultStorageWeight = 1000000, -- = 1000 Kg
        actionsRange = 20.0,
    },
    ['5'] = {
        Locations = {
            PrimaryEntrance = vector4(2628.726, 1693.783, 116.53, 281.05822753906), 
            SecondaryExit   = vector4(0,0,0, 0),
            MenuActions     = vector3(2626.739, 1691.679, 115.68), 
            ActionDistance  = 1.8, -- Don´t touch
        },
        hasTeleportationEntrance = false,
        doors = { 
            {
                [1] = { 
                    objCoords = vector3(2628.221435546875, 1694.3289794921875, 114.66619110107422), 
                    objYaw = -101.51953887939453,
                },
                [2] = false, 
            },
        },
        purchaseMethods = {
            dollars = { cost = 300},
        },
        sell = { receive = 150 }, -- 300 / 2 = 150 = - 50% of default price.
        tax = 25,
        ledgerLimit = 5000,
        defaultStorageWeight = 1000000, -- = 1000 Kg
        actionsRange = 20.0,
    },
    ['6'] = {
        Locations = {
            PrimaryEntrance = vector4(1980.718, 1195.169, 170.96, 56.607650756836), 
            SecondaryExit   = vector4(0,0,0, 0), 
            MenuActions     = vector3(1980.667, 1191.524, 171.40), 
            ActionDistance  = 1.8, -- Don´t touch
        },
        hasTeleportationEntrance = false,
        doors = { 
            {
                [1] = { 
                    objCoords = vector3(1981.965087890625, 1195.0836181640625, 170.41778564453125), 
                    objYaw = -124.84463500976562,
                },
                [2] = false, 
            },
        },
        purchaseMethods = {
            dollars = { cost = 300},
        },
        sell = { receive = 150 }, -- 300 / 2 = 150 = - 50% of default price.
        tax = 25,
        ledgerLimit = 5000,
        defaultStorageWeight = 1000000, -- = 1000 Kg
        actionsRange = 20.0,
    },
    ['7'] = {
        Locations = {
            PrimaryEntrance = vector4(1866.304, 580.5608, 113.84, 165.69606018066), 
            SecondaryExit   = vector4(0,0,0, 0), 
           
            MenuActions     = vector3(1867.114, 587.8313, 113.92), 
            ActionDistance  = 1.8, -- Don´t touch
        },
        hasTeleportationEntrance = false,
        doors = { 
            {
                [1] = { 
                    objCoords = vector3(1867.09033203125, 581.2611083984375, 112.83411407470703), 
                    objYaw = 159.0830535888672,
                },
                [2] = false, 
            },
        },
        purchaseMethods = {
            dollars = { cost = 150},
        },
        sell = { receive = 75 }, 
        tax = 25,
        ledgerLimit = 5000,
        defaultStorageWeight = 1000000, -- = 1000 Kg
        actionsRange = 10.0,
    },
    ['8'] = {
        Locations = {
            PrimaryEntrance = vector4(2542.909, 699.4825, 79.726, 9.6655235290527), 
            SecondaryExit   = vector4(0,0,0, 0), 
           
            MenuActions     = vector3(2540.678, 697.8855, 80.745), 
            ActionDistance  = 1.8, -- Don´t touch
        },
        hasTeleportationEntrance = false,
        doors = { 
            {
                [1] = { 
                    objCoords = vector3(2542.505859375, 698.691650390625, 79.75918579101562), 
                    objYaw = 10.1307725906372,
                },
                [2] = false, 
            },
        },
        purchaseMethods = {
            dollars = { cost = 100},
        },
        sell = { receive = 50 }, -- 100 / 2 = 50 = - 50% of default price.
        tax = 25,
        ledgerLimit = 5000,
        defaultStorageWeight = 1000000, -- = 1000 Kg
        actionsRange = 10.0,
    },
    ['9'] = {
        Locations = {
            PrimaryEntrance = vector4(2717.219, 707.5354, 79.155, 200.75015258789), 
            SecondaryExit   = vector4(0,0,0, 0), 
            MenuActions     = vector3(2715.924, 711.2705, 79.522), 
            ActionDistance  = 1.8, -- Don´t touch
        },
        hasTeleportationEntrance = false,
        doors = { 
            {
                [1] = { 
                    objCoords = vector3(2716.814208984375, 708.1665649414062, 78.60517883300781), 
                    objYaw = 0.07928969711065,
                },
                [2] = false, 
            },
        },
        purchaseMethods = {
            dollars = { cost = 100},
        },
        sell = { receive = 50 }, -- 100 / 2 = 50 = - 50% of default price.
        tax = 25,
        ledgerLimit = 5000,
        defaultStorageWeight = 1000000, -- = 1000 Kg
        actionsRange = 10.0,
    },
    ['10'] = {
        Locations = {
            PrimaryEntrance = vector4(2819.894, 278.9041, 50.963, 45.582988739014), 
            SecondaryExit   = vector4(0,0,0, 0), 
            MenuActions     = vector3(2825.767, 277.375, 48.097), 
            ActionDistance  = 1.8, -- Don´t touch
        },
        hasTeleportationEntrance = false,
        doors = { 
            {
                [1] = { 
                    objCoords = vector3(2820.560791015625, 278.9088134765625, 50.09118270874023), 
                    objYaw = -135.00006103515625,
                },
                [2] = false, 
            },
            {
                [1] = { 
                    objCoords = vector3(2824.4970703125, 270.89910888671875, 47.12080764770508), 
                    objYaw = 44.99993896484375,
                },
                [2] = false, 
            },
        },
        purchaseMethods = {
            dollars = { cost = 250},
        },
        sell = { receive = 125 },
        tax = 25,
        ledgerLimit = 5000,
        defaultStorageWeight = 1000000, -- = 1000 Kg
        actionsRange = 15.0,
    },
    ['11'] = {
        Locations = {
            PrimaryEntrance = vector4(2238.014, -141.476, 47.603, 318.75), 
            SecondaryExit   = vector4(0,0,0, 0), 
            MenuActions     = vector3(2238.590, -144.447, 47.628), 
            ActionDistance  = 1.8, -- Don´t touch
        },
        hasTeleportationEntrance = false,
        doors = { 
            {
                [1] = { 
                    objCoords = vector3(2237.12353515625, -141.56480407714844, 46.6264419555664), 
                    objYaw = -50.00226974487305,
                },
                [2] = false, 
            },
            {
                [1] = { 
                    objCoords = vector3(2235.559814453125, -147.0606689453125, 46.62866973876953), 
                    objYaw = 129.9977264404297,
                },
                [2] = false, 
            },
        },
        purchaseMethods = {
            dollars = { cost = 250},
        },
        sell = { receive = 125 },
        tax = 25,
        ledgerLimit = 5000,
        defaultStorageWeight = 1000000, -- = 1000 Kg
        actionsRange = 10.0,
    },
    ['12'] = {
        Locations = {
            PrimaryEntrance = vector4(1792.581, -83.7813, 56.757, 267.1276245117), 
            SecondaryExit   = vector4(0,0,0, 0),
            MenuActions     = vector3(1782.195, -85.1265, 56.806), 
            ActionDistance  = 1.8, -- Don´t touch
        },
        hasTeleportationEntrance = false,
        doors = { 
            {
                [1] = { 
                    objCoords = vector3(1792.0633544921875, -83.22394561767578, 55.79853439331055), 
                    objYaw = -93.20934295654297,
                },
                [2] = false, 
            },
            {
                [1] = { 
                    objCoords = vector3(1785.488525390625, -93.06884765625, 55.8277359008789), 
                    objYaw = -3.47636604309082,
                },
                [2] = false, 
            },
            {
                [1] = { 
                    objCoords = vector3(1781.1064453125, -89.11561584472656, 55.81596374511719), 
                    objYaw = -93.00005340576172,
                },
                [2] = false, 
            },
            {
                [1] = { 
                    objCoords = vector3(1781.36181640625, -82.68769836425781, 55.79853820800781), 
                    objYaw = -93.00005340576172,
                },
                [2] = false, 
            },
        },
        purchaseMethods = {
            dollars = { cost = 500},
        },
        sell = { receive = 250 }, -- 500 / 2 = 250 = - 50% of default price.
        tax = 25,
        ledgerLimit = 5000,
        defaultStorageWeight = 1000000, -- = 1000 Kg
        actionsRange = 20.0,
    },
    ['13'] = {
        Locations = {
            PrimaryEntrance = vector4(1626.832, -366.809, 75.875, 189.87915039063), 
            SecondaryExit   = vector4(0,0,0, 0), 
            MenuActions     = vector3(1619.316, -362.713, 75.897), 
            ActionDistance  = 1.8, -- Don´t touch
        },
        hasTeleportationEntrance = false,
        doors = { 
            {
                [1] = { 
                    objCoords = vector3(1627.2501220703125, -366.256103515625, 74.90987396240234), 
                    objYaw = 179.99998474121094,
                },
                [2] = false, 
            },
        },
        purchaseMethods = {
            dollars = { cost = 350},
        },
        sell = { receive = 175 }, -- 350 / 2 = 175 = - 50% of default price.
        tax = 25,
        ledgerLimit = 5000,
        defaultStorageWeight = 1000000, -- = 1000 Kg
        actionsRange = 15.0,
    },
    ['14'] = {

        Locations = {
            PrimaryEntrance = vector4(1376.122, -872.619, 70.134, 291.44378662109), 
            SecondaryExit   = vector4(0,0,0, 0), 
            MenuActions     = vector3(1368.778, -870.906, 70.127), 
            ActionDistance  = 1.8, -- Don´t touch
        },
        hasTeleportationEntrance = false,
        doors = { 
            {
                [1] = { 
                    objCoords = vector3(1376.02392578125, -873.2420654296875, 69.11506652832031), 
                    objYaw = 104.99996185302734,
                },
                [2] = false, 
            },
            {
                [1] = { 
                    objCoords = vector3(1365.4197998046875, -872.8801879882812, 69.16214752197266), 
                    objYaw = -75.00003051757812,
                },
                [2] = false, 
            },
        },
        purchaseMethods = {
            dollars = { cost = 750},
        },
        sell = { receive = 375 }, -- 750 / 2 = 375 = - 50% of default price.
        tax = 25,
        ledgerLimit = 5000,
        defaultStorageWeight = 1000000, -- = 1000 Kg
        actionsRange = 15.0,
    },
    ['15'] = {
        Locations = {
            PrimaryEntrance = vector4(1114.282, -1305.71, 66.441, 197.2032623291), 
            SecondaryExit   = vector4(0,0,0, 0), 
            MenuActions     = vector3(1112.957, -1299.03, 66.405), 
            ActionDistance  = 1.8, -- Don´t touch
        },
        hasTeleportationEntrance = false,
        doors = { 
            {
                [1] = { 
                    objCoords = vector3(1114.6072998046875, -1305.0743408203125, 65.41828918457031), 
                    objYaw = -164.98619079589844,
                },
                [2] = false, 
            },
            {
                [1] = { 
                    objCoords = vector3(1111.4659423828125, -1297.5782470703125, 65.41828918457031), 
                    objYaw = 15.00000476837158,
                },
                [2] = false, 
            },
        },
        purchaseMethods = {
            dollars = { cost = 500},
        },
        sell = { receive = 250 }, -- 500 / 2 = 250 = - 50% of default price.
        tax = 25,
        ledgerLimit = 5000,
        defaultStorageWeight = 1000000, -- = 1000 Kg
        actionsRange = 15.0,
    },
    ['16'] = {
        Locations = {
            PrimaryEntrance = vector4(1323.161, -2279.58, 50.549, 314.59680175781), 
            SecondaryExit   = vector4(0,0,0, 0), 
            MenuActions     = vector3(1316.033, -2276.89, 50.518), 
            ActionDistance  = 1.8, -- Don´t touch
        },
        hasTeleportationEntrance = false,
        doors = { 
            {
                [1] = { 
                    objCoords = vector3(1322.4521484375, -2279.413818359375, 49.52224731445312), 
                    objYaw = -55.22403335571289,
                },
                [2] = false, 
            },
            {
                [1] = { 
                    objCoords = vector3(1316.47705078125, -2284.93896484375, 49.52444076538086), 
                    objYaw = 124.99995422363281,
                },
                [2] = false, 
            },
        },
        purchaseMethods = {
            dollars = { cost = 500},
        },
        sell = { receive = 250 }, -- 500 / 2 = 250 = - 50% of default price.
        tax = 25,
        ledgerLimit = 5000,
        defaultStorageWeight = 1000000, -- = 1000 Kg
        actionsRange = 15.0,
    },
    ['17'] = {
        Locations = {
            PrimaryEntrance = vector4(1890.716, -1857.69, 43.119, 54.802825927734), 
            SecondaryExit   = vector4(0,0,0, 0), 
            MenuActions     = vector3(1897.826, -1870.64, 43.131), 
            ActionDistance  = 1.8, -- Don´t touch
        },
        hasTeleportationEntrance = false,
        doors = { 
            {
                [1] = { 
                    objCoords = vector3(1892.202392578125, -1857.3302001953125, 42.1469841003418), 
                    objYaw = 49.99995803833008,
                },
                [2] = { 
                    objCoords = vector3(1890.6436767578125, -1859.18701171875, 42.14753723144531), 
                    objYaw = 49.9999580383300,
                },
            },
            {
                [1] = { 
                    objCoords = vector3(1903.3707275390625, -1857.267578125, 42.17497634887695), 
                    objYaw = 139.99986267089844,
                },
                [2] = false, 
            },
            {
                [1] = { 
                    objCoords = vector3(1903.274169921875, -1868.918212890625, 42.14916610717773), 
                    objYaw = 49.99995803833008,
                },
                [2] = false, 
            },
            {
                [1] = { 
                    objCoords = vector3(1892.9146728515625, -1870.743896484375, 42.15237808227539), 
                    objYaw = -39.99998474121094,
                },
                [2] = { 
                    objCoords = vector3(1893.958984375, -1871.619873046875, 42.15237808227539), 
                    objYaw = -39.99998474121094,
                },
            },
            {
                [1] = { 
                    objCoords = vector3(1889.6453857421875, -1867.8724365234375, 42.16537857055664), 
                    objYaw = -39.99998474121094,
                },
                [2] = { 
                    objCoords = vector3(1890.689697265625, -1868.7486572265625, 42.16537857055664), 
                    objYaw = -39.99998474121094,
                },
            },
        },
        purchaseMethods = {
            dollars = { cost = 1000},
        },
        sell = { receive = 500 }, -- 1000 / 2 = 500 = - 50% of default price.
        tax = 25,
        ledgerLimit = 5000,
        defaultStorageWeight = 1000000, -- = 1000 Kg
        actionsRange = 20.0,
    },
    ['18'] = {
        Locations = {
            PrimaryEntrance = vector4(2371.519, -864.765, 43.064, 198.36711120605), 
            SecondaryExit   = vector4(0,0,0, 0), 
           
            MenuActions     = vector3(2368.999, -864.116, 43.022), 
            ActionDistance  = 1.8, -- Don´t touch
        },
        hasTeleportationEntrance = false,
        doors = { 
            {
                [1] = { 
                    objCoords = vector3(2370.870361328125, -864.4375, 42.04009246826172), 
                    objYaw = 19.80922698974609,
                },
                [2] = false, 
            },
            {
                [1] = { 
                    objCoords = vector3(2370.92919921875, -857.4860229492188, 42.04308700561523), 
                    objYaw = -160.1158447265625,
                },
                [2] = false, 
            },
        },
        purchaseMethods = {
            dollars = { cost = 150},
        },
        sell = { receive = 75 }, 
        tax = 25,
        ledgerLimit = 5000,
        defaultStorageWeight = 1000000, -- = 1000 Kg
        actionsRange = 7.0,
    },
    ['19'] = {
        Locations = {
            PrimaryEntrance = vector4(2069.167, -856.503, 43.345, 181.81117248535), 
            SecondaryExit   = vector4(0,0,0, 0), 
            MenuActions     = vector3(2071.174, -855.104, 43.356), 
            ActionDistance  = 1.8, -- Don´t touch
        },
        hasTeleportationEntrance = false,
        doors = { 
            {
                [1] = { 
                    objCoords = vector3(2068.35888671875, -855.8857421875, 42.35087966918945), 
                    objYaw = 0,
                },
                [2] = { 
                    objCoords = vector3(2069.721923828125, -855.87939453125, 42.35087966918945), 
                    objYaw = -0.43209585547447,
                },
            },
            {
                [1] = { 
                    objCoords = vector3(2069.722900390625, -847.3150024414062, 42.35087966918945), 
                    objYaw = 179.99998474121094,
                },
                [2] = { 
                    objCoords = vector3(2068.35986328125, -847.3214111328125, 42.35087966918945), 
                    objYaw = 179.6019287109375,
                },
            },
            {
                [1] = { 
                    objCoords = vector3(2065.75146484375, -847.3150024414062, 42.35087966918945), 
                    objYaw = -179.93507385253906,
                },
                [2] = { 
                    objCoords = vector3(2064.388671875, -847.3214111328125, 42.35087966918945), 
                    objYaw = 179.99998474121094,
                },
            },
        },
        purchaseMethods = {
            dollars = { cost = 250},
        },
        sell = { receive = 125 },
        tax = 25,
        ledgerLimit = 5000,
        defaultStorageWeight = 1000000, -- = 1000 Kg
        actionsRange = 50.0,
    },
    ['20'] = {
        Locations = {
            PrimaryEntrance = vector4(1384.784, -2085.87, 52.600, 113.59962463379), 
            SecondaryExit   = vector4(0,0,0, 0), 
            MenuActions     = vector3(1392.500, -2084.44, 52.565), 
            ActionDistance  = 1.8, -- Don´t touch
        },
        hasTeleportationEntrance = false,
        doors = { 
            {
                [1] = { 
                    objCoords = vector3(1385.0645751953125, -2085.1806640625, 51.58381652832031), 
                    objYaw = -67.79705810546875,
                },
                [2] = false, 
            },
            {
                [1] = { 
                    objCoords = vector3(1387.3026123046875, -2077.44091796875, 51.58108520507812), 
                    objYaw = -159.75546264648438,
                },
                [2] = false, 
            },
        },
        purchaseMethods = {
            dollars = { cost = 100},
        },
        sell = { receive = 50 }, -- 100 / 2 = 50 = - 50% of default price.
        tax = 25,
        ledgerLimit = 5000,
        defaultStorageWeight = 1000000, -- = 1000 Kg
        actionsRange = 10.0,
    },
    ['21'] = {
        Locations = {
            PrimaryEntrance = vector4(347.3879, -666.815, 42.786, 245.91331481934), 
            SecondaryExit   = vector4(0,0,0, 0), 
            MenuActions     = vector3(340.2781, -667.204, 42.810), 
            ActionDistance  = 1.8, -- Don´t touch
        },
        hasTeleportationEntrance = false,
        doors = { 
            {
                [1] = { 
                    objCoords = vector3(347.24737548828125, -666.053466796875, 41.82276153564453), 
                    objYaw = -120.00007629394531,
                },
                [2] = false, 
            },
            {
                [1] = { 
                    objCoords = vector3(338.2540283203125, -669.947509765625, 41.82113647460937), 
                    objYaw = -29.9360179901123,
                },
                [2] = false, 
            },
        },
        purchaseMethods = {
            dollars = { cost = 350},
        },
        sell = { receive = 175 }, -- 350 / 2 = 175 = - 50% of default price.
        tax = 25,
        ledgerLimit = 5000,
        defaultStorageWeight = 1000000, -- = 1000 Kg
        actionsRange = 12.0,

    },
    ['22'] = {
        Locations = {
            PrimaryEntrance = vector4(-64.3675, -394.268, 72.241, 300.0), 
            SecondaryExit   = vector4(0,0,0, 0), 
            MenuActions     = vector3(-63.6798, -392.288, 72.215), 
            ActionDistance  = 1.8, -- Don´t touch
        },
        hasTeleportationEntrance = false,
        doors = { 
            {
                [1] = { 
                    objCoords = vector3(-64.24259948730469, -393.5611267089844, 71.24869537353516), 
                    objYaw = -60.00001907348633,
                },
                [2] = false, 
            },
        },
        purchaseMethods = {
            dollars = { cost = 350},
        },
        sell = { receive = 175 }, -- 350 / 2 = 175 = - 50% of default price.
        tax = 25,
        ledgerLimit = 5000,
        defaultStorageWeight = 1000000, -- = 1000 Kg
        actionsRange = 10.0,
    },
    ['23'] = {
        Locations = {
            PrimaryEntrance = vector4(-818.110, 350.5407, 98.111, 172.503417968), 
            SecondaryExit   = vector4(0,0,0, 0), 
            MenuActions     = vector3(-813.138, 355.7528, 98.082), 
            ActionDistance  = 1.8, -- Don´t touch
        },
        hasTeleportationEntrance = false,
        doors = { 
            {
                [1] = { 
                    objCoords = vector3(-818.61376953125, 351.16156005859375, 97.10883331298828), 
                    objYaw = -10.15568351745605,
                },
                [2] = false, 
            },
            {
                [1] = { 
                    objCoords = vector3(-819.1436157226562, 358.7345886230469, 97.10627746582031), 
                    objYaw = 169.7873992919922,
                },
                [2] = false, 
            },
        },
        purchaseMethods = {
            dollars = { cost = 350},
        },
        sell = { receive = 175 }, -- 350 / 2 = 175 = - 50% of default price.
        tax = 25,
        ledgerLimit = 5000,
        defaultStorageWeight = 1000000, -- = 1000 Kg
        actionsRange = 15.0,
    },
    ['24'] = {
        Locations = {
            PrimaryEntrance = vector4(899.7727, 265.5565, 116.03, 4.6019735336304), 
            SecondaryExit   = vector4(0,0,0, 0), 
            MenuActions     = vector3(902.2537, 263.6886, 115.99), 
            ActionDistance  = 1.8, -- Don´t touch
        },
        hasTeleportationEntrance = false,
        doors = { 
            {
                [1] = { 
                    objCoords = vector3(900.343505859375, 265.2184143066406, 115.04804992675781), 
                    objYaw = 179.99365234375,
                },
                [2] = false, 
            },
        },
        purchaseMethods = {
            dollars = { cost = 350},
        },
        sell = { receive = 175 }, -- 350 / 2 = 175 = - 50% of default price.
        tax = 25,
        ledgerLimit = 5000,
        defaultStorageWeight = 1000000, -- = 1000 Kg
        actionsRange = 15.0,
    },
    ['25'] = {
        Locations = {
            PrimaryEntrance = vector4(1117.264, 485.8627, 97.267, 230.1255035), 
            SecondaryExit   = vector4(0,0,0, 0), 
            MenuActions     = vector3(1120.418, 492.5742, 97.284), 
            ActionDistance  = 1.8, -- Don´t touch
        },
        hasTeleportationEntrance = false,
        doors = { 
            {
                [1] = { 
                    objCoords = vector3(1116.399169921875, 485.99212646484375, 96.3062973022461), 
                    objYaw = 40.00003433227539,
                },
                [2] = false, 
            },
            {
                [1] = { 
                    objCoords = vector3(1114.0626220703125, 493.746337890625, 96.29093933105469), 
                    objYaw = -49.99995803833008,
                },
                [2] = false, 
            },
        },
        purchaseMethods = {
            dollars = { cost = 750},
        },
        sell = { receive = 375 }, -- 750 / 2 = 375 = - 50% of default price.
        tax = 25,
        ledgerLimit = 5000,
        defaultStorageWeight = 1000000, -- = 1000 Kg
        actionsRange = 15.0,
    },
    ['26'] = {
        Locations = {
            PrimaryEntrance = vector4(1887.682, 297.5323, 76.850, 182.0860443), 
            SecondaryExit   = vector4(0,0,0, 0), 
           
            MenuActions     = vector3(1889.801, 304.8412, 77.055), 
            ActionDistance  = 1.8, -- Don´t touch
        },
        hasTeleportationEntrance = false,
        doors = { 
            {
                [1] = { 
                    objCoords = vector3(1888.1700439453125, 297.95916748046875, 76.07620239257812), 
                    objYaw = -179.9995880126953,
                },
                [2] = false, 
            },
            {
                [1] = { 
                    objCoords = vector3(1891.083251953125, 302.62200927734375, 76.0915756225586), 
                    objYaw = -89.99917602539062,
                },
                [2] = false, 
            },
        },
        purchaseMethods = {
            dollars = { cost = 350},
        },
        sell = { receive = 175 },
        tax = 25,
        ledgerLimit = 5000,
        defaultStorageWeight = 1000000, -- = 1000 Kg
        actionsRange = 15.0,
    },
    ['27'] = {
        Locations = {
            PrimaryEntrance = vector4(779.4117, 849.1409, 118.93, 283.232391357), 
            SecondaryExit   = vector4(0,0,0, 0), 
            MenuActions     = vector3(779.9094, 844.0106, 118.90), 
            ActionDistance  = 1.8, -- Don´t touch
        },
        hasTeleportationEntrance = false,
        doors = { 
            {
                [1] = { 
                    objCoords = vector3(778.968994140625, 849.5256958007812, 117.91557312011719), 
                    objYaw = -72.05952453613281,
                },
                [2] = false, 
            },
            {
                [1] = { 
                    objCoords = vector3(772.6528930664062, 841.267822265625, 117.91557312011719), 
                    objYaw = 17.72804832458496,
                },
                [2] = false, 
            },
        },
        purchaseMethods = {
            dollars = { cost = 750},
        },
        sell = { receive = 375 }, -- 750 / 2 = 375 = - 50% of default price.
        tax = 25,
        ledgerLimit = 5000,
        defaultStorageWeight = 1000000, -- = 1000 Kg
        actionsRange = 15.0,
    },
    ['28'] = {
        Locations = {
            PrimaryEntrance = vector4(223.4083, 990.6601, 190.92, 351.51095581), 
            SecondaryExit   = vector4(0,0,0, 0), 
            MenuActions     = vector3(225.1354, 987.8232, 190.88), 
            ActionDistance  = 1.8, -- Don´t touch
        },
        hasTeleportationEntrance = false,
        doors = { 
            {
                [1] = { 
                    objCoords = vector3(222.8267822265625, 990.534423828125, 189.90150451660156), 
                    objYaw = -10.21693801879882,
                },
                [2] = false, 
            },
            {
                [1] = { 
                    objCoords = vector3(215.800048828125, 988.0651245117188, 189.90150451660156), 
                    objYaw = -100.01841735839844,
                },
                [2] = false, 
            },
        },
        purchaseMethods = {
            dollars = { cost = 500},
        },
        sell = { receive = 250 }, -- 500 / 2 = 250 = - 50% of default price.
        tax = 25,
        ledgerLimit = 5000,
        defaultStorageWeight = 1000000, -- = 1000 Kg
        actionsRange = 12.0,
    },
    ['29'] = {
        Locations = {
            PrimaryEntrance = vector4(-67.4751, 1234.961, 170.80, 127.624343872), 
            SecondaryExit   = vector4(0,0,0, 0), 
            MenuActions     = vector3(-65.7959, 1238.299, 170.77), 
            ActionDistance  = 1.8, -- Don´t touch
        },
        hasTeleportationEntrance = false,
        doors = { 
            {
                [1] = { 
                    objCoords = vector3(-67.30323791503906, 1235.837646484375, 169.76470947265625), 
                    objYaw = -59.89761352539062,
                },
                [2] = false, 
            },
        },
        purchaseMethods = {
            dollars = { cost = 250},
        },
        sell = { receive = 125 },
        tax = 25,
        ledgerLimit = 5000,
        defaultStorageWeight = 1000000, -- = 1000 Kg
        actionsRange = 12.0,
    },
    ['30'] = {
        Locations = {
            PrimaryEntrance = vector4(-616.147, -27.8058, 86.014, 115.4423), 
            SecondaryExit   = vector4(0,0,0, 0), 
           
            MenuActions     = vector3(-615.878, -23.6280, 85.971), 
            ActionDistance  = 1.8, -- Don´t touch
        },
        hasTeleportationEntrance = false,
        doors = { 
            {
                [1] = { 
                    objCoords = vector3(-615.939208984375, -27.08654594421386, 84.99760437011719), 
                    objYaw = -70.273193359375,
                },
                [2] = false, 
            },
            {
                [1] = { 
                    objCoords = vector3(-608.7384643554688, -26.61294746398925, 84.99763488769531), 
                    objYaw = 109.99995422363281,
                },
                [2] = false, 
            },
        },
        purchaseMethods = {
            dollars = { cost = 500},
        },
        sell = { receive = 250 }, -- 500 / 2 = 250 = - 50% of default price.
        tax = 25,
        ledgerLimit = 5000,
        defaultStorageWeight = 1000000, -- = 1000 Kg
        actionsRange = 15.0,
    },
    ['31'] = {
        Locations = {
            PrimaryEntrance = vector4(-692.252, 1042.355, 135.03, 141.36312866), 
            SecondaryExit   = vector4(0,0,0, 0), 
            MenuActions     = vector3(-690.022, 1041.475, 135.00), 
            ActionDistance  = 1.8, -- Don´t touch
        },
        hasTeleportationEntrance = false,
        doors = { 
            {
                [1] = { 
                    objCoords = vector3(-692.4359130859375, 1042.918701171875, 134.0235595703125), 
                    objYaw = -54.47789001464844,
                },
                [2] = false, 
            },
        },
        purchaseMethods = {
            dollars = { cost = 250},
        },
        sell = { receive = 125 },
        tax = 25,
        ledgerLimit = 5000,
        defaultStorageWeight = 1000000, -- = 1000 Kg
        actionsRange = 10.0,
    },
    ['32'] = {
        Locations = {
            PrimaryEntrance = vector4(-1815.23, 654.1401, 131.79, 216.274505615), 
            SecondaryExit   = vector4(0,0,0, 0), 
            MenuActions     = vector3(-1818.33, 661.9285, 131.87), 
            ActionDistance  = 1.8, -- Don´t touch
        },
        hasTeleportationEntrance = false,
        doors = { 
            {
                [1] = { 
                    objCoords = vector3(-1815.14892578125, 654.9638061523438, 130.88250732421875), 
                    objYaw = -149.3169403076172,
                },
                [2] = false, 
            },
        },
        purchaseMethods = {
            dollars = { cost = 350},
        },
        sell = { receive = 175 }, -- 350 / 2 = 175 = - 50% of default price.
        tax = 25,
        ledgerLimit = 5000,
        defaultStorageWeight = 1000000, -- = 1000 Kg
        actionsRange = 15.0,
    },
    ['33'] = {
        Locations = {
            PrimaryEntrance = vector4(-2459.92, 836.6832, 142.37, 182.5136871), 
            SecondaryExit   = vector4(0,0,0, 0), 
            MenuActions     = vector3(-2461.02, 839.9203, 146.37), 
            ActionDistance  = 1.8, -- Don´t touch
        },
        hasTeleportationEntrance = false,
        doors = { 
            {
                [1] = { 
                    objCoords = vector3(-2460.434814453125, 839.1107177734375, 145.3572235107422), 
                    objYaw = 0.26353466510772,
                },
                [2] = false, 
            },
        },
        purchaseMethods = {
            dollars = { cost = 150},
        },
        sell = { receive = 75 }, 
        tax = 25,
        ledgerLimit = 5000,
        defaultStorageWeight = 1000000, -- = 1000 Kg
        actionsRange = 7.0,
    },
    ['34'] = {
        Locations = {
            PrimaryEntrance = vector4(-557.320, 2698.416, 320.25, 154.9732208252), 
            SecondaryExit   = vector4(0,0,0, 0), 
            MenuActions     = vector3(-554.636, 2698.816, 320.42), 
            ActionDistance  = 1.8, -- Don´t touch
        },
        hasTeleportationEntrance = false,
        doors = { 
            {
                [1] = { 
                    objCoords = vector3(-556.4169311523438, 2698.86376953125, 319.3801574707031), 
                    objYaw = 147.21568298339844,
                },
                [2] = false, 
            },
            {
                [1] = { 
                    objCoords = vector3(-557.9639892578125, 2708.988037109375, 319.43182373046875), 
                    objYaw = -122.65821075439453,
                },
                [2] = false, 
            },
        },
        purchaseMethods = {
            dollars = { cost = 350},
        },
        sell = { receive = 175 }, -- 350 / 2 = 175 = - 50% of default price.
        tax = 25,
        ledgerLimit = 5000,
        defaultStorageWeight = 1000000, -- = 1000 Kg
        actionsRange = 15.0,
    },
    ['35'] = {
        Locations = {
            PrimaryEntrance = vector4(-1976.16, -1664.80, 118.03, 324.55331420), 
            SecondaryExit   = vector4(0,0,0, 0), 
            MenuActions     = vector3(-1977.87, -1670.06, 118.17), 
            ActionDistance  = 1.8, -- Don´t touch
        },
        hasTeleportationEntrance = false,
        doors = { 
            {
                [1] = { 
                    objCoords = vector3(-1976.1314697265625, -1665.6568603515625, 117.19026947021484), 
                    objYaw = 145.1171417236328,
                },
                [2] = false, 
            },
        },
        purchaseMethods = {
            dollars = { cost = 350},
        },
        sell = { receive = 175 }, -- 350 / 2 = 175 = - 50% of default price.
        tax = 25,
        ledgerLimit = 5000,
        defaultStorageWeight = 1000000, -- = 1000 Kg
        actionsRange = 15.0,
    },
    ['36'] = {
        Locations = {
            PrimaryEntrance = vector4(-2373.29, -1592.63, 154.01, 239.1914978027), 
            SecondaryExit   = vector4(0,0,0, 0), 
           
            MenuActions     = vector3(-2374.80, -1589.28, 154.28), 
            ActionDistance  = 1.8, -- Don´t touch
        },
        hasTeleportationEntrance = false,
        doors = { 
            {
                [1] = { 
                    objCoords = vector3(-2374.364013671875, -1592.602294921875, 153.29959106445312), 
                    objYaw = 52.97750091552734,
                },
                [2] = false, 
            },
        },
        purchaseMethods = {
            dollars = { cost = 350},
        },
        sell = { receive = 175 }, -- 350 / 2 = 175 = - 50% of default price.
        tax = 25,
        ledgerLimit = 5000,
        defaultStorageWeight = 1000000, -- = 1000 Kg
        actionsRange = 15.0,
    },
    ['37'] = {
        Locations = {
            PrimaryEntrance = vector4(1011.0451, -1759.6350, 47.6051, 179.4546), 
            SecondaryExit   = vector4(0,0,0, 0), 
            MenuActions     = vector3(1021.4477, -1775.3131, 47.5808), 
            ActionDistance  = 1.8, -- Don´t touch
        },
        hasTeleportationEntrance = false,
        doors = { 
            {
                [1] = { 
                    objCoords = vector3(1012.2030029297,-1762.0412597656,46.599708557129),  
                    objYaw = 0.26353466510772,
                },
                [2] = { 
                    objCoords = vector3(1010.002685546875, -1762.0411376953125, 46.59970474243164),
                    objYaw = 0,
                },
            },
            {
                [1] = { 
                    objCoords = vector3(1007.03662109375, -1761.9989013671875, 46.62434387207031),  
                    objYaw = 179.99998474121094,
                },
                [2] = { 
                    objCoords = vector3(1005.6728515625, -1761.9990234375, 46.62434387207031),
                    objYaw = 179.99998474121094,
                },
            },
            {
                [1] = { 
                    objCoords = vector3(1002.5367431640625, -1761.9818115234375, 46.62434387207031),  
                    objYaw = 179.99998474121094,
                },
                [2] = { 
                    objCoords = vector3(1001.1729736328125, -1761.98193359375, 46.62434387207031),
                    objYaw = 179.99998474121094,
                },
            },
            {
                [1] = { 
                    objCoords = vector3(1000.0399169921875, -1764.3233642578125, 46.62434387207031),  
                    objYaw = -90.00007629394531,
                },
                [2] = { 
                    objCoords = vector3(1000.0399169921875, -1765.6871337890625, 46.62434387207031),
                    objYaw = -90.00000762939453,
                },
            },
            {
                [1] = { 
                    objCoords = vector3(1000.0394897460938, -1767.839111328125, 46.62312316894531),  
                    objYaw = -90.00007629394531,
                },
                [2] = { 
                    objCoords = vector3(1000.0394897460938, -1769.201904296875, 46.62312316894531),
                    objYaw = -90.00000762939453,
                },
            },
            {
                [1] = { 
                    objCoords = vector3(1000.03466796875, -1771.873779296875, 46.62672805786133),  
                    objYaw = -90.00007629394531,
                },
                [2] = { 
                    objCoords = vector3(1000.03466796875, -1773.2373046875, 46.62672805786133),
                    objYaw = -90.00007629394531,
                },
            },
            {
                [1] = { 
                    objCoords = vector3(1010.4942016601562, -1779.3802490234375, 46.60939407348633),  
                    objYaw = 0,
                },
                [2] = { 
                    objCoords = vector3(1011.8570556640625, -1779.3739013671875, 46.60939407348633),
                    objYaw = 0,
                },
            },
            {
                [1] = {
                    objCoords = vector3(1022.5319213867188, -1777.7064208984375, 46.6240119934082),  
                    objYaw = 89.99998474121094,
                },
                [2] = { 
                    objCoords = vector3(1022.5318603515625, -1776.3426513671875, 46.62406539916992),
                    objYaw = 89.99993133544922,
                },
            },
            {
                [1] = { 
                    objCoords = vector3(1022.5319213867188, -1774.5867919921875, 46.6240119934082),  
                    objYaw = 89.99998474121094,
                },
                [2] = { 
                    objCoords = vector3(1022.5318603515625, -1773.2230224609375, 46.62406539916992),
                    objYaw = 89.99993133544922,
                },
            },
            {
                [1] = { 
                    objCoords = vector3(1022.5319213867188, -1769.20263671875, 46.62361526489258),  
                    objYaw = 89.99993133544922,
                },
                [2] = { 
                    objCoords = vector3(1022.5319213867188, -1767.8389892578125, 46.62361526489258),
                    objYaw = 89.99998474121094,
                },
            },
            {
                [1] = { 
                    objCoords = vector3(1022.5345458984375, -1765.7020263671875, 46.6240119934082),  
                    objYaw = 89.99998474121094,
                },
                [2] = { 
                    objCoords = vector3(1022.5345458984375, -1764.3389892578125, 46.6240119934082),
                    objYaw = 89.99993133544922,
                },
            },
            {
                [1] = { 
                    objCoords = vector3(1021.140625, -1761.9793701171875, 46.6240119934082),  
                    objYaw = 179.99998474121094,
                },
                [2] = { 
                    objCoords = vector3(1019.777587890625, -1761.9793701171875, 46.6240119934082),
                    objYaw = 179.99998474121094,
                },
            },
            {
                [1] = { 
                    objCoords = vector3(1016.7928466796875, -1761.9793701171875, 46.6240119934082),  
                    objYaw = 179.99998474121094,
                },
                [2] = { 
                    objCoords = vector3(1015.4298095703125, -1761.9793701171875, 46.6240119934082),
                    objYaw = 179.99998474121094,
                },
            },

        },
        purchaseMethods = {
            dollars = { cost = 6500},
        },
        sell = { receive = 75 }, 
        tax = 55,
        ledgerLimit = 5000,
        defaultStorageWeight = 1000000, -- = 1000 Kg
        actionsRange = 7.0,
    },
    ['38'] = {
        Locations = {
            PrimaryEntrance = vector4(2401.4912, -1096.9491, 47.4204, 2.6667), 
            SecondaryExit   = vector4(0,0,0, 0), 
            MenuActions     = vector3(2393.6597, -1084.1970, 52.4369), 
            ActionDistance  = 1.8, -- Don´t touch
        },
        hasTeleportationEntrance = false,
        doors = { 
            {
                [1] = { 
                    objCoords = vector3(2400.3046875, -1095.501220703125, 46.42541885375976), 
                    objYaw = 0,
                },
                [2] = { 
                    objCoords = vector3(2402.5146484375,-1095.5643310546875,46.42541885375976), 
                    objYaw = 179.99998474121094,
                },
            },
            { 
                [1] = { 
                    objCoords = vector3(2387.85009765625, -1083.4393310546875, 46.43347930908203), 
                    objYaw = 89.9999771118164,
                },
                [2] = false,
            },
            {
                [1] = { 
                    objCoords = vector3(2387.718505859375, -1092.5770263671875, 46.4251480102539), 
                    objYaw = -90.00000762939453,
                },
                [2] = { 
                    objCoords = vector3(2387.71875, -1093.9228515625, 46.4251480102539), 
                    objYaw = -90.00000762939453,
                },
            },
            {
                [1] = { 
                    objCoords = vector3(2387.718505859375, -1090.2613525390625, 46.4251480102539), 
                    objYaw = -90.00000762939453,
                },
                [2] = { 
                    objCoords = vector3(2387.718505859375, -1091.6070556640625, 46.4251480102539), 
                    objYaw = -90.00000762939453,
                },
            },
            {
                [1] = { 
                    objCoords = vector3(2387.718505859375, -1087.9271240234375, 46.4251480102539), 
                    objYaw = -90.00000762939453,
                },
                [2] = { 
                    objCoords = vector3(2387.718505859375, -1089.27294921875, 46.4251480102539), 
                    objYaw = -90.00000762939453,
                },
            },
            {
                [1] = { 
                    objCoords = vector3(2387.718505859375, -1085.609375, 46.4251480102539), 
                    objYaw = -90.27192687988281,
                },
                [2] = { 
                    objCoords = vector3(2387.71875, -1086.954345703125, 46.4251480102539), 
                    objYaw = -89.81372833251953,
                },
            },
            {
                [1] = { 
                    objCoords = vector3(2397.47021484375, -1071.15966796875, 46.4251480102539), 
                    objYaw = 179.99998474121094,
                },
                [2] = { 
                    objCoords = vector3(2396.125, -1071.1595458984375, 46.4251480102539), 
                    objYaw = 179.99998474121094,
                },
            },
            {
                [1] = { 
                    objCoords = vector3(2399.788330078125, -1071.1597900390625, 46.4251480102539), 
                    objYaw = 179.99998474121094,
                },
                [2] = { 
                    objCoords = vector3(2398.443115234375, -1071.1597900390625, 46.4251480102539), 
                    objYaw = 179.99998474121094,
                },
            },
            {
                [1] = { 
                    objCoords = vector3(2402.106689453125, -1071.1597900390625, 46.4251480102539), 
                    objYaw = 179.99998474121094,
                },
                [2] = { 
                    objCoords = vector3(2400.760498046875, -1071.1595458984375, 46.4251480102539), 
                    objYaw = 179.99998474121094,
                },
            },
            {
                [1] = { 
                    objCoords = vector3(2404.42529296875, -1071.15966796875, 46.4251480102539), 
                    objYaw = 179.99998474121094,
                },
                [2] = { 
                    objCoords = vector3(2403.080078125, -1071.15966796875, 46.4251480102539), 
                    objYaw = 179.99998474121094,
                },
            },
            {
                [1] = { 
                    objCoords = vector3(2406.74365234375, -1071.15966796875, 46.4251480102539), 
                    objYaw = 179.99998474121094,
                },
                [2] = { 
                    objCoords = vector3(2405.398681640625, -1071.1597900390625, 46.4251480102539), 
                    objYaw = 179.99998474121094,
                },
            },
            { 
                [1] = { 
                    objCoords = vector3(2415.254638671875, -1094.43359375, 46.4251480102539), 
                    objYaw = 90.337890625,
                },
                [2] = { 
                    objCoords = vector3(2415.2548828125, -1093.0709228515625, 46.4251480102539), 
                    objYaw = 90.30559539794922,
                },
            },
            { 
                [1] = { 
                    objCoords = vector3(2415.254638671875, -1091.9517822265625, 46.4251480102539), 
                    objYaw = 89.9999771118164,
                },
                [2] = { 
                    objCoords = vector3(2415.254638671875, -1090.5892333984375, 46.4251480102539), 
                    objYaw = 89.9999771118164,
                },
            },
            { 
                [1] = { 
                    objCoords = vector3(2415.254638671875, -1089.4661865234375, 46.4251480102539), 
                    objYaw = 89.9999771118164,
                },
                [2] = { 
                    objCoords = vector3(2415.25439453125, -1088.1031494140625, 46.4251480102539), 
                    objYaw = 89.9999771118164,
                },
            },
            { 
                [1] = { 
                    objCoords = vector3(2415.254638671875, -1086.97998046875, 46.4251480102539), 
                    objYaw = 89.8932876586914,
                },
                [2] = { 
                    objCoords = vector3(2415.254638671875, -1085.6182861328125, 46.4251594543457), 
                    objYaw = 90.16177368164062,
                },
            },
            { 
                [1] = { 
                    objCoords = vector3(2415.544921875, -1084.0823974609375, 46.4251480102539), 
                    objYaw = -0.19511154294013,
                },
                [2] = { 
                    objCoords = vector3(2416.889892578125, -1084.08251953125, 46.4251480102539), 
                    objYaw = 0.11808874458074,
                },
            },
        },
        purchaseMethods = {
            dollars = { cost = 7000},
        },
        sell = { receive = 175 },
        tax = 25,
        ledgerLimit = 5000,
        defaultStorageWeight = 1000000, -- = 1000 Kg
        actionsRange = 15.0,
    },
    ['39'] = {
        Locations = {
            PrimaryEntrance = vector4(1932.972, 1949.702, 266.07, 23.494300842285), 
            SecondaryExit   = vector4(0,0,0, 0),
            MenuActions     = vector3(1935.05, 1948.20, 266.10),
            ActionDistance  = 1.8, -- Don´t touch
        },
        hasTeleportationEntrance = false,
        doors = { 

            {
                [1] = { 
                    objCoords = vector3(1933.5963134765625, 1949.029541015625, 265.1185302734375), 
                    objYaw = -174.99990844726562,
                },
    
                [2] = false, 
            },
        },
        purchaseMethods = {
            dollars = { cost = 250},
        },
        sell = { receive = 125 },
        tax = 25,
        ledgerLimit = 5000,
        defaultStorageWeight = 1000000, -- = 1000 Kg
        actionsRange = 20.0,
    },
    
}

--[[-------------------------------------------------------
 Webhooks
]]---------------------------------------------------------

Config.Webhooking = {

    ['BOUGHT'] = { 
        Enabled = false, 
        Url = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", 
        Color = 10038562,
    },

    ['SOLD'] = { 
        Enabled = false, 
        Url = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", 
        Color = 10038562,
    },

    ['TRANSFERRED'] = { 
        Enabled = false, 
        Url = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", 
        Color = 10038562,
    },

}
