#!/bin/sh
# ln -s Crashlytics_ios.framework Crashlytics.framework
# ln -s Fabric_ios.framework Fabric.framework
#carthage update --platform iOS
cd Carthage/Build/iOS/
list="Alamofire
SystemKitiOS
IoniconsSwift
Charts
SwiftyStoreKit
Reachability
MMDB
Charts
SwiftyStoreKit
GRDB
DarwinCore
ObjectMapper
IDZSwiftCommonCrypto
SFSocket
Sodium
CocoaAsyncSocket
AxLogger
kcp
snappy
SwiftyJSON
Crypto
CommonCrypto
XFoundation
XRuler
XProxy
Xsocket
Xcon
lwip"

for line in $list
#cat ff.txt |while read line
do
	echo $line
lipo  -remove i386   $line.framework/$line  -output  $line.framework/$line 
lipo  -remove x86_64  $line.framework/$line   -output  $line.framework/$line 
file  $line.framework/$line 
done
