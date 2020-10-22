library(quantmod)
library(lubridate)
tw_future_4306 <- 'C:\\Users\\sie\\Desktop\\test\\tw_future_4306.csv'
backTestingStartTime <- '' #回測開始時間,不寫就是第一筆資料開始,'%Y%m%d %H:%M:%S'
backTestingEndTime <- '' #回測結束時間,不寫就是到最後一筆資料結束,'%Y%m%d %H:%M:%S'
#chanceMessage <- 2 #每次訊號出來買幾口,反手 covering 相同
underboundFirstMessage <- 20 #第一口守點樓地板
upperboundSecondMessage <- 50 #第二口目標天花板
upperboundPerday <- 50 #總獲利天花板
fee <- 0 #2 #手續費一趟%數換算約2點
profit <- matrix( , nrow <- 0 ,ncol <- 9)
colnames(profit) <-c("最高點","最低點","買進日期","預測多空(1多/0/-1空)","損益1","是否反手","反手時間","損益2","總損益")
init <- function(csvInput){
  sourceFromCSV <- read.csv(csvInput, header = TRUE)
  time_rownames <- strptime(paste(sourceFromCSV[,1]),'%Y/%m/%d %H:%M')
  sourceFromCSV <- as.xts(sourceFromCSV[,-1], time_rownames)
  dataStart <- strptime( min(time_rownames) ,format = '%Y-%m-%d %H:%M:%S')
  dataEnd <- strptime( max(time_rownames) ,format = '%Y-%m-%d %H:%M:%S')
  if (backTestingStartTime != ''){
    manualStart <- strptime( backTestingStartTime ,format = '%Y%m%d %H:%M:%S')
    if(manualStart > dataStart) backTestingStartTime <- manualStart else backTestingStartTime <- dataStart
  } else backTestingStartTime <- dataStart
  if (backTestingEndTime != ''){
    manualEnd <- strptime( backTestingEndTime ,format = '%Y%m%d %H:%M:%S')
    if(manualEnd < dataEnd) backTestingEndTime <- manualEnd else backTestingEndTime <- dataEnd
  } else backTestingEndTime <- dataEnd
  assign("tw_future_4306",window(sourceFromCSV , start = backTestingStartTime , end = backTestingEndTime), envir = .GlobalEnv) #使用時記得將每次的標的更改為一開始的 csv file path
  #assign("backTestingStartTime",backTestingStartTime , envir = .GlobalEnv )
  #assign("backTestingEndTime",backTestingEndTime , envir = .GlobalEnv )
}
strategyReversion0 <- function (){
}
init(tw_future_4306)
######################################################################################
strategyVectorTime <- 4 # 判斷區間,bar count
dailyTick <- index(to.daily(tw_future_4306))
for (day_iter in 1:length(dailyTick)){
  #下錯點位暫不考慮
  price_silde <- 0 #round(runif(1, -2.0 , 2.0)) #滑價 -2~2 點
  startPerDay = dailyTick[day_iter] #今日開始時間
  endPerDay = dailyTick[day_iter] + hours(23) #今日結束時間
  WhenStrategyVector <- '' #進場時間
  approach <- '' #進場點
  stopLoss <- '' #停損點
  appearance_1 <- '' #第一出場點
  appearance_2 <- '' #第二出場點
  profit_1 <- 0 #第一損益
  profit_2 <- 0 #第二損益
  profit_total <- #總損益
    fromNowOn_highest <- 0 #本日目前為止最高
  fromNowOn_lowest <- 9999999 #本日目前為止最低
  exit_flag <- FALSE #是否不再進場
  covering_flag <- FALSE #是否反手
  covering_time <- '' #反手時間
  tmp = window(tw_future_4306, start = startPerDay ,end = endPerDay) #今日盤勢
  highest <- max(Hi(tmp[c(1:strategyVectorTime)])) #highest = Hi(to.period(tmp, "minutes", k = strategyVectorTime)[1])
  lowest <- min(Lo(tmp[c(1:strategyVectorTime)])) #lowest = Lo(to.period(tmp, "minutes", k = strategyVectorTime)[1])
  fromNowOn_highest <- highest
  fromNowOn_lowest <- lowest
  realTick <- index(tmp)
  strategyVector <- 0 # long 1 , short -1 , keepout 0
  for (tickNow in seq(from <- strategyVectorTime + 1 , to <- length(realTick))){ #前N個 TICK 被用掉了,從 n+1 開始判斷進場
    if(exit_flag) next
    fromNowOn_highest <- if(as.integer(Hi(tmp[realTick[tickNow]])) > fromNowOn_highest) as.integer(Hi(tmp[realTick[tickNow]])) else fromNowOn_highest
    fromNowOn_lowest <- if(as.integer(Lo(tmp[realTick[tickNow]])) < fromNowOn_highest) as.integer(Lo(tmp[realTick[tickNow]])) else fromNowOn_lowest
    if (strategyVector == 0 ){ #判斷做多空、進場點、守點
      if(as.integer(Hi(tmp[realTick[tickNow]])) >= highest){
        strategyVector<- 1
        approach <- highest + price_silde
        stopLoss <- lowest
        appearance_1 <- ifelse(approach + abs(approach - stopLoss)*strategyVector > underboundFirstMessage , approach + abs(approach - stopLoss)*strategyVector , underboundFirstMessage )
        appearance_2 <- ifelse(approach + abs(approach - stopLoss)*strategyVector > upperboundSecondMessage , approach + abs(approach - stopLoss)*strategyVector , upperboundSecondMessage )
        WhenStrategyVector <- realTick[tickNow]
        
        approach <- approach + price_silde #上方進出場目標都是理想值，最終考慮進滑價(實際值)
} else if(as.integer(Lo(tmp[tickNow])) <= lowest){
strategyVector<- -1
approach <- lowest
stopLoss <- highest
appearance_1 <- ifelse(approach + abs(approach - stopLoss)*strategyVector > underboundFirstMessage , approach + abs(approach - stopLoss)*strategyVector , underboundFirstMessage )
appearance_2 <- ifelse(approach + abs(approach - stopLoss)*strategyVector > upperboundSecondMessage , approach + abs(approach - stopLoss)*strategyVector , upperboundSecondMessage )
WhenStrategyVector <- realTick[tickNow]
approach <- approach + price_silde #上方進出場目標都是理想值，最終考慮進滑價(實際值)
}
next #判斷完後直接進入下個時段
}
if (strategyVector == 1) { #做多的情境
#獲利1出場，包含第一次尾盤平倉
if (as.integer(Hi(tmp[realTick[tickNow]]))>=appearance_1 && profit_1 == 0){#獲利1
profit_1 <- (appearance_1 - approach)*1*strategyVector + price_silde
next
}else if(tickNow == length(realTick) &&  profit_1 == 0){ #第一次尾盤平倉
profit_1 <- (as.integer(Cl(tmp[realTick[tickNow]])) - approach)*1*strategyVector + price_silde
profit_2 <- profit_1
exit_flag <- TRUE
}
#獲利2出場，包含超過每日停利上限，一起出場，包含第二次尾盤平倉、反手平倉
if (as.integer(Hi(tmp[realTick[tickNow]]))>=appearance_2 && profit_1 != 0 && profit_2 == 0){#獲利2
profit_2 <- (appearance_2 - approach)*1*strategyVector + price_silde
exit_flag <- TRUE
}else if (as.integer(Hi(tmp[realTick[tickNow]]))>=appearance_1 && abs(appearance_1 - approach) >= upperboundSecondMessage){ #每日停利上限
profit_1 <- (appearance_1 - approach)*1*strategyVector + price_silde
profit_2 <- profit_1
exit_flag <- TRUE
}else if(tickNow == length(realTick) && profit_1 != 0  &&  profit_2 == 0){ #第二次尾盤平倉、反手平倉
profit_2 <- (as.integer(Cl(tmp[realTick[tickNow]])) - approach)*1*strategyVector + price_silde
exit_flag <- TRUE
}
#停損反手->空方
if (as.integer(Lo(tmp[realTick[tickNow]]))<=stopLoss && profit_1 == 0 ){
covering_flag <- TRUE
covering_time <- realTick[tickNow]
profit_1 <- (stopLoss - approach)*2*strategyVector + price_silde
strategyVector<- -1
approach <- stopLoss
stopLoss <- fromNowOn_highest
appearance_2 <- approach + profit_1*2 * strategyVector  #反手目的為停損
approach <- approach + price_silde #上方進出場目標都是理想值，最終考慮進滑價(實際值)
}
#反守做多停損(雙巴)
if(as.integer(Lo(tmp[realTick[tickNow]])) <= stopLoss && profit_1 != 0){
profit_2 <- (stopLoss - approach)*2*strategyVector + price_silde
exit_flag <- TRUE
}
#反守做多停利(平盤)
if(as.integer(Lo(tmp[realTick[tickNow]])) >= appearance_2 && profit_1 != 0){
profit_2 <- (appearance_2 - approach)*2*strategyVector + price_silde
exit_flag <- TRUE
}
}
if (strategyVector == -1) { #做空的情境
#獲利1出場，包含第一次尾盤平倉
if (as.integer(Lo(tmp[realTick[tickNow]]))<=appearance_1 && profit_1 == 0){#獲利1
profit_1 <- (appearance_1 - approach)*1*strategyVector + price_silde
next
}else if(tickNow == length(realTick) &&  profit_1 == 0){ #第一次尾盤平倉
profit_1 <- (as.integer(Cl(tmp[realTick[tickNow]])) - approach)*1*strategyVector + price_silde
profit_2 <- profit_1
exit_flag <- TRUE
}
#獲利2出場，包含超過每日停利上限，一起出場，包含第二次尾盤平倉、反手平倉
if (as.integer(Lo(tmp[realTick[tickNow]]))<=appearance_2 && profit_1 != 0){#獲利2
profit_2 <- (appearance_2 - approach)*1*strategyVector + price_silde
exit_flag <- TRUE
}else if (as.integer(Lo(tmp[realTick[tickNow]]))<=appearance_1 && abs(appearance_1 - approach) >= upperboundSecondMessage){ #每日停利上限
profit_1 <- (appearance_1 - approach)*1*strategyVector + price_silde
profit_2 <- profit_1
exit_flag <- TRUE
}else if(tickNow == length(realTick) && profit_1 != 0 ){ #第二次尾盤平倉、反手平倉
profit_2 <- (as.integer(Cl(tmp[realTick[tickNow]])) - approach)*1*strategyVector + price_silde
exit_flag <- TRUE
}
#停損反手 -> 多方
if (as.integer(Hi(tmp[realTick[tickNow]]))>=stopLoss && profit_1 == 0 ){
covering_flag <- TRUE
covering_time <- realTick[tickNow]
profit_1 <- (stopLoss - approach)*2*strategyVector + price_silde
strategyVector<- 1
approach <- stopLoss
stopLoss <- fromNowOn_lowest
appearance_2 <- approach + profit_1*2 * strategyVector  #反手目的為停損
approach <- approach + price_silde #上方進出場目標都是理想值，最終考慮進滑價(實際值)
}
#反守做空停損(雙巴)
if(as.integer(Hi(tmp[realTick[tickNow]])) >= stopLoss && profit_1 != 0){
profit_2 <- (stopLoss - approach)*2*strategyVector + price_silde
exit_flag <- TRUE
}
#反守做空停利(平盤)
if(as.integer(Lo(tmp[realTick[tickNow]])) >= appearance_2 && profit_1 != 0){
profit_2 <- (appearance_2 - approach)*2*strategyVector + price_silde
exit_flag <- TRUE
}
}
}
#結算當天獲利點數，合併扣除手續$
profit_total <- profit_1 + profit_2 - fee
profit_tmp<-matrix(c(highest , lowest ,as.character(WhenStrategyVector) ,strategyVector, profit_1 , covering_flag , as.character(covering_time) , profit_2 , profit_total) , ncol=9)
colnames(profit_tmp) <-c("最高點","最低點","買進日期","預測多空(1多/0/-1空)","損益1","是否反手","反手時間","損益2","總損益")
rownames(profit_tmp) <- as.character(startPerDay)
profit_tmp <- as.table(profit_tmp)
profit <- rbind(profit_tmp,profit)
print(c(as.character(startPerDay), 'OK!'))
}
View(profit)
