local transformNode, model, text

local isRotating = false
local speed = 1.0
local clickCount = 0

local timeLeft = 0 

local function updateText()
text.text.value = "Количество нажатий: " .. clickCount
end

local function do_smooth_spin()
    if speed <= 0 or not isRotating or not transformNode then return end
    
    local rot = transformNode.rotate
    if not rot then return end
    
    rot:z((rot:z() + speed) % 360)
    
    transformNode.rotate = rot
    timeLeft = timeLeft - speed
    
    if timeLeft <= 0 then
        timer:unsubscribe(do_smooth_spin)
        
        local finalRot = transformNode.rotate
        finalRot:x(0) finalRot:y(0) finalRot:z(0)
        transformNode.rotate = finalRot
        
        isRotating = false
        updateText()
    end
end

local function start_rotation()
    if isRotating then return end
    
    isRotating = true
    
    timeLeft = 360
    updateText()
    
    timer:subscribe(do_smooth_spin, 0.01)
end

local function init_logic()
    transformNode = reactorController:getReactorByName("Transform")
    model = reactorController:getReactorByName("Model")
    text = reactorController:getReactorByName("Text")

    updateText()

    if model then
        model:subscribeEvent("onClick", function()
            if isRotating then return end
            
            clickCount = clickCount + 1
            updateText()
            start_rotation()
        end)
    end

    local globalHandler = osgGA.GUIEventHandler(function(ea, aa)
        if ea:getEventType() == osgGA.GUIEventAdapter.PUSH then
            if isRotating then return true end
            return true
        end

        return false
    end)

    viewer:addEventHandler(globalHandler)
end

init_logic()