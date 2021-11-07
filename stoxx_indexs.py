import requests
import pandas
from bs4 import BeautifulSoup


def get_urls(symbol, page):
    url = 'https://www.stoxx.com/index-details?p_p_id=STOXXIndexDetailsportlet_WAR_STOXXIndexDetailsportlet&p_p_lifecycle=2&p_p_state=normal&p_p_mode=view&p_p_resource_id=paginateComponents&p_p_cacheability=cacheLevelPage&p_p_col_id=column-1&p_p_col_count=3&_STOXXIndexDetailsportlet_WAR_STOXXIndexDetailsportlet_symbol='
    payload = {'pageNumber': page}
    res = requests.post(url + symbol, data=payload)
    soup = BeautifulSoup(res.text, "lxml")

    symbol_list = soup.select('.redirect-to')
    stock_url_list = []

    for symbol in symbol_list:
        stock_url_list.append(symbol['value'])
    return stock_url_list

def get_ric(stock_url):
    res = requests.get(stock_url)
    df = pandas.read_html(res.text)

    return df[1].iat[4, 1]

def get_stock_info(ric):
    reu_url = 'https://www.reuters.com/finance/stocks/overview/'
    datetime_now=datetime.datetime.now().strftime("%Y%m%d")
    res = requests.get(reu_url + ric)
    soup = BeautifulSoup(res.text, "lxml")

    low_quote = soup.select('.sectionQuoteDetail') #dashboard 切版下半部
    currency = low_quote[0].find_all('span')[2].text.strip()
    edttime =low_quote[0].find_all('span')[3].text.strip()
    price_now = low_quote[0].find_all('span')[1].text.strip()
    o = low_quote[2].find_all('span')[1].text.strip()
    l = low_quote[3].find_all('span')[1].text.strip()
    wk52_l = low_quote[5].find_all('span')[1].text.strip()

    hi_quote = soup.select('.sectionQuoteDetailTop') #dashboard 切版上半部
    c_lastday = hi_quote[0].find_all('span')[1].text.strip()
    h = hi_quote[1].find_all('span')[1].text.strip()
    vol = hi_quote[2].find_all('span')[1].text.strip()
    wk52_h = hi_quote[3].find_all('span')[1].text.strip()

    return {'ric':ric,'currency':currency,'EDTtime':edttime,'wk52_l':wk52_l,'wk52_h':wk52_h,'c_lastday':c_lastday,'price_now':price_now,'o':o,'h':h,'l':l}


for i in range(1, 11):
    while 1:
        results = get_urls('SXXP', i)
        if len(results) != 0:
            break

    for r in results:
        ric = get_ric(r)
        print(ric, get_stock_info(ric))