import qrcode

address = input("Menu address (example http://192.168.220.33:5000/m): ").strip()
image = qrcode.make(address)
image.save("menu_qr.png")
print("Saved menu_qr.png in this folder")