monitor = peripheral.find("monitor")

function draw_image()
    imagepath = "sg_idle.nfp"
    image = paintutils.loadImage(imagepath)
    paintutils.drawImage(image,1,1)
end

draw_image()
