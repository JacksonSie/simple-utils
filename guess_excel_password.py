#python3
#此檔案可用來猜測excel的密碼
#TODO:
#   multi thread
#   process bar(speed = num/sec,100%,stdout & flush guess word)

import sys , string , itertools , datetime
import win32com.client

letters=3
openedDoc = win32com.client.Dispatch("Excel.Application")
filename= sys.argv[1]
def main():
    results = open('results.txt', 'w')
    source = string.ascii_letters[:] + string.digits
    for i in range(1,letters+1):
        print('(%s) letter length:%s'%(datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S'),i))
        for xs in itertools.product(source,repeat = i):
            password = ''.join(xs)
            try:
                wb = openedDoc.Workbooks.Open(filename, False, True, None, password)
                print("Success! Password is: "+password)
                results.write(password)
                results.close()
                return
            except:
                #print("Incorrect password")
                pass

if __name__ == '__main__':
    main()