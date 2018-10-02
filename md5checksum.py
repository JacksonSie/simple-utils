import sys
import hashlib
 
def md5(fileName):
    """Compute md5 hash of the specified file"""
    m = hashlib.md5()
    try:
        fd = open(fileName,"rb")
    except IOError:
        print ("Reading file has problem:", filename)
        return
    x = fd.read()
    fd.close()
    m.update(x)
    return m.hexdigest()
 
if __name__ == "__main__":
    for eachFile in sys.argv[1:]:
        print ("%s" % md5(eachFile))