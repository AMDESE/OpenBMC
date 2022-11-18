
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

#Checking Main Code version_MG9100  ¡õ
################################################################
#echo "########## 2. Start checking Main Code version ##########" >> /tmp/Result.log

#for z in {0..2};
#do
#echo "MG9100 0x6$z ¡õ" >> /tmp/Result.log
#sleep 1
#echo "i2cget -f -y 10 0x6$z 0x61;" >> /tmp/Result.log
#a=$(i2cget -f -y 10 0x6$z 0x61;)
#echo "$a" >> /tmp/Result.log
#sleep 1
#echo "i2cget -f -y 10 0x6$z 0x62;" >> /tmp/Result.log
#b=$(i2cget -f -y 10 0x6$z 0x62;)
#echo "$b" >> /tmp/Result.log#

#if [ "$a" != "0x00" ];then
#echo "FAIL !!!!!!!!!!!!!!!!" >> /tmp/Result.log
#echo "Main code version is not 00m81" >> /tmp/Result.log
#exit 1
#fi

#if [ "$b" != "0x81" ];then
#echo "" >> /tmp/Result.log
#echo "FAIL !!!!!!!!!!!!!!!!" >> /tmp/Result.log
#echo "Main code version is not 00m81" >> /tmp/Result.log
#exit 1
#else
#echo "!!!!! PASS !!!!!" >> /tmp/Result.log
#fi

#echo "" >> /tmp/Result.log

#done


#echo "Main code version of all three MG9100 are 00m81" >> /tmp/Result.log
#echo "########## Finish Main Code version check ##########" >> /tmp/Result.log
################################################################



#echo "" >> /tmp/Result.log
#echo "" >> /tmp/Result.log
#echo "" >> /tmp/Result.log



#Erase and Set software strap, CFRU ¡õ
################################################################
echo "########## 3. Erase and Set software strap, CFRU ##########" >> /tmp/Result.log

echo "i2ctransfer -f -y 10 w4@0x62 0x00 0x91 0x00 0xC9; #Reset MG9100 " >> /tmp/Result.log
i2ctransfer -f -y 10 w4@0x62 0x00 0x91 0x00 0xC9 ; #reset MG9100
sleep 1

echo "i2ctransfer -f -y 10 w8@0x62 0x00 0x91 0x00 0xC7 0x82 0x2C 0x5F 0x9b; #Program SW Strap, Strap MG9100 to U.3 BP  [slot16 to 23]" >> /tmp/Result.log
i2ctransfer -f -y 10 w8@0x62 0x00 0x91 0x00 0xC7 0x82 0x2C 0x5F 0x9b;
#Program SW Strap, Strap MG9100 to U.3 BP  [slot16 to 23]
sleep 1


echo "i2ctransfer -f -y 10 w4@0x62 0x55 0xAA 0x92 0x00; #Erase MG9100-CFRU0  [slot16to23]" >> /tmp/Result.log
i2ctransfer -f -y 10 w4@0x62 0x55 0xAA 0x92 0x00 ; #Erase MG9100-CFRU0  [slot16to23]
sleep 1


echo "i2ctransfer -f -y 10 w22@0x62 0x55 0xAA 0x97 0x0 0x00 0x10 0x03 0x13 0x02 0x12 0x01 0x11 0x00 0x10 0x87 0x17 0x86 0x16 0x85 0x15 0x84 0x14; #CFRU WRITE Command, 1st-16BYTE  [slot16to23]" >> /tmp/Result.log
i2ctransfer -f -y 10 w22@0x62 0x55 0xAA 0x97 0x0 0x00 0x10 0x03 0x13 0x02 0x12 0x01 0x11 0x00 0x10 0x87 0x17 0x86 0x16 0x85 0x15 0x84 0x14; #CFRU WRITE Command, 1st-16BYTE  [slot16to23]
sleep 1

echo "i2ctransfer -f -y 10 w22@0x62 0x55 0xAA 0x97 0x0 0x10 0x10 0x00 0x18 0x00 0x00 0x90 0x00 0x90 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x10; #CFRU WRITE Command, 2nd-16BYTE  [slot16to23]]" >> /tmp/Result.log
i2ctransfer -f -y 10 w22@0x62 0x55 0xAA 0x97 0x0 0x10 0x10 0x00 0x18 0x00 0x00 0x90 0x00 0x90 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x10; #CFRU WRITE Command, 2nd-16BYTE  [slot16to23]
sleep 1


echo "i2ctransfer -f -y 10 w4@0x62 0x00 0x91 0x00 0xC9; #Reset MG9100 " >> /tmp/Result.log
i2ctransfer -f -y 10 w4@0x62 0x00 0x91 0x00 0xC9 ; #reset MG9100
sleep 1


echo "########## Finish Erase software strap and CFRU ##########" >> /tmp/Result.log
################################################################



echo "" >> /tmp/Result.log
echo "" >> /tmp/Result.log
echo "" >> /tmp/Result.log



#Check software strap and CFRU  ¡õ
################################################################
echo "" >> /tmp/Result.log
echo "########## 4. Check software strap and CFRU ##########" >> /tmp/Result.log

echo "i2ctransfer -f -y 10 w4@0x62 0x00 0x91 0x00 0xC9;  #Reset MG9100" >> /tmp/Result.log
i2ctransfer -f -y 10 w4@0x62 0x00 0x91 0x00 0xC9;  #reset MG9100
echo "" >> /tmp/Result.log
sleep 6   # After reset, i2ctransfer -f -y 10 w1@0x62 0x59 r1 will be 0x10 in 5 sec, because MG9100 is still reading device's status

#1
echo "i2ctransfer -f -y 10 w1@0x62 0x59 r1; #check REGISTER 0x59  [slot16to23]" >> /tmp/Result.log
c=$(i2ctransfer -f -y 10 w1@0x62 0x59 r1;)
echo "$c" >> /tmp/Result.log
echo "" >> /tmp/Result.log

if [ "$c" != "0x16" ];then
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

if [ "$f" != "0x5f" ];then
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

if [ "$g" != "0x03 0x13 0x02 0x12 0x01 0x11 0x00 0x10 0x87 0x17 0x86 0x16 0x85 0x15 0x84 0x14" ];then
echo "FAIL !!!!!!!!!!!!!!!!" >> /tmp/Result.log
echo "Fail to set CFRU" >> /tmp/Result.log
exit 1
fi
sleep 1

echo "" >> /tmp/Result.log

#6
echo "i2ctransfer -f -y 10 w6@0x62 0x55 0xAA 0x98 0x0 0x10 0x10 r16; #CFRU Read Command, 2st-16BYTE" >> /tmp/Result.log
h=$(i2ctransfer -f -y 10 w6@0x62 0x55 0xAA 0x98 0x0 0x10 0x10 r16;)
echo "$h" >> /tmp/Result.log

if [ "$h" != "0x00 0x18 0x00 0x00 0x90 0x00 0x90 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x10" ];then
echo "FAIL !!!!!!!!!!!!!!!!" >> /tmp/Result.log
echo "Fail to set CFRU" >> /tmp/Result.log
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
#echo "All three MG9100 are using Main Code 00m81" >> /tmp/Result.log
echo "Soft straps have been removed, CFRU set up correctly" >> /tmp/Result.log
echo "Slot 16 to 23 support only SATA, Slot 0 to 15 are PCIe" >> /tmp/Result.log

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
