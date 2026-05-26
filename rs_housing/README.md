-- For the wardrobe to work, add this at the very end of rsg-appearance/client/clothes.lua

    RegisterNetEvent('rsg-appearance:client:openWardrobe')
    AddEventHandler('rsg-appearance:client:openWardrobe', function()
        Outfits()
    end)

-- Job for realestate rsg-core\shared\jobs.lua

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
