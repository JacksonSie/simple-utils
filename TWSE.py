import requests
import pandas
from io import StringIO
import re
import datetime
import dateutil

#台灣證交所 TWSE
#return day所在當月個股dataframe
#symbol ex: 2330
#day ex:20190501

class TWSE:
    #只能輸入
    def __init__(self , symbol , date_start , date_end):
        if (len(re.findall('^\d{6}$',date_start))<=0 
                or len(re.findall('^\d{6}$',date_end))<=0 
                or len(re.findall('^\d{4}$',symbol))<=0):
            raise Exception("時間格式請使用%Y%m(e.g., 201901) ,not %s & %s"%date_start,date_end )
        self._symbol = symbol
        self._date_start = date_start+'01'
        self._date_end = date_end+'01'
        self._date_iter = None
        self.showData = None
        if (self._date_start and self._date_end and self._symbol):
            self.dateperiod_parse()
            self.main()

    def TWSE_OHLC(self) -> pandas.DataFrame:
        if isinstance(self._date_iter , datetime.date) : 
            day = self._date_iter.strftime('%Y%m%d')
        r=requests.post(
            r'https://www.twse.com.tw/exchangeReport/STOCK_DAY?response=csv&date={day}&stockNo={symbol}'.format(
                day=day,symbol=self._symbol)
        )
        if len(r.text.strip())<=0:return
        try :
            df = pandas.read_csv(StringIO(r.text), header=["日期" in l for l in r.text.split("\n")].index(True))
            df = df[df.日期.str.match('^\d{3}/\d{2}/\d{2}')]
            df = df.drop(['Unnamed: 9'],axis=1)
        except (Exception, e):
            print(day)
            print(r.text.split("\n"))
            print(e)
            return null
        return df

    def combine_df(self , df_piece , ignore_index = True) -> None:
        self.showData=pandas.concat([self.showData,df_piece],ignore_index=ignore_index)
    
    def dateperiod_parse(self) -> None :
        self._date_start = datetime.datetime.strptime(self._date_start,'%Y%m%d')
        self._date_end = datetime.datetime.strptime(self._date_end,'%Y%m%d')
        self._date_iter = self._date_start
    
    #每次對 self._date_iter 加一個月
    #若 self._date_iter 超過 self._date_end 則 self._date_end = None
    def date_add(self) -> None :
        self._date_iter = self._date_iter + dateutil.relativedelta.relativedelta(months=1) if self._date_iter < self._date_end else None
        
    def main(self) -> None:
        while(self._date_iter):
            piece_df = self.TWSE_OHLC()
            if (not piece_df.empty) : self.combine_df(piece_df)
            #print(self._date_iter )
            print(self._date_iter, end = '')
            self.date_add()
        return self.showData
    
a = TWSE('2330','201101' , '201302')
a.showData