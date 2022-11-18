
#for i in {1..10000};
for i in {1};
do
echo "----------------------------------------------------------" >> /tmp/Result.log
#echo "Loop $i" >> /tmp/Result.log


#Switching MUX_U284 ¡õ
################################################################
echo "########## 1. Switching MUX_U284 to channel_3 ##########" >> /tmp/Result.log
echo "i2cset -f -y 10 0x75 0x08" >> /tmp/Result.log

i2cset -f -y 10 0x75 0x08;
x=$(i2cget -f -y 10 0x60 0x00;)   #Reading MG9100, if read fail, not value will be returned

if [ "$x" != "0x00" ];then
echo "" >> /tmp/Result.log
echo "FAIL to switch MUX" >> /tmp/Result.log
exit 1
else
echo "MUX_U284 has been switch to channel_3 correctly" >> /tmp/Result.log
fi

echo "" >> /tmp/Result.log
echo "########## Finish switching MUX ##########" >> /tmp/Result.log
################################################################

echo "" >> /tmp/Result.log
echo "" >> /tmp/Result.log
echo "" >> /tmp/Result.log


#Restore to HW Strap and Built-in UBM-FRU Settings ¡õ
################################################################
echo "########## 3. Restore to HW Strap and Built-in UBM-FRU Settings ##########" >> /tmp/Result.log

echo "i2ctransfer -f -y 10 w4@0x62 0x00 0x91 0x00 0xC9; #Reset MG9100 " >> /tmp/Result.log
i2ctransfer -f -y 10 w4@0x62 0x00 0x91 0x00 0xC9 ; #reset MG9100
sleep 1

echo "i2ctransfer -f -y 10 w4@0x62 0x00 0x91 0x00 0xC2 ; #Erase SW Strap and go back to use HW strap  [slot16to23]" >> /tmp/Result.log
i2ctransfer -f -y 10 w4@0x62 0x00 0x91 0x00 0xC2;
#Erase SW Strap and go back to use HW strap  [slot16to23]
sleep 1


echo "i2ctransfer -f -y 10 w4@0x62 0x55 0xAA 0x92 0x00; #ERASE Custom UBM FRU, CFRU0  [slot16to23]" >> /tmp/Result.log
i2ctransfer -f -y 10 w4@0x62 0x55 0xAA 0x92 0x00 ; #ERASE Custom UBM FRU, CFRU0  [slot16to23]
sleep 1


echo "########## Finish Erase software strap and CFRU ##########" >> /tmp/Result.log
################################################################



echo "" >> /tmp/Result.log
echo "" >> /tmp/Result.log
echo "" >> /tmp/Result.log



#Check Status: Hardware Strap + built-in UBM FRU ¡õ
################################################################
echo "" >> /tmp/Result.log
echo "########## 4. Check Status: Hardware Strap + built-in UBM FRU ##########" >> /tmp/Result.log

echo "i2ctransfer -f -y 10 w4@0x62 0x00 0x91 0x00 0xC9;  #Reset MG9100" >> /tmp/Result.log
i2ctransfer -f -y 10 w4@0x62 0x00 0x91 0x00 0xC9;  #reset MG9100
echo "" >> /tmp/Result.log
sleep 6   # After reset, i2ctransfer -f -y 10 w1@0x62 0x59 r1 will be 0x10 in 5 sec, because MG9100 is still reading device's status

#1
echo "i2ctransfer -f -y 10 w1@0x62 0x59 r1; #Check REGISTER 0x59" >> /tmp/Result.log
c=$(i2ctransfer -f -y 10 w1@0x62 0x59 r1;)
echo "$c" >> /tmp/Result.log
echo "" >> /tmp/Result.log

if [ "$c" != "0x02" ];then
echo "FAIL !!!!!!!!!!!!!!!!" >> /tmp/Result.log
echo "Fail to set soft strap" >> /tmp/Result.log
exit 1
fi
sleep 1


#2
echo "i2ctransfer -f -y 10 w2@0x62 0x5C 0; #Check Current Strap Status, REG0x5C, select byte0" >> /tmp/Result.log
echo "i2ctransfer -f -y 10 w1@0x62 0x5C r1; #Check Current Strap Status, REG0x5C" >> /tmp/Result.log
i2ctransfer -f -y 10 w2@0x62 0x5C 0;
d=$(i2ctransfer -f -y 10 w1@0x62 0x5C r1;)
echo "$d" >> /tmp/Result.log
echo "" >> /tmp/Result.log

if [ "$d" != "0x82" ];then
echo "FAIL !!!!!!!!!!!!!!!!" >> /tmp/Result.log
echo "Fail to set soft strap" >> /tmp/Result.log
exit 1
fi
sleep 1


#3
echo "i2ctransfer -f -y 10 w2@0x62 0x5C 1; #Check Current Strap Status, REG0x5C, select byte1" >> /tmp/Result.log
echo "i2ctransfer -f -y 10 w1@0x62 0x5C r1; #Check Current Strap Status, REG0x5C" >> /tmp/Result.log
i2ctransfer -f -y 10 w2@0x62 0x5C 1;
e=$(i2ctransfer -f -y 10 w1@0x62 0x5C r1;)
echo "$e" >> /tmp/Result.log
echo "" >> /tmp/Result.log
if [ "$e" != "0x2e" ];then
echo "FAIL !!!!!!!!!!!!!!!!" >> /tmp/Result.log
echo "Fail to set soft strap" >> /tmp/Result.log
exit 1
fi
sleep 1


#4
echo "i2ctransfer -f -y 10 w2@0x62 0x5C 2; #check Current Strap Status, REG0x5C, select byte2" >> /tmp/Result.log
echo "i2ctransfer -f -y 10 w1@0x62 0x5C r1; #check Current Strap Status, REG0x5C" >> /tmp/Result.log
i2ctransfer -f -y 10 w2@0x62 0x5C 2;
f=$(i2ctransfer -f -y 10 w1@0x62 0x5C r1;)
echo "$f" >> /tmp/Result.log

if [ "$f" != "0xdf" ];then
echo "FAIL !!!!!!!!!!!!!!!!" >> /tmp/Result.log
echo "Fail to set soft strap" >> /tmp/Result.log
exit 1
fi
sleep 1

echo "" >> /tmp/Result.log



#5
echo "i2ctransfer -f -y 10  w6@0x62 0x55 0xAA 0x98 0x0 0x00 0x10 r16; #CFRU Read Command, 1st-16BYTE" >> /tmp/Result.log
g=$(i2ctransfer -f -y 10  w6@0x62 0x55 0xAA 0x98 0x0 0x00 0x10 r16;)
echo "$g" >> /tmp/Result.log

if [ "$g" != "0xff 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0xff" ];then
echo "FAIL !!!!!!!!!!!!!!!!" >> /tmp/Result.log
echo "Fail to erase CFRU" >> /tmp/Result.log
exit 1
fi
sleep 1

echo "" >> /tmp/Result.log


#6
echo "i2ctransfer -f -y 10 w6@0x62 0x55 0xAA 0x98 0x0 0x10 0x10 r16; #CFRU Read Command, 2st-16BYTE" >> /tmp/Result.log
h=$(i2ctransfer -f -y 10 w6@0x62 0x55 0xAA 0x98 0x0 0x10 0x10 r16;)
echo "$h" >> /tmp/Result.log

if [ "$h" != "0xff 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0xff" ];then
echo "FAIL !!!!!!!!!!!!!!!!" >> /tmp/Result.log
echo "Fail to erase CFRU" >> /tmp/Result.log
exit 1
fi
sleep 1



echo "########## Finish checking software strap and CFRU ##########" >> /tmp/Result.log
################################################################



echo "" >> /tmp/Result.log
echo "" >> /tmp/Result.log
echo "" >> /tmp/Result.log



echo "################################################################################" >> /tmp/Result.log
echo "################################################################################" >> /tmp/Result.log
echo "" >> /tmp/Result.log
echo "Soft straps have been removed, CFRU set up correctly" >> /tmp/Result.log
echo "All slots have been set to PCIe (Including slot 16 ~ 23)" >> /tmp/Result.log
echo "Please execute DC cycle" >> /tmp/Result.log

echo "" >> /tmp/Result.log
echo "!!!!!!!!!! PASS !!!!!!!!!!!" >> /tmp/Result.log
echo "" >> /tmp/Result.log
echo "################################################################################" >> /tmp/Result.log
echo "################################################################################" >> /tmp/Result.log


echo "" >> /tmp/Result.log
echo "" >> /tmp/Result.log
echo "" >> /tmp/Result.log           #lOG¸Ì­±´«¦æ


echo "----------------------------------------------------------" >> /tmp/Result.log

#i2cset -f -y 10 0x75 0x00;    #Turn off MUX_U284

done
