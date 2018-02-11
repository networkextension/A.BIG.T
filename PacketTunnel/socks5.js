var tunnel = "SOCKS5 240.7.1.10:10082; ";//SOCKS 127.0.0.1:1080; DIRECT;
var direct = "DIRECT";
function FindProxyForURL(url, host) {
    return tunnel
}