green = '\033[3;32m'
Red = '\033[3;31m'
white = '\033[0m'

import os
import signal
import getpass
import stdiomask
import time

print("")
print(Red + "MASTER CHEEF" + white, end=' ')
print("Please Enter Your Pass", end=' ')
print(Red + "!!!" + white)
print("")

PASSWORD = stdiomask.getpass()
if PASSWORD == "?":
    print("")
    print(green + "WELCOME CHEEF" + white)
    print("")
else:
    if (PASSWORD != "?"):
        print("")
        print(Red + "Access Denied")
        time.sleep(1.0)
        os.kill(os.getppid(), signal.SIGHUP)
