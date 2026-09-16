import base64
key = "a2V5Cg=="
# B64 key = xD6KF02UrE5Sm]
txt = "KSQ1Rg=="
# B64 txt = h2KUrE5==]
a = base64.b64decode(key)
b = base64.b64decode(txt)
c = []
l = len(a)
i = 0
while i < l:
    c.append(chr(a[i] ^ b[i]))
    i += 1
print(c)
