ESX = nil
local _wheel = nil
local _lambo = nil
local _isShowCar = false
local _wheelPos = vector3(976.54, 50.02, 74.68)
local Keys = {
	["ESC"] = 322, ["BACKSPACE"] = 177, ["E"] = 38, ["ENTER"] = 18,	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173
}
local _isRolling = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	while not ESX.IsPlayerLoaded() do 
        Citizen.Wait(500)
    end

    if ESX.IsPlayerLoaded() then
        local model = GetHashKey('vw_prop_vw_luckywheel_02a')
        local carmodel = GetHashKey('bc')

        Citizen.CreateThread(function()
            RequestModel(model)

            while not HasModelLoaded(model) do
                Citizen.Wait(0)
            end

            _wheel = CreateObject(model, 977.99, 50.33, 73.95, false, false, true)
            SetEntityHeading(_wheel, 328.47)
            SetModelAsNoLongerNeeded(model)
            
            -- Car
            RequestModel(carmodel)
            while not HasModelLoaded(carmodel) do
                Citizen.Wait(0)
            end

            local vehicle = CreateVehicle(carmodel, 963.1, 47.95, 75.1, 0.0, false, false)
            
            SetModelAsNoLongerNeeded(carmodel)
            

            -- RequestCollisionAtCoord(963.1, 47.95, 75.1)

            -- while not HasCollisionLoadedAroundEntity(vehicle) do
            --     RequestCollisionAtCoord(963.1, 47.95, 75.1)
            --     Citizen.Wait(0)
            -- end

            -- SetVehRadioStation(vehicle, 'OFF')
            FreezeEntityPosition(vehicle, true)
            local _curPos = GetEntityCoords(vehicle)
            SetEntityCoords(vehicle, _curPos.x, _curPos.y, _curPos.z + 1, false, false, true, true)
            _lambo = vehicle
            
        end)
    end
end)

Citizen.CreateThread(function() 
    while true do
        if _lambo ~= nil then
            local _heading = GetEntityHeading(_lambo)
            local _z = _heading - 0.3
            SetEntityHeading(_lambo, _z)
        end
        Citizen.Wait(5)
    end
end)

RegisterNetEvent("esx_tpnrp_luckywheel:doRoll")
AddEventHandler("esx_tpnrp_luckywheel:doRoll", function(_priceIndex) 
    _isRolling = true
	SetEntityHeading(_wheel, -30.9754)
    Citizen.CreateThread(function()
        local speedIntCnt = 1
        local rollspeed = 1.0
        local _winAngle = (_priceIndex - 1) * 18
        local _rollAngle = _winAngle + (360 * 8)
        local _midLength = (_rollAngle / 2)
        local intCnt = 0
        while speedIntCnt > 0 do
            local retval = GetEntityRotation(_wheel, 1)
            if _rollAngle > _midLength then
                speedIntCnt = speedIntCnt + 1
            else
                speedIntCnt = speedIntCnt - 1
                if speedIntCnt < 0 then
                    speedIntCnt = 0
                    
                end
            end
            intCnt = intCnt + 1
            rollspeed = speedIntCnt / 10
            local _y = retval.y - rollspeed
            _rollAngle = _rollAngle - rollspeed
			SetEntityHeading(_wheel, -30.9754)
            SetEntityRotation(_wheel, 0.0, _y, -30.9754, 2, true)
            Citizen.Wait(5)
        end
    end)
end)

RegisterNetEvent("esx_tpnrp_luckywheel:rollFinished")
AddEventHandler("esx_tpnrp_luckywheel:rollFinished", function() 
    _isRolling = false
end)


function doRoll()
    if not _isRolling then
        _isRolling = true
        local playerPed = PlayerPedId()
        local _lib = 'anim_casino_a@amb@casino@games@lucky7wheel@female'
        if IsPedMale(playerPed) then
            _lib = 'anim_casino_a@amb@casino@games@lucky7wheel@male'
        end
        local lib, anim = _lib, 'enter_right_to_baseidle'
        ESX.Streaming.RequestAnimDict(lib, function()
            local _movePos = vector3(976.54, 50.36, 74.68)
            TaskGoStraightToCoord(playerPed,  _movePos.x,  _movePos.y,  _movePos.z,  1.0,  -1,  312.2,  0.0)
            local _isMoved = false
            while not _isMoved do
                local coords = GetEntityCoords(PlayerPedId())
                if coords.x >= (_movePos.x - 0.01) and coords.x <= (_movePos.x + 0.01) and coords.y >= (_movePos.y - 0.01) and coords.y <= (_movePos.y + 0.01) then
                    _isMoved = true
                end
                Citizen.Wait(0)
            end
            TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
            while IsEntityPlayingAnim(playerPed, lib, anim, 3) do
                    Citizen.Wait(0)
                    DisableAllControlActions(0)
            end
            TaskPlayAnim(playerPed, lib, 'enter_to_armraisedidle', 8.0, -8.0, -1, 0, 0, false, false, false)
            while IsEntityPlayingAnim(playerPed, lib, 'enter_to_armraisedidle', 3) do
                Citizen.Wait(0)
                DisableAllControlActions(0)
            end
            TriggerServerEvent("esx_tpnrp_luckywheel:getLucky")
            TaskPlayAnim(playerPed, lib, 'armraisedidle_to_spinningidle_high', 8.0, -8.0, -1, 0, 0, false, false, false)
        end)
    end
end

-- Menu Controls
Citizen.CreateThread(function()
	while true do
        Citizen.Wait(1)
        local coords = GetEntityCoords(PlayerPedId())

        if(GetDistanceBetweenCoords(coords, _wheelPos.x, _wheelPos.y, _wheelPos.z, true) < 1.5) and not _isRolling then
            ESX.ShowHelpNotification("Press E to test your luck with the $ 100,000 Grand Prize")
            if IsControlJustReleased(0, Keys['E']) then
                doRoll()
            end
        end		
	end
end)