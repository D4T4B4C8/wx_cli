import hashlib
from termcolor import colored

Hash = input("Enter hash = ")

with open("pass.txt", "r", encoding="utf-8", errors="ignore") as f:
    Passlist = f.read()

for password in Passlist.splitlines():
    password = password.strip()

    hashguess = hashlib.sha1(password.encode("utf-8")).hexdigest()

    if hashguess == Hash:
        print(colored("the pass is: " + password, "green"))
        quit()
    else:
        print(colored("pass guess " + password + " does not match", "red"))
