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

Stats = require 'stats'
local minihttp = require 'minihttp'
local lunit = require 'lunit'

module( "minihttp_test", lunit.testcase, package.seeall )

function message(actual, expected)
  return string.format("test failure: actual=<%s> expected=<%s>", actual or 'nil', expected or 'nil')
end

function or_nil_str(value)
  if value == nil then
    return 'nil'
  end
  return value
end


function test_request()
  local payload_arr = {
    'GET /videoplayback/aa/bbb?algorithm=throttle-factor&burst=40s HTTP/1.1\r\n',
    'Host: r6---sn-oxup5-3ufe.c.youtube.com\r\n',
    'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:22.0) Gecko/20100101 Firefox/22.0\r\n',
    'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\n',
    'Accept-Language: en-US,en;q=0.5\r\n',
    'Accept-Encoding: gzip, deflate\r\n',
    'Referer: http://s.ytimg.com/yts/swfbin/watch_as3-vfldOoVEA.swf\r\n',
    'Cookie: VISITOR_INFO1_LIVE=6aStOq9K_eY; PREF=f4=210020&al=en&fv=11.2.202&f1=50000000; demographics=33e0c897fe64d81fe8b7bc0b5bd5890ce3QDAAAAYWdlaSsAAAB0BgAAAGdlbmRlcnQBAAAAbTA=; googtrans=/auto/en; YSC=7wnfMPDWVmA; wide=0; recently_watched_video_id_list=1cfd0; ACTIVITY=1373534604727\r\n',
    'Connection: keep-alive\r\n',
    'Authorization: Basic c3VwZXJ1c2VyOg==  \r\n',  
    '\r\n'
  } 
  local payload_str = table.concat(payload_arr, '')   
  local obj = Stats()
  --print(payload_str)
  local parse_status = minihttp.parse_request(payload_str, obj)
  print('Request:')
  print('\tparse_status:', parse_status)
  print('\top name:', '"'..obj.operation_name..'"')
--  assert(obj.operation_name == "r6---sn-oxup5-3ufe.c.youtube.com/videoplayback/aa/bbb")
  assert(obj.operation_name == "r6---sn-oxup5-3ufe.c.youtube.com")
  print("\tos version:", '"' .. or_nil_str(obj.os_name) .. '"')
  assert(obj.os_name == "Ubuntu", message(obj.os_name, 'Ubuntu'))
  print("\tbrowser:", '"' .. or_nil_str(obj.browser) ..'"')
  assert(obj.browser == "Firefox", message(obj.browser, 'Firefox')) 
  print("\tbrowser version:", '"'.. or_nil_str(obj.browser_version) ..'"')
  assert(obj.browser_version == "22.0", message(obj.browser_version, '22.0'))
  print("\thardware:", '"'.. or_nil_str(obj.hardware) ..'"')
  assert(obj.hardware == "Linux", message(obj.hardware, 'Linux'))
  print("\tusername:", '"'.. or_nil_str(obj.username) ..'"')
  assert(obj.username == "superuser", message(obj.username, 'superuser')) 
end


function test_request2()
  local payload_arr = {
  'GET /bluemelon/hotels_ao.jpg HTTP/1.1\r\n',
  'User-Agent: Opera/9.22 (Windows 95; U; en)\r\n', 
  'Host: www.thomson.co.uk\r\n', 
  'Accept: text/html, application/xml;q=0.9, application/xhtml+xml, image/png, image/jpeg, image/gif, image/x-xbitmap, */*;q=0.1\r\n',
  'Accept-Language: en-GB,en;q=0.9\r\n',
  'Accept-Charset: iso-8859-1, utf-8, utf-16, *;q=0.1\r\n', 
  'Accept-Encoding: deflate, gzip, x-gzip, identity, *;q=0\r\n', 
  'Referer: http://www.thomson.co.uk/hotels/hotels.html\r\n',
  'If-Modified-Since: Mon, 25 Jun 2007 11:35:47 GMT\r\n',
  'If-None-Match: \"28cd-116a-69fd0ac0\"\r\n',
  'Cookie: disableSearchHelp=true; thomsonrv=x%5Ex%5Ex%23http%3A//www.thomson.co.uk/%5EGreat%20offers%20on%20Holidays%2C%20Flights%20and%20Hotels%23http%3A//www.thomson.co.uk/editorial/legal/about-thomson.html%5EAbout%20Thomson%23http%3A//www.thomson.co.uk/hotels/hotels.html%5EGreat%20hotel%20and%20apartment%20deals%23http%3A//www.thomson.co.uk/editorial/faqs/faqs.html%5EFrequently%20Asked%20Questions%23http%3A//www.thomson.co.uk/editorial/legal/contact-us.html%5EContact%20Us%23http%3A//www.thomson.co.uk/editorial/legal/thomson-shops.html%5EThomson%20Shops%23; __utmz=193973736.1202413139.1.1.utcn=(direct)|utmcsr=(direct)|utmcmd=(none); __utma=193973736.1543780758.1202413139.1202491520.1202493177.5; __utmb=193973736; __utmc=193973736\r\n',
  'Cookie2: $Version=1\r\n',
  'Connection: Keep-Alive, TE\r\n', 
  'TE: deflate, gzip, chunked, identity, trailers\r\n',
  '\r\n'
  } 
  local payload_str = table.concat(payload_arr, '')     
  local obj = Stats()
  --print(payload_str)
  local parse_status = minihttp.parse_request(payload_str, obj)
  print('Request2:')
  print('\tparse_status:', parse_status)
  print('\top name:', '"'..obj.operation_name..'"')
--  assert(obj.operation_name == "r6---sn-oxup5-3ufe.c.youtube.com/videoplayback/aa/bbb")
  print("\tos version:", '"' .. or_nil_str(obj.os_name) .. '"')
--  assert(obj.os_name == "Ubuntu", message(obj.os_name, 'Ubuntu'))
  print("\tbrowser:", '"' .. or_nil_str(obj.browser) ..'"')
--  assert(obj.browser == "Firefox", message(obj.browser, 'Firefox')) 
  print("\tbrowser version:", '"'.. or_nil_str(obj.browser_version) ..'"')
--  assert(obj.browser_version == "22.0", message(obj.browser_version, '22.0'))
  print("\thardware:", '"'.. or_nil_str(obj.hardware) ..'"')
--  assert(obj.hardware == "Linux", message(obj.hardware, 'Linux'))
end


function test_request3()  
  local payload_str = "GET /thomson/cms/thomson.co.uk/byo/details/details?reference=reviewtop HTTP/1.1\r\nVia: 1.0 LANPROXY\r\nUser-Agent: Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1;SV1)\r\nHost: www.thomson.co.uk\r\nCookie: JSESSIONID=DC2DDA255CB5459B600BD8868E1A1EEF.iscapethomsonp19c; thomsonrv=x%5Ex%5Ex%23http%3A//www.thomson.co.uk/editorial/deals/summer-2008-deals.tml%5ESummer%202008%20Deals%23http%3A//www.thomson.co.uk/editorial/deals/deals.html%5EThomson%20deals%20on%20holidays%2C%20hotels%20and%20flights%23http%3A//www.thomson.co.uk/%5EGreat%20offers%20on%20Holidays%2C%20Flights%20and%20Hotels%23; FHPI=\"USG=search group 1\"; dealsHelper=false; __utma=193973736.1893857425.1199707242.1199707242.1202485101.2; __utmb=193973736; __utmz=193973736.1202485101.2.2.utmccn=(organic)|utmcsr=google|utmctr=thomson|utmcmd=organic; __utmc=193973736\r\nAccept: */*\r\nReferer: http://www.thomson.co.uk/thomson/page/byo/search/reults.page?sortOption=2&pageSize=10&x=11&y=7\r\nAccept-Language: en-gb\r\nCache-Control: max-stale=0\r\nConnection: close\r\nX-BlueCoat-Via: 599DB86B6F9957B8\r\nAuthorization: Basic c3VwZXJ1c2VyOg==  \r\n\r\n" 
  local obj = Stats()
  --print(payload_str)
  local parse_status = minihttp.parse_request(payload_str, obj)
  print('Request3:')
  print('\tparse_status:', parse_status)
  print('\top name:', '"'..obj.operation_name..'"')
--  assert(obj.operation_name == 'www.thomson.co.uk/thomson/cms/thomson.co.uk/byo/details/details', message(obj.operation_name, 'www.thomson.co.uk/thomson/cms/thomson.co.uk/byo/details/details'))
  assert(obj.operation_name == 'www.thomson.co.uk', message(obj.operation_name, 'www.thomson.co.uk'))
  print("\tos version:", '"' .. or_nil_str(obj.os_name) .. '"')
  assert(obj.os_name == "Windows NT 5.1", message(obj.os_name, 'Windows NT 5.1'))
  print("\tbrowser:", '"' .. or_nil_str(obj.browser) ..'"')
  assert(obj.browser == "MSIE", message(obj.browser, 'MSIE')) 
  print("\tbrowser version:", '"'.. or_nil_str(obj.browser_version) ..'"')
  assert(obj.browser_version == "6.0", message(obj.browser_version, '6.0'))
  print("\thardware:", '"'.. or_nil_str(obj.hardware) ..'"')
  assert(obj.hardware == "Windows", message(obj.hardware, 'Windows'))
  print("\tusername:", '"'.. or_nil_str(obj.username) ..'"')
  assert(obj.username == "superuser", message(obj.username, 'superuser')) 
end

function test_request4()  
  local payload_str = "GET http://www.onet.pl/thomson/cms/thomson.co.uk/byo/details/details?reference=reviewtop HTTP/1.1\r\nVia: 1.0 LANPROXY\r\nUser-Agent: Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1;SV1)\r\nHost: www.thomson.co.uk\r\nCookie: JSESSIONID=DC2DDA255CB5459B600BD8868E1A1EEF.iscapethomsonp19c; thomsonrv=x%5Ex%5Ex%23http%3A//www.thomson.co.uk/editorial/deals/summer-2008-deals.tml%5ESummer%202008%20Deals%23http%3A//www.thomson.co.uk/editorial/deals/deals.html%5EThomson%20deals%20on%20holidays%2C%20hotels%20and%20flights%23http%3A//www.thomson.co.uk/%5EGreat%20offers%20on%20Holidays%2C%20Flights%20and%20Hotels%23; FHPI=\"USG=search group 1\"; dealsHelper=false; __utma=193973736.1893857425.1199707242.1199707242.1202485101.2; __utmb=193973736; __utmz=193973736.1202485101.2.2.utmccn=(organic)|utmcsr=google|utmctr=thomson|utmcmd=organic; __utmc=193973736\r\nAccept: */*\r\nReferer: http://www.thomson.co.uk/thomson/page/byo/search/reults.page?sortOption=2&pageSize=10&x=11&y=7\r\nAccept-Language: en-gb\r\nCache-Control: max-stale=0\r\nConnection: close\r\nX-BlueCoat-Via: 599DB86B6F9957B8\r\nAuthorization: Basic c3VwZXJ1c2VyOg==  \r\n\r\n" 
  local obj = Stats()
  --print(payload_str)
  local parse_status = minihttp.parse_request(payload_str, obj)
  print('Request4:')
  print('\tparse_status:', parse_status)
  print('\top name:', '"'..obj.operation_name..'"')
  assert(obj.operation_name == 'www.onet.pl', message(obj.operation_name, 'www.onet.pl'))
end


function test_request5()  
  local payload_str = "GET www.wp.pl/thomson/cms/thomson.co.uk/byo/details/details?reference=reviewtop HTTP/1.1\r\nVia: 1.0 LANPROXY\r\nUser-Agent: Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1;SV1)\r\nHost: www.thomson.co.uk\r\nCookie: JSESSIONID=DC2DDA255CB5459B600BD8868E1A1EEF.iscapethomsonp19c; thomsonrv=x%5Ex%5Ex%23http%3A//www.thomson.co.uk/editorial/deals/summer-2008-deals.tml%5ESummer%202008%20Deals%23http%3A//www.thomson.co.uk/editorial/deals/deals.html%5EThomson%20deals%20on%20holidays%2C%20hotels%20and%20flights%23http%3A//www.thomson.co.uk/%5EGreat%20offers%20on%20Holidays%2C%20Flights%20and%20Hotels%23; FHPI=\"USG=search group 1\"; dealsHelper=false; __utma=193973736.1893857425.1199707242.1199707242.1202485101.2; __utmb=193973736; __utmz=193973736.1202485101.2.2.utmccn=(organic)|utmcsr=google|utmctr=thomson|utmcmd=organic; __utmc=193973736\r\nAccept: */*\r\nReferer: http://www.thomson.co.uk/thomson/page/byo/search/reults.page?sortOption=2&pageSize=10&x=11&y=7\r\nAccept-Language: en-gb\r\nCache-Control: max-stale=0\r\nConnection: close\r\nX-BlueCoat-Via: 599DB86B6F9957B8\r\nAuthorization: Basic c3VwZXJ1c2VyOg==  \r\n\r\n" 
  local obj = Stats()
  --print(payload_str)
  local parse_status = minihttp.parse_request(payload_str, obj)
  print('Request5:')
  print('\tparse_status:', parse_status)
  print('\top name:', '"'..obj.operation_name..'"')
  assert(obj.operation_name == 'www.wp.pl', message(obj.operation_name, 'www.wp.pl'))
end


function test_response()
  local payload_arr = {
    'HTTP/1.1 200 OK\r\n',
    'Content-Length: 245760\r\n',
    'Last-Modified: Mon, 01 Jul 2013 22:46:48 GMT\r\n',
    'Date: Thu, 11 Jul 2013 09:44:58 GMT\r\n',
    'Expires: Thu, 11 Jul 2013 09:44:58 GMT\r\n',
    'Cache-Control: private, max-age=21746\r\n',
    'Content-Type: text/plain\r\n',
    'Accept-Ranges: bytes\r\n',
    'Connection: keep-alive\r\n',
    'X-Content-Type-Options: nosniff\r\n',
    'Server: gvs 1.0\r\n',
    '\r\n'
  }
  local payload_str = table.concat(payload_arr, '')
  local obj = Stats()
  --print(payload_str)
  local parse_status = minihttp.parse_response(payload_str, obj)
  print('Response:')
  print('\tparse_status:', parse_status)
end


function test_response2()
  local payload_arr = {
    'HTTP/1.1 404 Not Found\r\n',
    '\r\n'
  }
  local payload_str = table.concat(payload_arr, '')
  local obj = Stats()
  --print(payload_str)
  local parse_status = minihttp.parse_response(payload_str, obj)
  print('Response2:')
  print('\tparse_status:', parse_status)
  print('\tbucket_id:', obj.bucket_id)
  assert(obj.bucket_id == 4, message(obj.bucket_id, 4))
end



function test_user_agent()
  local examples = {
    'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:22.0) Gecko/20100101 Firefox/22.0',
    'Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)',
    'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)',
    'Opera/9.80 (Windows NT 6.0) Presto/2.12.388 Version/12.14'
  }
  local stats
  stats = Stats()
--  print('\nUser-Agent:', examples[1])
  actual = parse_user_agent(examples[1], stats)
  assert(stats.os_name == 'Ubuntu', message(stats.os_name, 'Ubuntu'))
  assert(stats.hardware == 'Linux', message(stats.hardware, 'Linux'))
  assert(stats.browser == 'Firefox', message(stats.browser, 'Firefox'))
  assert(stats.browser_version == '22.0', message(stats.browser_version, '22.0'))
  
--  print('\nUser-Agent:', examples[2])
  print('userAgent:')
  stats = Stats()
  actual = parse_user_agent(examples[2], stats)
  assert(stats.os_name == 'Windows NT 5.0', message(stats.os_name, 'Windows NT 5.0'))
  assert(stats.hardware == 'Windows', message(stats.hardware, 'Windows'))
  assert(stats.browser == 'MSIE', message(stats.browser, 'MSIE'))
  assert(stats.browser_version == '5.01', message(stats.browser_version, '5.01'))
  
--  print('\nUser-Agent:', examples[3])
  stats = Stats()
  actual = parse_user_agent(examples[3], stats)
  assert(stats.os_name == 'Windows NT 6.1', message(stats.os_name, 'Windows NT 6.1'))
  assert(stats.hardware == 'Windows', message(stats.hardware, 'Windows'))
  assert(stats.browser == 'MSIE', message(stats.browser, 'MSIE'))
  assert(stats.browser_version == '9.0', message(stats.browser_version, '9.0')) 
end