--[[
Copyright © 2015 Dynatrace LLC. 
All rights reserved. 
Unpublished rights reserved under the Copyright Laws of the United States.

U.S. GOVERNMENT RIGHTS-Use, duplication, or disclosure by the U.S. Government is
subject to restrictions as set forth in Dynatrace LLC license agreement and as
provided in DFARS 227.7202-1(a) and 227.7202-3(a) (1995), DFARS
252.227-7013(c)(1)(ii) (OCT 1988), FAR 12.212 (a) (1995), FAR 52.227-19, 
or FAR 52.227-14 (ALT III), as applicable.

This product contains confidential information and trade secrets of Dynatrace LLC. 
Disclosure is prohibited without the prior express written permission of Dynatrace LLC. 
Use of this product is subject to the terms and conditions of the user's License Agreement with Dynatrace LLC.
See the license agreement text online at https://community.dynatrace.com/community/download/attachments/5144912/dynaTraceBSD.txt?version=3&modificationDate=1441261477160&api=v2
--]]

--[[

This is mock class that pretends IPayloadParserResult interface.
It is used in parser tests written in Lua.
 
--]]

local Stats = {}
Stats.__index = Stats

setmetatable(Stats, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function Stats.new()
  local self = setmetatable({}, Stats)
  self.operation_name = nil
  self.parameters = {}
  self.appl_errors = {}
  self.metrics = {}
  self.corr_id = nil
  self.username = nil
  self.os_name = nil
  self.hardware = nil
  self.browser = nil
  self.browser_version = nil
  self.bucket_id = nil 
  self.isFirstTransHit = true
  self.isLastTransHit = true
  self.isMonitor = true
  return self
end

-- operation name ------------------------------------
function Stats:getOperationName()
   return self.operation_name
end

function Stats:setOperationName(name, len)
   if len == nil then
      error("'len' parameter is obligatory")
   end
   self.operation_name = name:sub(1, len)
end

-- parameters ----------------------------------------
function Stats:getParameter(id)
   return self.parameters[id]
end

function Stats:setParameter(id, value)
   self.parameters[id] = value
end

-- attributes ----------------------------------------
function Stats:getAttribute(id)
   return self.appl_errors[id]
end

function Stats:setAttribute(id, value)
   self.appl_errors[id] = value
end

-- metrics -------------------------------------------
function Stats:getMetric(id)
   return self.metrics[id]
end

function Stats:setMetric(id, value)
   self.metrics[id] = value
end

-- browser / os / hardware ---------------------------
function Stats:getBrowser()
   return self.browser
end

function Stats:getBrowserVersion()
   return self.browser_version
end

function Stats:getOs()
   return self.os_name
end

function Stats:getHardware()
   return self.hardware
end

function Stats:setBrowserOsHardware(browserName, browserVersion, osName, hardwareName)
   self.hardware = hardwareName
   self.os_name = osName
   self.browser_version = browserVersion
   self.browser = browserName
end

-- user name -----------------------------------------
function Stats:getUserName()
   return self.username
end

function Stats:setUserName(name)
   self.username = name
end

-- correlation id ------------------------------------
function Stats:getCorrelationId()
   return self.corr_id
end

function Stats:setCorrelationId(id)
   self.corr_id = id
end

-- transport error -----------------------------------
function Stats:getTransportError()
   return self.bucket_id
end

function Stats:setTransportError(bucket_id)
   self.bucket_id = bucket_id 
end

-- dictionary ----------------------------------------
function Stats:getDictText(text, len)
   return {false, nil, nil}
end

-- hits -> transactions flags ------------------------
function Stats:isFirstTransHit()
   return self.isFirstTransHit
end

function Stats:setFirstTransHit(isFirstTransHit)
   self.first_hit = isFirstTransHit
end

function Stats:isLastTransHit()
   return self.isLastTransHit
end

function Stats:setLastTransHit(isLastTransHit)
   self.last_hit = isLastTransHit
end

-- per operation reporting and auto-learning ---------
function Stats:isMonitored()
   return self.isMonitor
end

function Stats:setMonitored(flag)
   self.isMonitor = flag
end



return Stats
