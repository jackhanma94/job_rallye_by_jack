---menu f6
lib.registerContext({
    id = 'menu_drift',
    title = 'MENU RALLYE',
    options = {
      {
        title = '📤menu annonce',
        description = 'acceder au annonce',
        menu = 'annonce',
        icon = 'bars'
      },
      {
        title = '💸menu facture',
        description = 'mettre une facture',
        event = 'sendbill',
        icon = 'bars'
      }
    }
})

lib.registerContext({
  id = 'annonce',
  title = 'menu annonce',
  menu = 'menu_drift',
  onBack = function()
    print('Went back!')
  end,
  options = {
    {
      title = '🌔annonce ouverture',
      description = 'appuyer pour ouvrir',
      event = 'drift:ouvert',
      icon = 'bars'
    },
    {
      title = '🌚annonce fermeture',
      description = 'appuyer pour fermer',
      event = 'drift:fermer',
      icon = 'bars'
    },
    {
      title = '📑annonce personalise',
      description = 'appuyer pour faire une annonce',
      event = 'drift:perso',
      icon = 'bars'
    }
  }
})

--- annonce
RegisterNetEvent('drift:perso')
AddEventHandler('drift:perso', function(message)
    local input = lib.inputDialog(('message personalise'), {'Message'})
 
    if not input then return end

    local message = input[1]

    TriggerServerEvent('drift:Perso', message)
end)
RegisterNetEvent('drift:ouvert')
AddEventHandler('drift:ouvert', function()
    TriggerServerEvent('drift:Ouvert')
end)

RegisterNetEvent('drift:fermer')
AddEventHandler('drift:fermer', function()
    TriggerServerEvent('drift:Fermer')
end)

-- Facture
RegisterNetEvent('sendbill')
AddEventHandler('sendbill', function()
  local input = lib.inputDialog('FACTURE RALLYE', {
    {type = "number", label = "Montant de la facture", min = 1, max = 100000}
  })
           if input then
                local amount = tonumber(input[1])
			
				if amount == nil or amount < 0 then
					ESX.ShowNotification('Montant Invalide')
				else
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
				if closestPlayer == -1 or closestDistance > 4.0 then
					ESX.ShowNotification('Personne proche!')
				else
          TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_VEHICLE_MECHANIC', 0, true)
				TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_lscustom', 'Facture Mecano', amount)
        
			end
		end
    end
end)

RegisterCommand("drift", function()
    if ESX.PlayerData.job and ESX.PlayerData.job.name == Config.JobUtiliser and not ESX.PlayerData.dead then
        lib.showContext("menu_drift")
    end
end)

RegisterKeyMapping("drift", "menu_drift", "keyboard", "F6")



---mecanopoint

lib.registerContext({
    id = 'action',
    title = 'INTERACTION VEHICULE',
    onExit = function() CreateThread(PositionMecanoCheck) end,
    options = {
      {
        title = '🔨reparer vehicule',
        description = 'appuyer pour reparer',
        event = 'reparer',
        icon = 'bars',
        image = 'https://th.bing.com/th/id/R.6fedeebc437085adc5ac3f16a4ec1fdf?rik=T%2fXVy6SSNis4fQ&riu=http%3a%2f%2fwww.amicalecg.fr%2fwp-content%2fuploads%2f2019%2f05%2freparation.jpg&ehk=EmRivuFgHTYKBIeyd11FTOkEVCuHuvprGpjXt0Bz1wc%3d&risl=&pid=ImgRaw&r=0'
      },
      {
        title = '👋nettoyer vehicule',
        description = 'appuyer pour nettoyer',
        event = 'nettoyage',
        icon = 'bars',
        image ='https://th.bing.com/th/id/R.ba29e9cd998fbf2954154301d6326cd8?rik=Y1nrLV1r4os8Ng&pid=ImgRaw&r=0'
      }
    }
})

function PositionMecanoCheck()
    local ms   
    while (function()
        ms = 1000
        ESX.PlayerData = ESX.GetPlayerData()
        if #(GetEntityCoords(PlayerPedId()) - Config.pose.mecano) <= 2 and ESX.PlayerData.job.name == Config.JobUtiliser and ESX.PlayerData.job.grade_name == Config.gradejobmecano then  
            lib.showTextUI('[E] - mecano menu', {
              position = "left-center",
              style = {
                  borderRadius = 0,
                  backgroundColor = '#3fd2d5',
                  color = 'white',
              }
            })
            ms = 0 
            if IsControlJustPressed(1,51) then
              lib.showContext('action')
              lib.hideTextUI()
              return false 
            end
          else
  
        end
    
        if #(GetEntityCoords(PlayerPedId()) - Config.pose.mecano) > 2 then
           lib.hideTextUI()
        end
  
        return true 
      end)() do 
        Wait(ms)
      end
  end
  


RegisterNetEvent('nettoyage')
AddEventHandler('nettoyage', function()
    local vehicle   = ESX.Game.GetVehicleInDirection()
    local playerPed = PlayerPedId()
    local hasitem   = exports.ox_inventory:Search('count', Config.item.repa)
    if hasitem > 0 then
        if DoesEntityExist(vehicle) then
            TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_MAID_CLEAN', 0, true)
            CreateThread(PositionMecanoCheck)
            isBusy = true
            if lib.progressBar({
                    duration = 30000,
                    label = 'Nettoyage en cours',
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        car = true,
                    },
                }) then
                print('Do stuff when complete')
            else
                print('Do stuff when cancelled')
            end
            Citizen.CreateThread(function()
                Citizen.Wait(20000)
                SetVehicleDirtLevel(vehicle, 0.0)
                ClearPedTasksImmediately(playerPed)
                ESX.ShowNotification('Le véhicule est néttoyer')
                lib.showContext('action')
                isBusy = false
            end)
        else
            ESX.ShowNotification('Vous n\'avez l\'item chiffon')
            lib.showContext('action')
        end
    else
        ESX.ShowNotification('Aucun véhicule à proximiter')
        lib.showContext('action')
    end
end)






RegisterNetEvent('reparer')
RegisterNetEvent('reparer', function()
    local vehicle   = ESX.Game.GetVehicleInDirection()
	  local playerPed = PlayerPedId()
    local hasitem   = exports.ox_inventory:Search('count', Config.item.nettoyage)
    if hasitem > 0 then
        if DoesEntityExist(vehicle) then
		    isBusy = true
        SetEntityHeading(PlayerPedId(), GetEntityHeading(PlayerPedId() >> 1))
		    TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_VEHICLE_MECHANIC', 0, true)
		      if lib.progressBar({
            duration = 30000,
            label = 'reparation en cours',
            useWhileDead = false,
            canCancel = true,
            disable = {
              car = true,
            },
          }) then print('Do stuff when complete') else print('Do stuff when cancelled') end
		    Citizen.CreateThread(function()
			    Citizen.Wait(20000)
			    SetVehicleFixed(vehicle)
			    SetVehicleDeformationFixed(vehicle)
			    SetVehicleUndriveable(vehicle, false)
			    SetVehicleEngineOn(vehicle, true, true)
			    ClearPedTasksImmediately(playerPed)

			    ESX.ShowNotification('Le véhicule est réparé')
			    isBusy = false
		    end)
	    else
		      ESX.ShowNotification('Aucun véhicule à proximiter')
	    end
    else
  end
end)    

function InitPositionBossMenu()
    CreateThread(PositionMecanoCheck)
    CreateThread(PositionGarageCheck)
    CreateThread(PositionBossCheck)
    CreateThread(PositionCoffreCheck)
    CreateThread(PositionVestiereCheck)
    CreateThread(PositionBarCheck)
  end
  
  
  AddEventHandler("onClientResourceStart", function()
      InitPositionBossMenu()
end)

---BLIPS
local blips = {
    { title = Config.blips.title, colour = Config.blips.color, id = Config.blips.id, x = Config.blips.x, y = Config.blips.y, z = Config.blips.z }
  }
  
Citizen.CreateThread(function()
    for _, info in pairs(blips) do
        info.blip = AddBlipForCoord(info.x, info.y, info.z)
        SetBlipSprite(info.blip, info.id)
        SetBlipDisplay(info.blip, 4)
        SetBlipScale(info.blip, 0.6)
        SetBlipColour(info.blip, info.colour)
        SetBlipAsShortRange(info.blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(info.title)
        EndTextCommandSetBlipName(info.blip)
    end
end)


---garage

---------sortie

local function OpenMenu()
    local menu = {}
    for k, v in pairs(Vehicle) do 
        menu[#menu+1] = {
            title = v.label,
            description = "sortir le :"..v.label.."",
            onSelect = function() TriggerServerEvent("testserverside", v)  end,
            image = v.image,
        }
    end
    lib.registerContext({
        id = "garage",
        title = "garage",
        onExit = function() CreateThread(PositionGarageCheck) end,
        options = menu
    })
    lib.showContext('garage')
end


RegisterNetEvent("clientside", function(data)
  local h = GetHashKey(data.name)
  RequestModel(h)
  while not HasModelLoaded(h) do Wait(0) end 
  local car = CreateVehicle(h, Config.pose.spawn, true, false)
  SetPedIntoVehicle(PlayerPedId(), car, -1)
  checkrange(car, data)
end)
  
function PositionGarageCheck()
    local ms   
    while (function()
        ms = 1000
        ESX.PlayerData = ESX.GetPlayerData()
        if #(GetEntityCoords(PlayerPedId()) - Config.pose.garage) <= 2 and ESX.PlayerData.job.name == Config.JobUtiliser then 
            lib.showTextUI('[E] - garage menu', {
              position = "left-center",
              style = {
                  borderRadius = 0,
                  backgroundColor = '#3fd2d5',
                  color = 'white',
              }
            })
            ms = 0 
            if IsControlJustPressed(1,51) then
              OpenMenu()
              lib.hideTextUI()
              return false 
            end
          else
  
        end
    
        if #(GetEntityCoords(PlayerPedId()) - Config.pose.garage) > 2 then
           lib.hideTextUI()
        end
  
        return true 
      end)() do 
        Wait(ms)
      end
end 
  
---boss menu
lib.registerContext({
  id = 'boss_menu',
  title = 'BOSS MENU',
  onExit = function() CreateThread(PositionBossCheck) end,
  options = {
    {
      title = '🤝action menu',
      icon = 'bars',
      menu = 'personel_menu',
      onSelect = function() mecanoRetraitEntreprise() end
    },
    {
      title = '🏧gestion argent',
      icon = 'bars',
      menu = 'gestion_argent',
      onSelect = function() mecanoRetraitEntreprise() end
    },
    {
      title = '🏧donner license FIA',
      icon = 'bars',
      onSelect = function()
        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
        if closestPlayer ~= -1 and closestDistance <= 3.0 then
            TriggerServerEvent('esx_license:addLicense', GetPlayerServerId(closestPlayer), 'fia')
            ESX.ShowNotification('~g~Vous avez attribué le code de la route avec succès.')
            lib.showContext('boss_menu')
        else
            ESX.ShowNotification("~r~Probleme~s~: Aucuns joueurs proche")
            lib.showContext('boss_menu')
        end
      end,
    }
}
})

lib.registerContext({
  id = 'personel_menu',
  title = 'action menu',
  menu = 'boss_menu',
  onBack = function()
    print('Went back!')
  end,
  onExit = function() CreateThread(PositionBossCheck) end,
  options = {
    {
      title = 'recruter',
      icon = 'bars',
      onSelect = function() 
        local Tikozaal = {}           
        Tikozaal.closestPlayer, Tikozaal.closestDistance = ESX.Game.GetClosestPlayer()
        if Tikozaal.closestPlayer == -1 or Tikozaal.closestDistance > 3.0 then
             ESX.ShowNotification('Aucun joueur à ~b~proximité')
             lib.showContext('boss_menu')
        else
            TriggerServerEvent('Tikoz:Recruter', GetPlayerServerId(Tikozaal.closestPlayer), ESX.PlayerData.job.name, 0)
            lib.showContext('boss_menu')
        end 
      end
    },
    {
      title = 'premouvoir',
      icon = 'bars',
      onSelect = function() 
        local Tikozaal = {}   
        Tikozaal.closestPlayer, Tikozaal.closestDistance = ESX.Game.GetClosestPlayer()
        if Tikozaal.closestPlayer == -1 or Tikozaal.closestDistance > 3.0 then
             ESX.ShowNotification('Aucun joueur à ~b~proximité')
             lib.showContext('boss_menu')
        else
            TriggerServerEvent('Tikoz:Promotion', GetPlayerServerId(Tikozaal.closestPlayer), ESX.PlayerData.job.name, 0)
            lib.showContext('boss_menu')
        end 
      end
    },
    {
      title = 'retrograder',
      icon = 'bars',
      onSelect = function() 
        local Tikozaal = {}   
        Tikozaal.closestPlayer, Tikozaal.closestDistance = ESX.Game.GetClosestPlayer()
        if Tikozaal.closestPlayer == -1 or Tikozaal.closestDistance > 3.0 then
             ESX.ShowNotification('Aucun joueur à ~b~proximité')
             lib.showContext('boss_menu')
        else
            TriggerServerEvent('Tikoz:Retrograder', GetPlayerServerId(Tikozaal.closestPlayer), ESX.PlayerData.job.name, 0)
            lib.showContext('boss_menu')
        end 
      end
    },
    {
      title = 'virer',
      icon = 'bars',
      onSelect = function() 
        local Tikozaal = {}   
        Tikozaal.closestPlayer, Tikozaal.closestDistance = ESX.Game.GetClosestPlayer()
        if Tikozaal.closestPlayer == -1 or Tikozaal.closestDistance > 3.0 then
             ESX.ShowNotification('Aucun joueur à ~b~proximité')
             lib.showContext('boss_menu')
        else
            TriggerServerEvent('Tikoz:Virer', GetPlayerServerId(Tikozaal.closestPlayer), ESX.PlayerData.job.name, 0)
            lib.showContext('boss_menu')
        end 
      end
    }
  }
})

lib.registerContext({
  id = 'gestion_argent',
  title = 'gestion argent',
  menu = 'boss_menu',
  onBack = function()
    print('Went back!')
  end,
  onExit = function() CreateThread(PositionBossCheck) end,
  options = {
    {
      title = '💶retirer argent',
      icon = 'bars',
      onSelect = function() autoRetraitEntreprise() end
    },
    {
      title = '🖥️deposer argent',
      icon = 'bars',
      onSelect = function() depotargentmechanic() end
    },
    {
      title = '🖥️argent du compte ',
      icon = 'bars',
      onSelect = function() getarententreprise() end
    }
}
})

function getarententreprise()
  ESX.TriggerServerCallback('getSocietyMoney', function(money)
  ESX.ShowNotification('compte ~g~'..money..'$')
  lib.showContext('gestion_argent')
  end)
end


function depotargentmechanic()
  local input = lib.inputDialog('DEPO', {
    {type = "number", label = "Montant du depo", min = 1, max = 100000}
  })
    if not input then
        ESX.ShowAdvancedNotification('Banque societé', "~b~auto ecolerallye", "Vous avez pas assez ~r~d'argent", 'CHAR_BANK_FLEECA', 9)
        lib.showContext('boss_menu')
    else
        TriggerServerEvent("depotentreprise", input[1])
        lib.showContext('boss_menu')
    end
end

function autoRetraitEntreprise()
  local input = lib.inputDialog('RETRAIT', {
    {type = "number", label = "Montant du retrait", min = 1, max = 100000}
  })
    if not input then
        ESX.ShowAdvancedNotification('Banque societé', "~b~rallye", "Vous avez pas assez ~r~d'argent", 'CHAR_BANK_FLEECA', 9)
        lib.showContext('boss_menu')
    else
        TriggerServerEvent("RetraitEntreprise", input[1])
        lib.showContext('boss_menu')
    end
end



function PositionBossCheck()
  local ms   
  while (function()
      ms = 1000
      if #(GetEntityCoords(PlayerPedId()) - Config.pose.boss) <= 2 and ESX.PlayerData.job.name == Config.JobUtiliser and ESX.PlayerData.job.grade_name == Config.gradejobboss then
          lib.showTextUI('[E] - boss menu', {
            position = "left-center",
            style = {
                borderRadius = 0,
                backgroundColor = '#3fd2d5',
                color = 'white',
            }
          })
          ms = 0 
          if IsControlJustPressed(1,51) then
            lib.showContext('boss_menu')
            local Tikozaal = {}
            lib.hideTextUI()
            return false 
          end
      end
  
      if #(GetEntityCoords(PlayerPedId()) - Config.pose.boss) > 2 then
         lib.hideTextUI()
      end

      return true 
    end)() do 
      Wait(ms)
  end
end



function PositionCoffreCheck()
  local ms
  local seetext = true 
  while (function()
      ms = 1000
      if #(GetEntityCoords(PlayerPedId()) - Config.pose.coffre) <= 2 and ESX.PlayerData.job.name == Config.JobUtiliser then 
          if seetext then
            lib.showTextUI('[E] - coffre menu', {
              position = "left-center",
              style = {
                  borderRadius = 0,
                  backgroundColor = '#3fd2d5',
                  color = 'white',
              }
            })
          end
          ms = 0 
          if IsControlJustPressed(1,51) then
            exports.ox_inventory:openInventory('stash', {id='coffre_rally'})
            seetext = false 
            lib.hideTextUI()
          end
      end
  
      if #(GetEntityCoords(PlayerPedId()) - Config.pose.coffre) > 2 then
         lib.hideTextUI() 
         seetext = true 
      end

      return true 
    end)() do 
      Wait(ms)
    end
end

-------rangment
function checkrange(car, int)
  CreateThread(function()
      while true do 
          if #(GetEntityCoords(PlayerPedId()) - Config.pose.delete) <= 5 then
              ms = 0 
              ESX.ShowHelpNotification("Appuie sur E pour ranger : ~b~"..int.name)
              if IsControlJustPressed(1, 51) then
                  TriggerServerEvent('oliann-removekeys', plate)
                  local plate = ESX.Math.Trim(GetVehicleNumberPlateText(vehicle))
                  ESX.Game.DeleteVehicle(car)
                  cansee = false
                  return 
              end
          else ms = 1000 end 
          Wait(ms)
      end
  end)
end
---vestiere

function vuniformemecano()
  TriggerEvent('skinchanger:getSkin', function(skin)
      local uniformObject
      if skin.sex == 0 then
          uniformObject = Config.tenue.male
          CreateThread(PositionVestiereCheck)
      else
          uniformObject = Config.tenue.female
          CreateThread(PositionVestiereCheck)
      end
      if uniformObject then
          TriggerEvent('skinchanger:loadClothes', skin, uniformObject)
      end
  end)
end

function vuniformesoirer()
  TriggerEvent('skinchanger:getSkin', function(skin)
      local uniformObject
      if skin.sex == 0 then
          uniformObject = Config.soirer.male
          CreateThread(PositionVestiereCheck)
      else
          uniformObject = Config.soirer.female
          CreateThread(PositionVestiereCheck)
      end
      if uniformObject then
          TriggerEvent('skinchanger:loadClothes', skin, uniformObject)
      end
  end)
end

function vuniformetravail()
  TriggerEvent('skinchanger:getSkin', function(skin)
      local uniformObject
      if skin.sex == 0 then
          uniformObject = Config.travail.male
          CreateThread(PositionVestiereCheck)
      else
          uniformObject = Config.travail.female
          CreateThread(PositionVestiereCheck)
      end
      if uniformObject then
          TriggerEvent('skinchanger:loadClothes', skin, uniformObject)
      end
  end)
end

function vcivil()
  ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
      TriggerEvent('skinchanger:loadSkin', skin)
      CreateThread(PositionVestiereCheck)
  end)
end

lib.registerContext({
  id = 'vestiere',
  title = 'VESTIERE',
  onBack = function()
    print('Went back!')
  end,
  onExit = function() CreateThread(PositionVestiereCheck) end,
  options = {
    {
      title = 'tenu pilote',
      icon = 'bars',
      onSelect = function() vuniformemecano() end
    },
    {
      title = 'tenu mecano',
      icon = 'bars',
      onSelect = function() vuniformetravail() end
    },
    {
      title = 'tenu soirer',
      icon = 'bars',
      onSelect = function() vuniformesoirer() end
    },
    {
      title = 'remettre sa tenue',
      icon = 'bars',
      onSelect = function() vcivil() end
    }
}
})

function PositionVestiereCheck()
  local ms   
  while (function()
      ms = 1000
      ESX.PlayerData = ESX.GetPlayerData()
      if #(GetEntityCoords(PlayerPedId()) - Config.pose.vestiere) <= 2 and ESX.PlayerData.job.name == Config.JobUtiliser then  
          lib.showTextUI('[E] - vestiere menu', {
            position = "left-center",
            style = {
                borderRadius = 0,
                backgroundColor = '#3fd2d5',
                color = 'white',
            }
          })
          ms = 0 
          if IsControlJustPressed(1,51) then
            lib.showContext('vestiere')
            lib.hideTextUI()
            return false 
          end
        else

      end
  
      if #(GetEntityCoords(PlayerPedId()) - Config.pose.vestiere) > 2 then
         lib.hideTextUI()
      end

      return true 
    end)() do 
      Wait(ms)
    end
end

---Bar

local function OpenMenuBar()
  local menu = {}
  for k, v in pairs(Bar) do 
      menu[#menu+1] = {
          title = v.label,
          description = "acheter "..v.label.."",
          onSelect = function() 
            TriggerServerEvent('add', v.name, 1)
            CreateThread(PositionBarCheck)
           end,
          image = v.image,
      }
  end
  lib.registerContext({
      id = "bar",
      title = "BAR MENU",
      onExit = function() CreateThread(PositionBarCheck) end,
      options = menu
  })
  lib.showContext('bar')
end


function PositionBarCheck()
  local ms   
  while (function()
      ms = 2000
      ESX.PlayerData = ESX.GetPlayerData()
      if #(GetEntityCoords(PlayerPedId()) - Config.pose.bar) <= 2 and ESX.PlayerData.job.name == Config.JobUtiliser then 
          lib.showTextUI('[E] - bar menu', {
            position = "left-center",
            style = {
                borderRadius = 0,
                backgroundColor = '#3fd2d5',
                color = 'white',
            }
          })
          ms = 0 
          if IsControlJustPressed(1,51) then
            OpenMenuBar()
            lib.hideTextUI()
            return false 
          end
        else

      end
  
      if #(GetEntityCoords(PlayerPedId()) - Config.pose.bar) > 2 then
         lib.hideTextUI()
      end

      return true 
    end)() do 
      Wait(ms)
    end
end 