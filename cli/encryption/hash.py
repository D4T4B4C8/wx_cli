import hashlib
hv = input("Enter a string to hash: ")
h1 = hashlib.md5()
h1.update(hv.encode())
print(h1.hexdigest())
#MD5
h2 = hashlib.sha1()
h2.update(hv.encode())
print(h2.hexdigest())
#SHA1
h3 = hashlib.sha224()
h3.update(hv.encode())
print(h3.hexdigest())
#SHA224
h4 = hashlib.sha256()
h4.update(hv.encode())
print(h4.hexdigest())
#SHA256
h5 = hashlib.sha512()
h5.update(hv.encode())
print(h5.hexdigest())
#SHA512
