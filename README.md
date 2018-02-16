# Surf project memo #

Just a Network extension framework Project 

### Frameworks ###
* Used open source project
```
github "Alamofire/Alamofire" "4.6.0" #Download file from server
github "Hearst-DD/ObjectMapper" "0c116f44b5d052892146bcb94ad6c690b3dec40d" #You know it,will drop it ,change use Swift 4 Codable 
github "SwiftyJSON/SwiftyJSON" "4.0.0" #You know it ,,will drop it ,change use Swift 4 Codable 
github "ashleymills/Reachability.swift" "v3.0" #You know it
github "bizz84/SwiftyStoreKit" "0.13.0" #InApp purchase, will drop  
github "danielgindi/Charts" "v3.0.5" #Chart 
github "groue/GRDB.swift" "v2.4.1" #operate Sqlite use Swift
github "iosdevzone/IDZSwiftCommonCrypto" "0.10.0" #Crypto 
github "networkextension/AxLogger" "dc7896554d40dd1b7032e12e0dd442175b661fe8" #A Logger
github "networkextension/DarwinCore" "5cae12a69d9fbe379dd392978c706d166ef27de6" #many many ObjC/C code 
github "networkextension/SystemKit" "56d5ff28f862f39f6e0a8aefe3964b75ade0dd31" #like DarwinCore ,get some System info 
github "networkextension/libkcp" "bef4a86e2e0020f7254f1dd4f3484585a9acbb91" #FEC enhanced KCP session library for iOS/Android in C++, and Objc Wrapper for Swift use
github "networkextension/liblwip" "0.3" #You know lwip 
github "networkextension/snappy-ios" "72c2b14842943a1f21eb2a76c06d76689fd7aa57" #kcptun compress module 
github "robbiehanson/CocoaAsyncSocket" "7.6.2" #You know it 
github "soffes/CommonCrypto" "v1.1.0" #Crypto
github "soffes/Crypto" "v0.5.4" #Crypto
github "tidwall/IoniconsSwift" "2.1.4" #a icon provider
github "yarshure/MMDB-Swift" "a357488a685efcc0d19f1c476e70fb20abc4fee5" #GeoIP module
github "yarshure/XFoundation" "e6c2f884d9231763b62207e4bbc1b33fe5c37ec5" #some wrapper func use Swift 
github "yarshure/XRuler" "7364f7d709c3192e7c4e394ca3bb752d49f1ada4" #Ruler and misc func 
github "yarshure/Xsocket" "f7c6c2f2edb9b66ee7ecb63a1ce0331a5413abbc" # TCP/UDP socket client
github "zhuhaow/Sodium-framework" "v1.0.10.1" #Sodium Crypto framework for Swift 
```
### Not open source framework ###

* XProxy, HTTP Proxy server write used Swift basic DarwinCore GCDSocketServer and Xcon, todo Finish  ![MITM](https://mitmproxy.org/ "MITM Proxy"), 
* SFSocket SFPacktunnelProvider/XPC,TCP/UDP packet processor,work with lwip    
* Xcon, A TCP  Connection client  basic on Xsocket,support HTTP/scoks5 and xx over kcptun ,also can work as a SSL client

### target 包含说明 ###
* Deployment instructions
* You need download Xcode9.3 Beta2
* Open Xcode change run script ./iosLib/Fabric.framework/run key token or delete run script
* $mkidr Carthage/Build && git clone https://github.com/networkextension/Surf_lib.git
* Or download packege from https://github.com/networkextension/Surf_lib/releases/tag/9.3Beta2, and put them in Carthage/Build
* Change Xcode codesing profile and icloud config
* Build and run  
* Xcode 9.3 have bug , see https://twitter.com/network_ext/status/962701570239533057
* build with command line 
```
$ xcodebuild -target  PacketTunnel-iOS
$xcodebuild -target  SurfToday
$xcodebuild
$ls build/Release-iphoneos/Surf.app
```
### Contribution guidelines ###
*
### Who do I talk to? ###
*none
### todo list ####
....
