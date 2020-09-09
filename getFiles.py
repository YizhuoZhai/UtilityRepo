# get file name of specific suffix
import sys
import os.path
file_abs = ""
def getFiles(dir_name):
    for dirpath, dirnames, filenames in os.walk(dir_name):    
        for filename in filenames:        
            if os.path.splitext(filename)[1] == ".bc":            
                module = os.path.join(dirpath, filename)            
                with open(file_abs, "a") as f:                
                    f.write(module)                
                    f.write("\n")

if __name__ == "__main__": 
    getFiles(sys.argv[1])
