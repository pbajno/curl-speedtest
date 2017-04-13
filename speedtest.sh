#!/bin/bash
# Licensed under GPLv3
# created by "black" on LET
# please give credit if you plan on using this for your own projects 

fileName="100mb.test";
#check if user wants 100MB files instead
##NOTE: testing with 100MB by default
#ls "FORCE100MBFILESPEEDTEST" 2>/dev/null 1>/dev/null;
#if [ $? -eq 0 ]
#then
#	#echo "Forcing 100MB speed test";
#	fileName="100mb.test";
#	#remove this file after filename variable as been set
#	rm FORCE100MBFILESPEEDTEST;
#fi

##need sed now because some european versions of curl insert a , in the speed results
speedtest () {
	dlspeed=$(echo -n "scale=2; " && curl --connect-timeout 8 http://$1/$fileName -w "%{speed_download}" -o $fileName -s | sed "s/\,/\./g" && echo "/1048576");
	echo "$dlspeed" | bc -q | sed "s/$/ MB\/sec/;s/^/\tDownload Speed\: /";
	ulspeed=$(echo -n "scale=2; " && curl --connect-timeout 8 -F "file=@$fileName" http://$1/webtests/ul.php -w "%{speed_upload}" -s -o /dev/null | sed "s/\,/\./g" && echo "/1048576");
	echo "$ulspeed" | bc -q | sed "s/$/ MB\/sec/;s/^/\tUpload speed\: /";
}

ls "$fileName" 1>/dev/null 2>/dev/null;
if [ $? -eq 0 ]
then
	echo "$fileName already exists, remove it or rename it";
	exit 1;
fi

cputest () {
	cpuName=$(cat /proc/cpuinfo | grep "model name" | cut -d ":" -f2 | tr -s " " | head -n 1);
	cpuCount=$(cat /proc/cpuinfo | grep "model name" | cut -d ":" -f2 | wc -l);
	echo "CPU: $cpuCount x$cpuName";
	echo -n "Time taken to generate PI to 5000 decimal places with a single thread: ";
	(time echo "scale=5000; 4*a(1)" | bc -lq) 2>&1 | grep real |  cut -f2
}

disktest () {
	echo "Writing 1000MB file to disk"
	dd if=/dev/zero of=$$.disktest bs=64k count=16k conv=fdatasync 2>&1 | tail -n 1 | cut -d " " -f3-;
	rm $$.disktest;
}

#check dependencies
metDependencies=1;
#check if curl is installed
type curl 1>/dev/null 2>/dev/null;
if [ $? -ne 0 ]
then
	echo "curl is not installed, install it to continue, typically you can install it by typing"
	echo "apt-get install curl"
	echo "yum install curl"
	echo "depending on your OS";
	metDependencies=0 ;
fi
#check if bc is installed
type bc 1>/dev/null 2>/dev/null;
if [ $? -ne 0 ]
then
	echo "bc is not installed, install it to continue, typically you can install it by typing"
	echo "apt-get install bc"
	echo "yum install bc"
	echo "depending on your OS";
	metDependencies=0;
fi
if [ $metDependencies -eq 0 ]
then
	exit 1;
fi


## start speed test
echo "-------------Speed test--------------------";

echo "Testing North America locations";

### Portland, Oregon, USA (donated by http://bonevm.com)
echo "Speedtest from Portland, Oregon, USA [ generously donated by http://bonevm.com ] on a shared 100 Mbps port";
speedtest 100.42.19.110;


echo -e "\nTesting PL locations";

echo "Rumia";
speedtest "speedtest1.interkar.pl:8080";

echo "Gdynia";
speedtest "speedtest.maxnet.org.pl:8080";

echo "Poznan";
speedtest "speedtest.horyzont.net:8080";

echo "Suwalki";
speedtest "www.lannet.org:8080";

echo "Warszawa";
speedtest "st.home.pl:8080";

echo "Krakow";
speedtest "speedtest.classcom.pl:8080";

echo "Wroclaw";
speedtest "head.tvk.pl:8080";

echo "Szczecin";
speedtest "st1.ltnt.pl:8080";

echo "Lublin";
speedtest "speed.enterpol.pl:8080";


echo -e "\nTesting EU locations";
### Paris, France
echo "Speedtest from Paris, France on a shared 1 Gbps port";
speedtest "4iil8b4g67f03cdecaw9nusv.getipaddr.net";

## Alblasserdam, Netherlands (donated by http://ramnode.com)
echo "Speedtest from Alblasserdam, Netherlands [ generously donated by http://ramnode.com ] on on a shared 1 Gbps port";
speedtest 185.52.0.68;

### Dusseldorf, Germany (donated by http://megavz.com)
echo "Speedtest from Dusseldorf, Germany [ generously donated by http://megavz.com ] on a shared 1 Gbps port";
speedtest 130.255.188.37:7020;

### Falkenstein, Germany (donated by http://megavz.com)
echo "Speedtest from Falkenstein, Germany [ generously donated by http://megavz.com ] on a shared 1 Gbps port";
speedtest 5.9.2.36:12120;

### Bucharest, Romania
echo "Speedtest from Bucharest, Romania [ generously donated by http://www.prometeus.net ] on a semi-dedicated 1 Gbps port";
speedtest "servoni.eu/webtests";

echo -e "\nTesting Asian locations";

### Singapore
echo "Speedtest from Singapore on a shared 1 Gbps port";
speedtest 128.199.65.191;

unlink $fileName;

### Due to expensive bandwidth, use the 10MB test file instead
fileName="10mb.test";

ls "$fileName" 1>/dev/null 2>/dev/null;
if [ $? -eq 0 ]
then
        echo "$fileName already exists, remove it or rename it";
        exit 1;
fi

### Tokyo, Japan
echo "Speedtest from Tokyo, Japan on a shared 1 Gbps port";
speedtest 108.61.200.70:12601;

echo -e "\nTesting Australian locations";

### Sydney, Australia
echo "Speedtest from Sydney, Australia on a shared 1 Gbps port";
speedtest 103.25.58.8:3310;

unlink $fileName;

## start CPU test
echo "---------------CPU test--------------------";
cputest;

## start disk test
echo "----------------IO test-------------------";
disktest;

##hints
echo -e "If you need to speedtest in a specific region:
http://dl.getipaddr.net/speedtest.NA.sh for North America
http://dl.getipaddr.net/speedtest.EU.sh for Europe
http://dl.getipaddr.net/speedtest.Asia.sh for Asia
http://dl.getipaddr.net/speedtest.AU.sh for Australia";

