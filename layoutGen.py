#!/usr/bin/python
#-*- coding:utf-8 -*-
#argv[1] 是想要的欄位 (英文)
#argv[2] 是整個 dw 的src 文件
import sys
tabsequence = 0
count=0
'''
Rowdata[0] = col 
Rowdata[1] = col_t'
'''
class readArgv1:
	with open(sys.argv[1],mode = 'r',newline='\r\n',encoding='utf-8',errors='ignore') as reading:
		for line in reading:
			Rowdata = line.strip().split('\r\n')
			if len(Rowdata) != 1:
				print ('error in line:\t'+str(Rowdata[0])+',\tlen(line)'+str(len(Rowdata))+'-->\t長度不足 or Bad EOF')
				exit()

			Rowdata.insert(1,Rowdata[0]+'_t')
			tabsequence = tabsequence + 10

			#print(Rowdata[0] ,Rowdata[1]  ,tabsequence )

			'''
			print ('column(name='+col_name,'id='+str(obj_id)+'','tabsequence='+str(tabsequence)+'','x="'+str(x)+'"','width="'+str(width)+'"','band=detail alignment="2" border="0" color="33554432" y="8" height="88" format="[general]" html.valueishtml="0"  visible="1" edit.limit=3 edit.case=any edit.focusrectangle=no edit.autoselect=yes edit.autohscroll=yes  font.face="Tahoma" font.height="-12" font.weight="400"  font.family="2" font.pitch="2" font.charset="0" background.mode="1" background.color="536870912" background.transparency="0" background.gradient.color="8421504" background.gradient.transparency="0" background.gradient.angle="0" background.brushmode="0" background.gradient.repetition.mode="0" background.gradient.repetition.count="0" background.gradient.repetition.length="100" background.gradient.focus="0" background.gradient.scale="100" background.gradient.spread="100" tooltip.backcolor="134217752" tooltip.delay.initial="0" tooltip.delay.visible="32000" tooltip.enabled="0" tooltip.hasclosebutton="0" tooltip.icon="0" tooltip.isbubble="0" tooltip.maxwidth="0" tooltip.textcolor="134217751" tooltip.transparency="0" transparency="0")',sep=" ")
			print('text(x="'+str(x)+'"','text="'+text+'"','name='+text_name+'','width="'+str(width)+'"','band=header alignment="2" border="0" color="33554432" y="8" height="76" html.valueishtml="0"  visible="1"  font.face="Tahoma" font.height="-12" font.weight="400"  font.family="2" font.pitch="2" font.charset="0" background.mode="1" background.color="536870912" background.transparency="0" background.gradient.color="8421504" background.gradient.transparency="0" background.gradient.angle="0" background.brushmode="0" background.gradient.repetition.mode="0" background.gradient.repetition.count="0" background.gradient.repetition.length="100" background.gradient.focus="0" background.gradient.scale="100" background.gradient.spread="100" tooltip.backcolor="134217752" tooltip.delay.initial="0" tooltip.delay.visible="32000" tooltip.enabled="0" tooltip.hasclosebutton="0" tooltip.icon="0" tooltip.isbubble="0" tooltip.maxwidth="0" tooltip.textcolor="134217751" tooltip.transparency="0" transparency="0")',sep=" ") '''
'''
def zh2unicode(stri):
	Auto converter encodings to unicode
	It will test utf8,gbk,big5,jp,kr to converter	


	for c in ('utf-8', 'gbk', 'big5', 'jp', 'euc_kr','utf16','utf32'):
		try:
			return stri.decode(c)
		except:
			pass
			print("GG")
			return stri
'''

class readArgv2:
	with open(sys.argv[2],mode = 'r',newline='\r\n',encoding='utf-8',errors='ignore') as reading:
		for count,line in reading:
			Rowdata = line.strip().split('\s')