#!/bin/sh

VCSHOME="${VCS_HOME:-/opt/VRTSvcs}"
ro=`${VCSHOME}/bin/haclus -value ReadOnly`
if [ $ro -eq 1 ];
then
	${VCSHOME}/bin/haconf -makerw
fi
${VCSHOME}/bin/hatype -add infinidat
#${VCSHOME}/bin/hatype -modify infinidat SupportedActions PreSwitch ReportRPOData StartWriter GetCurrentRPO StartRPOComputation StopRPOComputation
${VCSHOME}/bin/hatype -modify infinidat ArgList localbox UserLocal PasswordLocal remotebox UserRemote PasswordRemote LocalCG RemoteCG
${VCSHOME}/bin/hatype -modify infinidat OpenTimeout 180
${VCSHOME}/bin/hatype -modify infinidat OnlineTimeout 700
${VCSHOME}/bin/hatype -modify infinidat RestartLimit 1
${VCSHOME}/bin/haattr -add infinidat localbox -string
${VCSHOME}/bin/haattr -add infinidat UserLocal -string
${VCSHOME}/bin/haattr -add infinidat PasswordLocal -string
${VCSHOME}/bin/haattr -add infinidat remotebox -string
${VCSHOME}/bin/haattr -add infinidat UserRemote -string
${VCSHOME}/bin/haattr -add infinidat PasswordRemote -string
${VCSHOME}/bin/haattr -add infinidat LocalCG -string 
${VCSHOME}/bin/haattr -add infinidat RemoteCG -string 
#${VCSHOME}/bin/hatype -modify infinidat RegList ComputeDRSLA
mkdir -p $VCSHOME/bin/infinidat
ln -s /opt/VRTSvcs/bin/Script50Agent /opt/VRTSvcs/bin/infinidat/infinidat
ln -s /opt/VRTSvcs/bin/Script50Agent /opt/VRTSvcs/bin/infinidat/infinidatAgent
cp ../Linux/online $VCSHOME/bin/infinidat
cp ../Linux/offline $VCSHOME/bin/infinidat
cp ../Linux/monitor $VCSHOME/bin/infinidat
cp ../Linux/clean $VCSHOME/bin/infinidat
cp ../Linux/open $VCSHOME/bin/infinidat
cp ../Linux/close $VCSHOME/bin/infinidat
cp ../Linux/infinidat.pm $VCSHOME/bin/infinidat
cp *.xml $VCSHOME/bin/infinidat
chmod 744 $VCSHOME/bin/infinidat
cp ../Linux/*.cf  /etc/VRTSvcs/conf/


if [ $ro -eq 1 ];
then
	${VCSHOME}/bin/haconf -dump -makero
else
	${VCSHOME}/bin/haconf -dump
fi
PERL="/opt/VRTSperl/bin/perl"
MAKE="/usr/bin/make"
cp REST-Client-273.tar.gz /tmp/
cp Module-Install-1.18.tar.gz /tmp
cd /tmp
tar xvzf REST-Client-273.tar.gz
tar xvzf Module-Install-1.18.tar.gz 
cd Module-Install-1.18
$PERL Makefile.PL
$MAKE
$MAKE install
cd /tmp/REST-Client-273
cd REST-Client-273.tar.gz
$PERL Makefile.PL
$MAKE
$MAKE install
cd /tmp/
rm -rf REST-Client-273 
rm -rf Module-Install-1.18
