# Computercraft Program For The Stargate Journey Minecraft Mod

## scripts:

**V1**:<br />

``` wget https://raw.githubusercontent.com/darthzapp/Minecraft-SGJurney-CC-Dialing-Program/main/dialingprogram_v1.lua startup ```
<br />
<br />
**V2** (experimental): 
<br />
```wget https://raw.githubusercontent.com/darthzapp/Minecraft-SGJurney-CC-Dialing-Program/main/dialingprogram_v2.lua startup``` 
<br /> 
<br />
**V2.1**: 
<br />
 ```wget https://raw.githubusercontent.com/darthzapp/Minecraft-SGJurney-CC-Dialing-Program/main/dialingprogram_v2_1.lua startup``` 
<br /> 
<br />
<br />
**V2.2**(BETA) bugs can occur: 
<br />
```wget https://raw.githubusercontent.com/darthzapp/Minecraft-SGJurney-CC-Dialing-Program/main/dialingprogram_v2_2.lua startup``` 





<br /><br /><br /><br /><br />
# **How to use:** 
<br /><br />
## **Example Button Layout:** <br /> <sub>*updated for v2.2*</sub>
>[!IMPORTANT]
> 1. *connect the* **Stargate crystal interface** *or* **advanced interface** *with a modem to your computer* 
>
> 2. *a bundled cable from* **ProjectRed Transmission** *is required to be connected to the back of the computer*
>
> 3. *for IRIS control connect a transciver with a modem to the computer network*





Levers:

    |¯¯¯¯¯¯¯¯|
    |  red   | = Address Editing
    |________|

    |¯¯¯¯¯¯¯¯|
    | gray   | = Iris Editing
    |________|


Buttons:

                    |   [lime]   |   [white]   |    [red]    |   [black]   |   [pink]   |
    -----           |    dial    |    back     |    reset    |    next     |    iris    |
    Address Editing |   add new  |    back     |    delete   |    next     |  iris list |
    iris Editing    | local iris |    back     | remote iris |    next     |    iris    |

  local iris  = change local iris frequency and code
  remote iris = change the frequency and code of a remote stargate (these will send automaticly after conecting to it)
  iris list   = this will olen the local iris if dialed in by this address
  
<br /><br /><br /><br /><br /><br />
## **Versions:** 
new addresses need to be written directly into the computer in all versions
<br />
<br />
### **V1:** *(supports a monitor)* 
the dialingprogram_v1.lua uses a floppydisc per address to stimely use it with redstone buttons <br />
Redstone from the top start the dialing. <br />
Redstone from the bottom rewites the floppydisc. <br />
<br />
<br />
### **V2:** *(does not support a monitor)*
Redstone from the top start the dialing. <br />
left counts down right counts up. <br />
front sets first address. <br />
Redstone from the bottom enables the editing mode. <br />
*Editing Mode:* <br />
left adds new address <br />
right deletes the current chosen address <br />

### **V2.1:** *(supports a monitor)*
Conect a bundled cable from project red transmission from behind<br />
*Channals:* <br />
White: back <br />
Black: next <br />
Red: reset [MODE]: delete the current address <br />
Lime: dial / disconnect [MODE]: add a new address <br />
The mode gets activated with a lever on the blue chanal<br />

### **V2.2:** *(supports an iris)*
*added automatic iris closing and opening*<br />
*added automatic iris code sending*<br />
to toggle the iris set a redstonesignal to the pink channal<br />
a switch at the gray channal enters a IRIS editing mode


