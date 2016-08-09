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

-- this is 'amd' module used in unit tests only

amd = {print=print}

-- http://lua-users.org/wiki/BaseSixtyFour
-- character table string
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

function amd.fromBase64(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end
