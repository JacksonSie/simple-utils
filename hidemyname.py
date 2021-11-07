from selenium import webdriver
from selenium.common.exceptions import StaleElementReferenceException
from selenium.webdriver.firefox.options import Options
import time
import re
import argparse

class crawl_proxy:
    def __init__(self, url , proxy_number = 100):
        self.executable_path = r"E:\progs\geckodriver.exe" #TODO:config.py
        self.url = url
        self.proxy_number = proxy_number
        self.proxy_list = []
        self.type = {
            'HTTP',
            'HTTPS',
            'SOCKS4',
            'SOCKS5',
        }
        self.options = Options()
        self.options.add_argument('--headless') #to show page or not to show , this is a question~
        self.options.add_argument('')
        self.browser = webdriver.Firefox(executable_path = self.executable_path , options=self.options)
        self.browser.set_window_size(1600, 1200) # avoid ElementClickInterceptedException
        self.browser.get(url)
    def crawling(self):
        while True:
            if len(self.proxy_list) == 0 : time.sleep(15) #bypass cloudflare check
            trs = self.browser.find_elements_by_tag_name('tr')
            next_sign = 'html body div#global-wrapper div#content-section section.proxy div.proxy__in div.proxy__pagination ul li.arrow__right a'
            try:
                for tr in trs[1:]:
                    tr_orig = tr.text
                    tr = re.split('\n| ' ,tr_orig)
                    type_allow = []
                    for ii in self.type : 
                        if ii in tr_orig : type_allow.append(ii)
                    type_allow = '&'.join( _ for _ in type_allow)
                    #check_ip()
                    self.proxy_list.append((type_allow,tr[3],tr[0],tr[1])) #type , country , ip , port
                    '''
                    print('%s , %s , %s , %s' %(self.proxy_list[-1][0],
                                                self.proxy_list[-1][1],
                                                self.proxy_list[-1][2],
                                                self.proxy_list[-1][3]))
                    '''
                self.browser.find_element_by_css_selector(next_sign).click()
                if self.proxy_number - len(self.proxy_list) <= 0 : break
            except StaleElementReferenceException:
                pass
        return self.proxy_list
    def check_ip(type , country , ip , port):
        #TODO
        pass

def main():
    
    crawler = crawl_proxy(url = r'https://hidemy.name/en/proxy-list/?start=1#list' , proxy_number = 10)
    result = crawler.crawling()
    #---- 要修
    parser = argparse.ArgumentParser(description='Process some integers.')
    parser.add_argument('integers', metavar='N', type=int, nargs='+',
                        help='an integer for the accumulator')
    parser.add_argument('--sum', dest='accumulate', action='store_const',
                        const=sum, default=max,
                        help='sum the integers (default: find the max)')
    args = parser.parse_args()
    print(args.accumulate(args.integers))
    
    
    
if __name__ == "__main__":
    main()