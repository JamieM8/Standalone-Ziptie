RegisterServerEvent("handcuff:s:back")
AddEventHandler("handcuff:s:back", function(closetP)
    if IsPlayerAceAllowed(source, "ziptie") then
        TriggerClientEvent('jamie:anim', source)
        Citizen.Wait(3000)
        TriggerClientEvent("handcuff:c:back", closetP)
    else
        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'Hype! Custom Styling!', style = { ['background-color'] = '#ffffff', ['color'] = '#000000' } })
    end
end)

RegisterServerEvent("handcuff:s:front")
AddEventHandler("handcuff:s:front", function(closetP)
    if IsPlayerAceAllowed(source, "ziptie") then
        TriggerClientEvent('jamie:anim', source)
        Citizen.Wait(3000)
        TriggerClientEvent("handcuff:c:front", closetP)
    else
        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'Hype! Custom Styling!', style = { ['background-color'] = '#ffffff', ['color'] = '#000000' } })
    end
end)

RegisterServerEvent("handcuff:s:free")
AddEventHandler("handcuff:s:free", function(closetP)
    if IsPlayerAceAllowed(source, "ziptie") then
        TriggerClientEvent('jamie:anim', source)
        Citizen.Wait(3000)
        TriggerClientEvent("handcuff:c:free", closetP)
    else
        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'inform', text = 'Hype! Custom Styling!', style = { ['background-color'] = '#ffffff', ['color'] = '#000000' } })
    end
end)