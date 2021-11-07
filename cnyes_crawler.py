import pandas
import datetime , time , os
import math

class cnyes_crawler:
    def __init__(self , product , start , end , file , crawling_sleep_time = 1):
        self.url = r'http://www.cnyes.com/futures/History.aspx?mydate={0}&code=' + product # crawler 設計爬 cnyes，所以限定只有商品名稱能換
        self.start = start
        self.end = end
        self.product = product
        self.file = file.replace('$date_start',self.start).replace('$date_end',self.end).replace('$product',self.product)
        self.crawling_sleep_time = crawling_sleep_time
        self.end = end
        self.result_df = pandas.DataFrame(columns=[u"日期", u"開盤", u"最高", u"最低", u"收盤", u"成交量"])
        if self.start > self.end :
            print ("start > end")
            raise valueError
            
    def cnyes_crawler(self):
        date_now = self.start
        while True:
            if date_now > self.end : break
            url = self.url.format(date_now)
            print (url)
            html_table = pandas.read_html(url)
            
            html_table = html_table[1] #當天收盤結果
            html_table.columns = html_table.iloc[0]
            html_table = html_table.drop(0) 
            html_table[u"日期"] = date_now[:4]+'/'+date_now[4:6]+'/'+date_now[-2:] #處理 header
            
            date_now = datetime.datetime.strptime(date_now,'%Y%m%d') + datetime.timedelta(days = 1) #日期+1
            date_now = date_now.strftime('%Y%m%d')
            if len(html_table[html_table[u"開盤"] == u"目前尚未有資料"].index) == 1 :continue #當天休盤
            self.result_df = self.result_df.append(html_table)
            time.sleep(self.crawling_sleep_time)
        self.result_df.to_csv(self.file , sep=',' , mode = 'a+', encoding='utf-8' , index = False , quotechar = "'")
        print('file writed in '+self.file)
            
if __name__ == '__main__':
    cnyes_hsicon = cnyes_crawler('HSICON'
        , start = '20170414'
        , end = '20180107'
        , file = os.path.dirname(os.path.abspath(__file__)) + r'/$product.$date_start.$date_end.csv')
    cnyes_hsicon.cnyes_crawler()
    