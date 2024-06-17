monitor = peripheral.find("monitor")

function download_images()
    shell.run("wget https://raw.githubusercontent.com/darthzapp/Minecraft-SGJurney-CC-Dialing-Program/main/sg_idle.nfp sg_idle.nfp")
    print("[info] downloaded sg_idle.nfp ")
end

function draw_image()
    imagepath = "sg_idle.nfp"
    image = paintutils.loadImage(imagepath)
    paintutils.drawImage(image,1,1)
end

download_images()
draw_image()
