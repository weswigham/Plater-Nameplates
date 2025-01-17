
local DF = _G["DetailsFramework"]
if (not DF or not DetailsFrameworkCanLoad) then
	return
end

local C_Timer = _G.C_Timer
local unpack = table.unpack or _G.unpack

--make a namespace for schedules
DF.Schedules = DF.Schedules or {}

---@class df_schedule : table
---@field NewTicker fun(time: number, callback: function, ...: any): timer
---@field NewTimer fun(time: number, callback: function, ...: any): timer
---@field Cancel fun(ticker: timer)
---@field After fun(time: number, callback: function)
---@field SetName fun(object: timer, name: string)
---@field RunNextTick fun(callback: function)

--run a scheduled function with its payload
local triggerScheduledTick = function(tickerObject)
    local payload = tickerObject.payload
    local callback = tickerObject.callback

    local result, errortext = pcall(callback, unpack(payload))
    if (not result) then
        DF:Msg("error on scheduler: ", tickerObject.path, tickerObject.name, errortext)
    end
    return result
end

--schedule to repeat a task with an interval of @time
function DF.Schedules.NewTicker(time, callback, ...)
    local payload = {...}
    local newTicker = C_Timer.NewTicker(time, triggerScheduledTick)
    newTicker.payload = payload
    newTicker.callback = callback
    newTicker.expireAt = GetTime() + time

    --debug
    newTicker.path = debugstack()
    --
    return newTicker
end

--schedule a task with an interval of @time
function DF.Schedules.NewTimer(time, callback, ...)
    local payload = {...}
    local newTimer = C_Timer.NewTimer(time, triggerScheduledTick)
    newTimer.payload = payload
    newTimer.callback = callback
    newTimer.expireAt = GetTime() + time

    --debug
    newTimer.path = debugstack()
    --

    return newTimer
end

--cancel an ongoing ticker, the native call tickerObject:Cancel() also works with no problem
function DF.Schedules.Cancel(tickerObject)
    --ignore if there's no ticker object
    if (tickerObject) then
        return tickerObject:Cancel()
    end
end

--schedule a task with an interval of @time without payload
function DF.Schedules.After(time, callback)
    C_Timer.After(time, callback)
end

function DF.Schedules.SetName(object, name)
    object.name = name
end

function DF.Schedules.RunNextTick(callback)
    return DF.Schedules.After(0, callback)
end