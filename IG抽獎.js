function get留言url(貼文url){
    let pattern=貼文url.match(/\/p\/(.*?)\//)[1];
    if(pattern.length<=0){throw '非合法url';}
    let return_url=`https://www.instagram.com/graphql/query/?query_hash=97b41c52301f77ce508f55e66d17620e&variables={"shortcode":"${pattern}","first":50,"after":""}`;
    
    return return_url;
}
function get留言json(留言url){
    let req = new XMLHttpRequest();
    let json;
    req.onreadystatechange = function(){
        if(req.readyState == 4 && req.status == 200){
            json = JSON.parse(req.response);
        }
    }
    req.open('GET',留言url,false);
    req.send();
    
    return json;
}
function get得獎list(留言json,得獎人數,合格留言){
    let 留言list = 留言json.data.shortcode_media.edge_media_to_parent_comment.edges;
    let 合格留言list = [];
    let 得獎list = [];
    留言list.forEach(function(i){
        if(i.node.text.toLocaleLowerCase().includes(合格留言)){
            合格留言list.push(i.node.owner.username);
        }
    });
    for (let i = 0 ; i <= Math.random() * 10 * 合格留言list.length; i++){
        shuffleArray(合格留言list);
    };
    for(i=0;i<得獎人數;i++){
        得獎list.push(合格留言list[i]);
    }
    return 得獎list;
}
function shuffleArray(array) {
    for (let i = array.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [array[i], array[j]] = [array[j], array[i]];
    }
}

function openwindow(得獎list){
    得獎list.forEach(function(i){
        if(i != undefined) window.open(`https://www.instagram.com/${i}`);
    });
}

async function 執行抽獎(貼文url,合格留言,得獎人數,標記人數){
    let 留言url = await get留言url(貼文url);
    let 留言json = await get留言json(留言url);
    let 得獎list = await get得獎list(留言json,得獎人數,合格留言);
    await openwindow(得獎list);
}

/*
執行抽獎('https://www.instagram.com/p/xyz/'
    ,'done'
    ,10
);
*/
