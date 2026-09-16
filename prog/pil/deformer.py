from PIL import Image, ImageOps
class Deformer():
    def getmesh(self, img):
        w, h = img.size
        left = ((0,0,w//2,h),(0,0,0,h,w//2,h,w//2,0))
        right = ((w//2,0,w,h),(w//2,0,w//2,h,0,h,0,0))
        flip = ((w//2,0,w,h),(w//2,h,w//2,0,w,0,w,h))
        return [left, right]
image = Image.open('t9.png')
d = ImageOps.deform(image, Deformer())
d.show()
