require "prefabutil"
require "scheduler"
require "simutil"
require "behaviours/doaction"

local assets =
{
    Asset("ANIM", "anim/rotbox.zip"),
    Asset("ATLAS", "images/inventoryimages/rotbox.xml"),
    Asset("IMAGE", "images/inventoryimages/rotbox.tex")

}


local function onopen(inst) 
    inst.AnimState:PlayAnimation("open") 
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")     
end 

local function onclose(inst) 
    inst.AnimState:PlayAnimation("close") 
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")        
end 

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    inst.components.container:DropEverything()
    SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
    
    inst:Remove()
end

local function onhit(inst, worker)
    inst.AnimState:PlayAnimation("hit")
    inst.components.container:DropEverything()
    inst.AnimState:PushAnimation("closed", false)
    inst.components.container:Close()
end


local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("closed", false)
end

local function EditContainer(inst)
    local self
    if TheWorld.ismastersim then
        self = inst.components.container
    else
        self = inst.replica.container
    end

    self:WidgetSetup("icebox")
end

local function fn(Sim)
    local inst = CreateEntity()

    inst:AddTag("structure")

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon("rotbox.tex")

    inst.AnimState:SetBank("rotbox")
    inst.AnimState:SetBuild("rotbox")
    inst.AnimState:PlayAnimation("closed")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        local _OnEntityReplicated = inst.OnEntityReplicated
        inst.OnEntityReplicated = function(inst)
            if _OnEntityReplicated then
                _OnEntityReplicated(inst)
            end
            EditContainer(inst)
        end
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("container")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose

    EditContainer(inst)

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(2)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit) 
        
    inst:ListenForEvent( "onbuilt", onbuilt)
    MakeSnowCovered(inst, .01)  

    inst:DoPeriodicTask(60, function(inst)
        local con_inst = inst.components.container
        local num_found = 0
        local num_egg = 0
        --calculate foods except spoiled foods, rotten eggs and eggs
        for k,v in pairs(inst.components.container.slots) do
            if v.prefab ~= "spoiled_food" and v.prefab ~= "rottenegg" and v.prefab ~= "bird_egg" then
                if v.components.stackable then
                    num_found = num_found + v.components.stackable:StackSize()
                else
                    num_found = num_found + 1
                end
            end
        end
        --calculate egg
        for k,v in pairs(inst.components.container.slots) do
            if v.prefab == "bird_egg" then
                num_egg = num_egg + v.components.stackable:StackSize()
            end
        end
        --turn foods into spoiled foods
        if num_found > 0 then
            for k,v in pairs(inst.components.container.slots) do
                if v.prefab ~= "spoiled_food" and v.prefab ~= "rottenegg" and v.prefab ~= "bird_egg" then
                    if v.components.stackable then
                        con_inst:ConsumeByName(v.prefab, v.components.stackable:StackSize())
                    else
                        con_inst:ConsumeByName(v.prefab, 1)
                    end
                end
            end
            for i = 1, num_found do con_inst:GiveItem(SpawnPrefab("spoiled_food")) end
        end
        --turn eggs into rotten eggs
        if num_egg > 0 then
            for k,v in pairs(inst.components.container.slots) do
                if v.prefab == "bird_egg" then
                    con_inst:ConsumeByName(v.prefab, v.components.stackable:StackSize())
                end
            end
            for i = 1, num_egg do con_inst:GiveItem(SpawnPrefab("rottenegg")) end
        end
    end)

    return inst
end

return Prefab( "common/rotbox", fn, assets), 
        MakePlacer("common/rotbox_placer", "rotbox", "rotbox", "closed")