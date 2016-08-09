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

local HTTP_COMMANDS = {'GET', 'POST', 'PUT', 'DELETE', 'CONNECT', 'HEAD'}
local HTTP_PROPERTY = {HOST = 'Host:', USER_AGENT = 'User-Agent:',  AUTHORIZATION = 'Authorization:', PROXY_AUTHORIZATION = 'Proxy-Authorization:'}
local HTTP_PREFIX = 'http://'
local HTTP_PREFIX_LEN = HTTP_PREFIX:len()
local HTTPS_PREFIX = 'https://'
local HTTPS_PREFIX_LEN = HTTPS_PREFIX:len()
local HTTP = 'HTTP'
local HTTP_LEN = HTTP:len()

local HTTP_STATUS_LEN = 3

local HttpProtoErrorBucket = {NO_BUCKET = 0, CLI_ERR_OTHER_BUCKET = 1, SRV_ERR_OTHER_BUCKET = 2,
  CLI_ERR_UNAUTH_BUCKET = 3, CLI_ERR_NOT_FOUND_BUCKET = 4, CLI_ERR_DEF1_BUCKET = 5,
  SRV_ERR_DEF1_BUCKET = 6, SRV_ERR_DEF2_BUCKET = 7, CLI_ERR_UNAUTH_NO_PASS_BUCKET = 8}

  
-- remove leading and trailing spaces from string s 
local function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end 


-- Returns HTTP command which starts from pstr[offset]
-- If this is not legal command then nil is returned
local function get_http_command(pstr, offset)
  for idx, cmd in ipairs(HTTP_COMMANDS) do
    if pstr:sub(offset, cmd:len()) == cmd then
      return cmd
    end
  end
  return nil
end


-- HTTP request parser
function parse_request(payload, stats)
  if payload:len() == 0 then
    return 0
  end
  -- limit payload to HTTP header:
  local pstart, pend = payload:find("\r\n\r\n") 
  if pend then
    payload = payload:sub(1, pend) 
  end
  local lines_iterator = payload:gmatch("[^\r\n]+")
  local text = lines_iterator()
  if text == nil then
    return 1
  end 
  local cmd = get_http_command(text , 1)
  if cmd == nil then
    print('Lua: This is not a HTTP request')
    --    error(string.format('This is not a HTTP request: %s', payload))
    return 1
  end
  --  print('cmd:', cmd)
  local base_url, idx
  local url_offset = cmd:len() + 1 + 1
  idx = text:find('?', url_offset) or text:find(' ', url_offset)
  if idx ~= nil then
    base_url = text:sub(url_offset, idx - 1)
  end
  local host
  local url_has_host = false
  if base_url:sub(1, 1) ~= '/' then 
    host = text:sub(url_offset):match('([^ /]+)')
    url_has_host = true
  end
  if url_has_host then
    for kk, vv in pairs({HTTP_PREFIX, HTTPS_PREFIX}) do
      if text:find(string.format("%s %s", cmd, vv)) then
        url_has_host = true
        base_url = base_url:sub(vv:len() + 1)
        host = base_url:match('([^ /]+)')
        break
      end
    end
  end
  -- print('base_url:\t"' .. base_url .. '"')
  local properties = {}
  for line in lines_iterator do
    local space_pos = line:find(' ')
    if space_pos ~= nil then
      properties[line:sub(1, space_pos - 1)] = line:sub(space_pos + 1)
    end
  end

  if (not url_has_host) and properties[HTTP_PROPERTY.HOST] then
    host = properties[HTTP_PROPERTY.HOST]
    -- print('host:\t"' .. host .. '"')
    base_url = host .. base_url
  end
  if properties[HTTP_PROPERTY.USER_AGENT] then
    parse_user_agent(properties[HTTP_PROPERTY.USER_AGENT], stats)
  end
  
  if host ~= nil then
    host = trim(host)
    stats:setOperationName(host, host:len())
  end
  return 0
end


local function handle_http_code(http_response_code, stats)
  if http_response_code == 404 then
    stats:setTransportError(HttpProtoErrorBucket.CLI_ERR_NOT_FOUND_BUCKET)
  elseif (http_response_code == 401) or (http_response_code == 407) then
    stats:setTransportError(HttpProtoErrorBucket.CLI_ERR_UNAUTH_BUCKET)
  elseif (http_response_code >= 400) and (http_response_code < 500) then
    stats:setTransportError(HttpProtoErrorBucket.CLI_ERR_OTHER_BUCKET)
  elseif (http_response_code >= 500) and (http_response_code < 600) then
    stats:setTransportError(HttpProtoErrorBucket.SRV_ERR_OTHER_BUCKET)
  end
end


-- HTTP response parser
function parse_response(payload, stats)
  if payload:len() == 0 then
    return 0
  end
  -- limit payload to HTTP header:
  local pstart, pend = payload:find("\r\n\r\n") 
  if pend then
    payload = payload:sub(1, pend) 
  end 
  local lines_iterator = payload:gmatch("[^\r\n]+")
  local text = lines_iterator()
  if text:sub(1, HTTP_LEN) ~= HTTP then
    print('Lua: This is not a HTTP response')
    return 1
  end
  local space_pos = text:find(' ')
  if space_pos == nil then
    error('Corrupted HTTP response')
    return 1
  else
    local http_code_str = text:sub(space_pos + 1, space_pos + HTTP_STATUS_LEN)
    --    print('"'..http_code_str..'"')
    if http_code_str then
      handle_http_code(tonumber(http_code_str), stats)
    end
  end
  return 0
end


local function set_user_agent_fields(os_name, hardware, browser_name, browser_version, stats)
  stats:setBrowserOsHardware(browser_name, browser_version, os_name, hardware)
end


-- Useful links describing 'User-Agent' field:
-- http://en.wikipedia.org/wiki/User_agent
-- https://developer.mozilla.org/en-US/docs/Gecko_user_agent_string_reference
-- http://msdn.microsoft.com/en-us/library/ms537503%28v=vs.85%29.aspx
-- http://www.useragentstring.com/pages/useragentstring.php
function parse_user_agent(pstr, stats)
  local os_name, browser_name, browser_version, hardware
  os_name, hardware, browser_name, browser_version = pstr:match('%(%w+; (%w+); (%w+) .-(Firefox)/(%S+)')
  if os_name and hardware and browser_name and browser_version then
    set_user_agent_fields(os_name, hardware, browser_name, browser_version, stats)
    return
  end
  browser_name, browser_version, hardware, os_name = pstr:match('%(%w+; (MSIE) (%S+); (%S+) (.[^;%)]+)')
  if os_name and hardware and browser_name and browser_version then
    os_name = string.format("%s %s", hardware, os_name)
    set_user_agent_fields(os_name, hardware, browser_name, browser_version, stats)
    return
  end
  browser_name, browser_version, hardware, os_name = pstr:match('(Opera)/(%S+) %((Windows) ([^;%)]+)')
  if os_name and hardware and browser_name and browser_version then
    os_name = string.format("%s %s", hardware, os_name)
    set_user_agent_fields(os_name, hardware, browser_name, browser_version, stats)
    return
  end
end


local the_module = {}
the_module.parse_request = parse_request
the_module.parse_response = parse_response
return the_module
