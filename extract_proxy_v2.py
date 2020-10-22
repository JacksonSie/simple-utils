#-*- coding: utf-8 -*-
#using python3
import sys
import requests
from bs4 import BeautifulSoup
import js2py
import re
#import execjs


  
def proxy_list(country):
  #url = 'http://spys.one/free-proxy-list/TW/'
  url = 'http://spys.one/free-proxy-list/' + country + '/'
  r = requests.get(url)
  if r.status_code == requests.codes.ok:
    print("OK")
    soup = BeautifulSoup(r.text, 'html.parser')
    scripts = soup.find_all('script')
    js1 = scripts[3].string + '\r\n'
    #ips = soup.find_all(attrs={"class": "spy14"})
    trs = soup.find_all('tr')    
    count = 1
    for tr in trs:
      #print(len(trs))
      ss = str(tr)#ss's type must be string
      
      try:
        soup2 = BeautifulSoup(ss, 'html.parser')
        regexp = '.*<font class="spy14">(.*)<script type="text/javascript">(document.*)</script></font></td><td colspan="1">.*(SOCKS5|HTTP).*</td><td colspan="1"><font class="spy1">'
        
        pattern = re.compile(regexp)
        m = pattern.match(ss)
        if m != None:
          #print(m.group(0))
          ip = m.group(1)
          #print(m.group(1))
          #print(m.group(2))
          js2 = 'function x(){' + m.group(2).replace("document.write", "return ") + ';}\r\n'
          type = m.group(3)
          js3 = 'x()'
          js = js1 + js2 + js3
          port_data = js2py.eval_js(js)
          regexp = '(.*):([^\d]*)(\d*)'
          pattern = re.compile(regexp)
          mm = pattern.match(port_data)
          port = mm.group(3)
          #print(ss)
          print("{}. {}:{} {}".format(count,ip,port,type))
          count += 1
      except:
        pass  
  return
  
if __name__ == '__main__':
  if (len(sys.argv) != 2):
    print('Usage:{} [TW|JP|EN]'.format(sys.argv[0]))
    quit()
  country = sys.argv[1]
  proxy_list(country)