require "MF_ISMoodle"

MF.createMoodle("Proteins");
MF.createMoodle("Lipids");
MF.createMoodle("Carbohydrates");
MF.createMoodle("GainingWeight");
MF.createMoodle("LoosingWeight");


local caloriesDecreaseDivider = 2500;
-- This is from the game
--local caloriesToGainWeightMaxFemale = 3000;
--local caloriesToGainWeightMaxMale = 4000;
-- This is the average we will be using to remove doing a if ...
local caloriesIncreaseDivider = 3500;

local function MoodleUpdatePlayer(player)
    if player == getPlayer() then
        local nutrition = player:getNutrition();
        -- Simple moodles :
        MF.getMoodle("Proteins"):setValue(nutrition:getProteins());
        MF.getMoodle("Lipids"):setValue(nutrition:getLipids());
        MF.getMoodle("Carbohydrates"):setValue(nutrition:getCarbohydrates());

        -- Moodles for weight gain/loss
        local playerWeight = nutrition:getWeight();
        -- Compute limits (this is from the java files)
        local GainingWeightLimit = 1600 + (playerWeight - 80) * 40;
        local loosingWeightLimit = (playerWeight - 70) * 30;
        if loosingWeightLimit > 0 then
            loosingWeightLimit = 0;
        end
        -- Compute if we should gain/loose weight : based on traits Overweight / Underweight limits
        local shouldGainWeight = (playerWeight < 75);
        local shouldLooseWeight = (playerWeight > 85);

        -- setThresholds and values depending on if we should (or not) gain weight
        if shouldGainWeight then
            -- Gaining weight is good
            MF.getMoodle("GainingWeight"):setThresholds( -9999, -9999, -9999, -9999, GainingWeightLimit, GainingWeightLimit + caloriesIncreaseDivider / 3, 9999, 9999);
            MF.getMoodle("GainingWeight"):setValue(nutrition:getCalories());
            -- Loosing weight is really bad
            MF.getMoodle("LoosingWeight"):setThresholds( -9999, -9999, loosingWeightLimit - caloriesDecreaseDivider / 3, loosingWeightLimit, 9999, 9999, 9999, 9999);
            MF.getMoodle("LoosingWeight"):setValue(nutrition:getCalories());
        elseif shouldLooseWeight then
            -- Loosing it is good
            MF.getMoodle("LoosingWeight"):setThresholds( -9999, -9999, -9999, -9999, -loosingWeightLimit, -(loosingWeightLimit - caloriesDecreaseDivider / 3), 9999, 9999);
            MF.getMoodle("LoosingWeight"):setValue(-nutrition:getCalories());
            -- Gaining weight is really bad
            MF.getMoodle("GainingWeight"):setThresholds( -9999, -9999, -(GainingWeightLimit + caloriesIncreaseDivider / 3), -GainingWeightLimit, 9999, 9999, 9999, 9999);
            MF.getMoodle("GainingWeight"):setValue(-nutrition:getCalories());
        else
            -- We don't really care
            MF.getMoodle("GainingWeight"):setValue(0);
            MF.getMoodle("LoosingWeight"):setValue(0);
        end
    end
end
local function MoodleCreatePlayer()
    MF.getMoodle("Proteins"):setThresholds( -1500, -1000, -300, -200, 50, 300, 9999, 9999)
    MF.getMoodle("Lipids"):setThresholds( -9999, -1500, -1000, -500, 400, 700, 9999, 9999)
    MF.getMoodle("Carbohydrates"):setThresholds( -9999, -9999, -9999, -9999, 400, 700, 9999, 9999)
end

Events.OnPlayerUpdate.Add(MoodleUpdatePlayer);
Events.OnCreatePlayer.Add(MoodleCreatePlayer);
