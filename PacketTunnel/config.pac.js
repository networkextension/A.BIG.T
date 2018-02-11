var tunnel = "SOCKS5 127.0.0.1:1080; SOCKS 127.0.0.1:1080; DIRECT;";
var direct = "DIRECT";
var proxyList = "cdninstagram.com|squarespace.com|aka|licdn.com|gstatic.com|githubusercontent.com|imgur.com|dropboxstatic.com|bitbucket.org|github.com|mzstatic.com|pinboard.in|box.net|gravatar.com|jshint.com|twitch.tv|dropboxusercontent.com|engadget.com|amazon.com|openvpn.net|crashlytics.com|symauth.com|edgecastcdn.net|wikimedia.org|wsj.com|ow.ly|tumblr.com|itunes.com|github.io|lithium.com|wsj.net|openwrt.org|ift.tt|blogspot|t.co|fc2.com|goo.gl|blogcdn.com|twitter.com|linkedin.com|blogsmithmedia.com|instagram|twimg.com|cloudfront.net|docker.com|linode.com|symcd.com|fastly.net|ubnt.com|twitter|fbcdn.net|imageshack.us|fabric.io|wikipedia.com|dnsimple.com|eurekavpt.com|ytimg.com|nytimes.com|megaupload.com|blog.com|akamaihd.net|google|duckduckgo.com|symcb.com|youtube|ssl-images-amazon.com|mobile01.com|sstatic.net|ggpht.com|kenengba.com|me.com|j.mp|dropbox.com|fb.me|staticflickr.com|thepiratebay.org|stackoverflow.com|gmail|bloomberg.com|youtu.be|golang.org|feedburner.com|godaddy.com|facebook|flickr.com|modmyi.com|bit.ly|name.com|appspot.com|vimeo.com|chromium.org|kat.cr|wikipedia.org|wp.com|cloudflare.com|cocoapods.org|dribbble.com|wordpress.com|blogger.com|android.com|digicert.com|tapbots.com|amazonaws.com|cl.ly|akamai.net|angularjs.org".split("|").reduce(function(a, b) {
    return a[b] = 1, a;
}, {});
var directList = "360buy|apple.com|sohu.com|bdimg.com|icloud.com|hao123.com|analytics.126.net|qhimg.com|amap.com|cn|xunlei.com|cnbeta.com|api.smoot.apple.com|baidu.com|taobao.com|alipay|soso.com|lcdn-registration.apple.com|configuration.apple.com|youku.com|suning.com|netease.com|akadns.net|sogou.com|weibo.com|163.com|guzzoni.apple.com|douban.com|xp.apple.com|126.net|ess.apple.com|jd.com|captive.apple.com|cnzz.com|outlook.com|medium.com|tudou.com|ifeng.com|bdstatic.com|haosou.com|alicdn.com|tmall.com|ls.apple.com|smp-device-content.apple.com|iqiyi.com|ykimg.com|qq.com|zhihu.com|push.apple.com|gtimg.com|weather.com".split("|").reduce(function(a, b) {
    return a[b] = 1, a;
}, {});
var rejectList = "duomeng.net|adzerk.net|advertising.com|mobads.baidu.com|googeadsserving.cn|appads.com|adwhirl.com|js-agent.newrelic.com|ads|cr-nielsen.com|stat.ws.126.net|adcome.cn|wooboo.com.cn|admaster.com.cn|guomob.com|asimgs.pplive.cn|simaba.taobao.com|immob.cn|wiyun.com|mmstat.com|domob.com.cn|analytics|smartadserver.com|flurry.com|zhiziyun.com|temp.163.com|cmcore.com|sax.sina.cn|duomeng.cn|adsage.cn|wqmobile.com|aduu.cn|umeng.co|doubleclick.net|cnzz.com|stat.m.jd.com|ark.letv.com|uyunad.com|g.163.com|flurry.co|adxmi.com|monitor.uu.qq.com|tajs.qq.com|localytics.com|baidustatic.com|pos.baidu.com|umeng.com|eclick.baidu.com|m.simaba.taobao.com|inmobi.com|miaozhen.com|umeng.net|ads.mopub.com|waps.cn|mobads-logs.baidu.com|adview.cn|cbjs.baidu.com|adjust.com|acjs.aliyun.com|51.la|iadsdk.apple.com|anquan.org|counter.kingsoft.com|atm.youku.com|lh8.ggpht.com|ad.unimhk.com|adash.m.taobao.com|mob.c|pingtcss.qq.com|duomeng.org|x.jd.com|baifendian.com|adsmogo|cpro.baidu.com|lh7.ggpht.com|track|acs86.com|adwo.com|lh6.ggpht.com|bam.nr-data.net|msga.71.am|dsp.youdao.com|report.qq.com|pingma.qq.com|lh5.ggpht.com|msg.71.am|kejet.net|adinfuse.com|lives.l.qq.com|beacon.sina.com.cn|ad.api.3g.youku.com|adsage.com|traffic|adsmogo.org|nsclick.baidu.com|admob.com|appsflyer.com|lh4.ggpht.com|ads.mobclix.com|applifier.com|www.panoramio.com|beacon.qq.com|duomeng|youmi.net|pagead2.googlesyndication.com|csi.gstatic.com|lh3.ggpht.com|mtj.baidu.com|domob.org|ad.api.3g.tudou.com|coremetrics.com|pixel.wp.com|intely.cn|irs01.com|lh2.ggpht.com|adchina.com|ushaqi.com|tiqcdn.com|mixpanel.com|pingjs.qq.com|lh1.ggpht.com|127.net|union.youdao.com|hm.baidu.com|tapjoyads.com|umtrack.com|madmini.com|wrating.com|tanx.com".split("|").reduce(function(a, b) {
    return a[b] = 1, a;
}, {});
var ipRange = [
  "17.0.0.0\/8\/DIRECT",
  "91.108.56.0\/22\/PROXY",
  "91.108.4.0\/22\/PROXY",
  "109.239.140.0\/24\/PROXY",
  "149.154.160.0\/20\/PROXY",
  "192.168.0.0\/16\/DIRECT",
  "10.0.0.0\/8\/DIRECT",
  "172.16.0.0\/12\/DIRECT",
  "127.0.0.0\/8\/DIRECT"
];
var finallyRule = "PROXY";
var cidrToSubnetMask = {
    "0": "0.0.0.0",
    "1": "128.0.0.0",
    "2": "192.0.0.0",
    "3": "224.0.0.0",
    "4": "240.0.0.0",
    "5": "248.0.0.0",
    "6": "252.0.0.0",
    "7": "254.0.0.0",
    "8": "255.0.0.0",
    "9": "255.128.0.0",
    "10": "255.192.0.0",
    "11": "255.224.0.0",
    "12": "255.240.0.0",
    "13": "255.248.0.0",
    "14": "255.252.0.0",
    "15": "255.254.0.0",
    "16": "255.255.0.0",
    "17": "255.255.128.0",
    "18": "255.255.192.0",
    "19": "255.255.224.0",
    "20": "255.255.240.0",
    "21": "255.255.248.0",
    "22": "255.255.252.0",
    "23": "255.255.254.0",
    "24": "255.255.255.0",
    "25": "255.255.255.128",
    "26": "255.255.255.192",
    "27": "255.255.255.224",
    "28": "255.255.255.240",
    "29": "255.255.255.248",
    "30": "255.255.255.252",
    "31": "255.255.255.254",
    "32": "255.255.255.255"
};

ipRange = ipRange.contact(
    "0.0.0.0/8/DIRECT",
    "10.0.0.0/8/DIRECT",
    "100.64.0.0/10/DIRECT",
    "127.0.0.0/8/DIRECT",
    "169.254.0.0/16/DIRECT",
    "172.16.0.0/12/DIRECT",
    "192.0.0.0/24/DIRECT",
    "192.0.2.0/24/DIRECT",
    "192.168.0.0/16/DIRECT",
    "198.18.0.0/15/DIRECT",
    "198.51.100.0/24/DIRECT",
    "203.0.113.0/24/DIRECT",
    "224.0.0.0/4/DIRECT",
    "240.0.0.0/4/DIRECT",
    "255.255.255.255/32/DIRECT"
);

function FindProxyForURL(url, host) {
    if (isPlainHostName(host)) {
        return direct;
    }

    var domain = host;
    var pos = 0;
    var idx = 0;

    do {
        if (directList.hasOwnProperty(domain)) {
            return direct;
        }

        if (proxyList.hasOwnProperty(domain) || rejectList.hasOwnProperty(domain)) {
            return tunnel;
        }

        idx = pos;
        pos = host.indexOf(".", pos) + 1;

        if (idx < pos - 1) {
            var key = host.substring(idx, pos - 1);
            if (directList.hasOwnProperty(key)) {
                return direct;
            }
            if (proxyList.hasOwnProperty(key) || rejectList.hasOwnProperty(key)) {
                return tunnel;
            }
        }

        domain = host.substring(pos);
    } while (pos > 0);

    var ip = dnsResolve(host);

    if (!ip) {
        return tunnel;
    }

    for (var i in ipRange) {
        var parts = ipRange[i].split('/');
        if (isInNet(ip, parts[0], cidrToSubnetMask[parts[1]])) {
            if (parts[2] == 'DIRECT') {
                return direct;
            }
            return tunnel;
        }
    }

    if (finallyRule == 'PROXY') {
        return tunnel;
    }

    return direct;
}