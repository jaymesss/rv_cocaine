local QBCore = exports[Config.CoreName]:GetCoreObject()
local MissionTimer = 0

QBCore.Functions.CreateCallback('rv_cocaine:server:CanAffordDeposit', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if MissionTimer > os.time() then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.no_missions, 'error')
        cb(false)
        return
    end
    if Player.Functions.GetMoney('cash') > Config.Plane.Deposit then
        Player.Functions.RemoveMoney('cash', Config.Plane.Deposit)
        cb(true)
        MissionTimer = os.time() + Config.MissionCooldown
        return
    end
    TriggerClientEvent('QBCore:Notify', src, Locale.Error.cannot_afford, 'error')
    cb(false)
end)

QBCore.Functions.CreateCallback('rv_cocaine:server:GetCocaineBricks', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Player.Functions.GetItemByName(Config.PureBrickItem)
    if item == nil then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.need_cocaine_bricks, 'error')
        cb(0)
        return
    end
    cb(item.amount)
end)

QBCore.Functions.CreateCallback('rv_cocaine:server:GetPureCocaine', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Player.Functions.GetItemByName(Config.PureCocaineItem)
    if item == nil then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.need_pure_cocaine, 'error')
        cb(0)
        return
    end
    cb(item.amount)
end)

QBCore.Functions.CreateCallback('rv_cocaine:server:GetProcessedCocaine', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Player.Functions.GetItemByName(Config.ProcessedCocaineItem)
    if item == nil then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.need_processed_cocaine, 'error')
        cb(0)
        return
    end
    cb(item.amount)
end)

RegisterNetEvent('rv_cocaine:server:MissionComplete', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddItem(Config.Plane.Reward.ItemName, math.random(Config.Plane.Reward.AmountMin, Config.Plane.Reward.AmountMax))
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.Plane.Reward.ItemName], 'add')
end)

RegisterNetEvent('rv_cocaine:server:BreakDownBricks', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Player.Functions.GetItemByName(Config.PureBrickItem)
    if item == nil or item.amount < amount then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.need_cocaine_bricks, 'error')
        return
    end
    Player.Functions.RemoveItem(Config.PureBrickItem, amount)
    Player.Functions.AddItem(Config.PureCocaineItem, amount * Config.PureCocainePerBrick)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.PureCocaineItem], 'add')
end)

RegisterNetEvent('rv_cocaine:server:PurifyCocaine', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Player.Functions.GetItemByName(Config.PureCocaineItem)
    if item == nil or item.amount < amount then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.need_pure_cocaine, 'error')
        return
    end
    Player.Functions.RemoveItem(Config.PureCocaineItem, amount)
    Player.Functions.AddItem(Config.ProcessedCocaineItem, amount)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.ProcessedCocaineItem], 'add')
end)

RegisterNetEvent('rv_cocaine:server:PackageCocaine', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Player.Functions.GetItemByName(Config.ProcessedCocaineItem)
    if item == nil or item.amount < amount then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.need_processed_cocaine, 'error')
        return
    end
    Player.Functions.RemoveItem(Config.ProcessedCocaineItem, amount)
    local given = math.floor(amount / Config.ProcessedCocainePerBaggy)
    Player.Functions.AddItem(Config.CocaineBaggyItem, given)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.CocaineBaggyItem], 'add')
end)
