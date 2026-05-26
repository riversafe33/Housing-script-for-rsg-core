# Buy me a beer :beer:  :heart: 

https://ko-fi.com/riversafe33

https://www.paypal.com/donate/?hosted_button_id=NX4ENSGYS6YJN

# Complete property script for rsg-core

1 - Ability to charge taxes to players, monthly or weekly. When enabled in the config, a “Tax Ledger” option will appear in the menu where players can deposit money so their house is not taken away for not paying taxes. To prevent players from depositing large amounts of money and avoiding tax issues for long periods of inactivity, the Tax Ledger will only allow the exact required amount to be deposited each time.

2 - Normal ledger with a configurable option to set the maximum amount of money each player can store in their house inventory.

3 - Ability to give house keys to another player and decide what permissions each person with a key has individually.

4 - Ability for players to buy houses, or for a person with a specific job to act as the seller role. When the sale is confirmed, the script gives that seller a percentage of the house price.

5 - Ability to modify the amount a house gives when it is sold directly from the menu.

# 🎥 Showcase: https://streamable.com/j4rpws

# Config.furnitureitems = true  🎥 Showcase: https://streamable.com/o1zevh

# Config.furnitureitems = false  🎥 Showcase: https://streamable.com/zneosi
    
# 🚪 **Big Update for rs_housing** 🏠✨

1️⃣ The old open/close door text has been removed and replaced with a prompt system to simplify everything.
No more annoying coordinate adjustments — much cleaner and easier to use 👍

2️⃣ A new **House Furniture Menu** has been added!
Players can now place furniture inside the house radius, which can be customized in `config.lua` 🪑🛋️

3️⃣ Furniture can now be used as **items**, and the menu can be disabled if you want to create a carpenter/cabinetmaker job on your server 🔨📦

4️⃣ Added the option to **give or remove permissions** so your tenant can place furniture as well 🔑

5️⃣ The notification format has been improved because the old one became unreadable with long text messages 📢✨

6️⃣ A shop has been created which is enabled when Config.furnitureitems = true. In this shop, furniture objects 
are rendered so players can preview them before purchasing. Items can only be used within the actionsRange of each house, 
and only if the player is the owner of the house or has a house key and has been granted permission by the owner to place furniture 🔨📦

# ⚠️ **Important:**
# You must replace the entire script, including the SQL file.

# For the wardrobe to work, add this at the very end of rsg-appearance/client/clothes.lua

    RegisterNetEvent('rsg-appearance:client:openWardrobe')
    AddEventHandler('rsg-appearance:client:openWardrobe', function()
        Outfits()
    end)

# Job for realestate rsg-core\shared\jobs.lua

    realestate = {
        name = 'realestate',
        label = 'Realestate',
        type = 'realestate',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Employee', payment = 5 },
            ['1'] = { name = 'Worker', payment = 7 },
            ['2'] = { name = 'Supervisor', payment = 9 },
            ['3'] = { name = 'Boss', isboss = true, payment = 11 },
        },
    },
