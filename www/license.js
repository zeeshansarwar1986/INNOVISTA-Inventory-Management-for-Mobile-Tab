// INNOVISTA licensing: device ID + signed activation key (ECDSA P-256). Created by Zeeshan Sarwar.
(function(){
var C=window.LICENSE_CONFIG||{},enc=new TextEncoder(),dec=new TextDecoder(),KEY='innovista_lic',LS='innovista_ls',AL='0123456789ABCDEFGHJKMNPQRSTVWXYZ';
function b64u(b){return btoa(String.fromCharCode.apply(null,new Uint8Array(b))).replace(/\+/g,'-').replace(/\//g,'_').replace(/=+$/,'')}
function unb(s){s=s.replace(/-/g,'+').replace(/_/g,'/');while(s.length%4)s+='=';var b=atob(s),a=new Uint8Array(b.length);for(var i=0;i<b.length;i++)a[i]=b.charCodeAt(i);return a}
function b32(by){var bits=0,v=0,o='';for(var i=0;i<by.length;i++){v=(v<<8)|by[i];bits+=8;while(bits>=5){o+=AL[(v>>>(bits-5))&31];bits-=5;v&=(1<<bits)-1}}if(bits>0)o+=AL[(v<<(5-bits))&31];return o}
function norm(s){return String(s||'').toUpperCase().replace(/O/g,'0').replace(/[IL]/g,'1').replace(/[^0-9A-Z]/g,'')}
async function seed(){var id='';try{var D=window.Capacitor&&Capacitor.Plugins&&Capacitor.Plugins.Device;if(D&&D.getId){var r=await D.getId();id=(r&&(r.identifier||r.uuid))||''}}catch(e){}
 if(id)return'A|'+id;var s=localStorage.getItem('innovista_devseed');if(!s){s=b64u(crypto.getRandomValues(new Uint8Array(16)));localStorage.setItem('innovista_devseed',s)}return'B|'+s}
async function deviceId(){var h=await crypto.subtle.digest('SHA-256',enc.encode('INNOVISTA-DEVICE-v1|'+await seed()));return b32(new Uint8Array(h).slice(0,10)).replace(/(.{4})/g,'$1-').replace(/-$/,'')}
function clockOk(){var n=Date.now(),l=+localStorage.getItem(LS)||0;if(l&&n<l-864e5)return false;if(n>l)localStorage.setItem(LS,String(n));return true}
async function verify(key,dev){var bad=function(w){return{ok:false,why:w}};
 try{key=String(key||'').replace(/\s+/g,'');if(key.indexOf('INV1-')!==0)return bad('Invalid key format');
  var p=key.slice(5).split('.');if(p.length!==2)return bad('Invalid key format');
  var payload=unb(p[0]),sig=unb(p[1]),f=dec.decode(payload).split('|');if(f[0]!=='INV1')return bad('Invalid key format');
  if(!C.publicKey)return bad('Licensing is not configured in this build');
  var pub=await crypto.subtle.importKey('jwk',C.publicKey,{name:'ECDSA',namedCurve:'P-256'},false,['verify']);
  if(!await crypto.subtle.verify({name:'ECDSA',hash:'SHA-256'},pub,sig,payload))return bad('This key is not valid');
  if(norm(f[1])!==norm(dev))return bad('This key was made for another device');
  if(f[2]!=='LIFETIME'&&new Date().toISOString().slice(0,10)>f[2])return bad('This key expired on '+f[2]);
  return{ok:true,name:f[3]||'',exp:f[2]}}catch(e){return bad('Key could not be checked')}}
function copy(t){if(navigator.clipboard&&navigator.clipboard.writeText)return navigator.clipboard.writeText(t).catch(function(){old(t)});old(t);return Promise.resolve()}
function old(t){var a=document.createElement('textarea');a.value=t;document.body.appendChild(a);a.select();try{document.execCommand('copy')}catch(e){}a.remove()}
function screen(dev,msg){return new Promise(function(done){
 var logo=(typeof LOGO!=='undefined')?'<img src="'+LOGO+'" style="width:84px;height:84px;border-radius:50%" alt="">':'';
 var nav=document.getElementById('nav');if(nav)nav.innerHTML='';
 document.getElementById('app').innerHTML='<div class="card" style="max-width:420px;margin:6vh auto;text-align:center">'+logo+'<h2 style="margin-top:10px">Activation required</h2>'+
 '<p class="mu">Send this Device ID to the app owner. He will send you an activation key.</p>'+
 '<div id="lic-id" style="font:700 22px/1.3 ui-monospace,Menlo,Consolas,monospace;letter-spacing:1px;padding:14px;border:1px dashed var(--pr);border-radius:12px;margin:10px 0;user-select:all">'+dev+'</div>'+
 '<div style="display:flex;gap:8px;margin-bottom:14px"><button class="btn s w" id="lic-copy">Copy ID</button><button class="btn w" id="lic-wa" style="background:#1fa855">WhatsApp</button></div>'+
 '<label class="mu" style="display:block;text-align:left">Activation key</label><textarea id="lic-key" rows="4" placeholder="Paste the key here" style="width:100%;padding:10px;border-radius:10px;border:1px solid var(--bd);background:var(--bg);color:var(--tx);font:12px ui-monospace,Menlo,Consolas,monospace"></textarea>'+
 '<button class="btn w" id="lic-go" style="margin-top:10px">Activate</button><p class="bad" id="lic-err" style="min-height:20px">'+(msg||'')+'</p></div>';
 var msgText='INNOVISTA activation request\nDevice ID: '+dev;
 document.getElementById('lic-copy').onclick=function(){copy(dev).then(function(){var b=document.getElementById('lic-copy');b.textContent='Copied';setTimeout(function(){b.textContent='Copy ID'},1500)})};
 document.getElementById('lic-wa').onclick=function(){var u='https://wa.me/'+String(C.ownerWhatsApp||'').replace(/\D/g,'')+'?text='+encodeURIComponent(msgText);
  if(!C.ownerWhatsApp&&navigator.share){navigator.share({text:msgText}).catch(function(){})}else window.open(u,'_blank')};
 document.getElementById('lic-go').onclick=async function(){var k=document.getElementById('lic-key').value,e=document.getElementById('lic-err');e.textContent='Checking...';
  var r=await verify(k,dev);if(!r.ok){e.textContent=r.why;return}if(!clockOk()){e.textContent='Device clock looks wrong. Set the correct date and time.';return}
  localStorage.setItem(KEY,k.replace(/\s+/g,''));LIC.info={name:r.name,exp:r.exp,id:dev};done()}})}
var LIC=window.LIC={info:null,
 ensure:async function(){if(!C.required)return;var dev;try{dev=await deviceId()}catch(e){document.getElementById('app').innerHTML='<div class="card"><h2>Not supported</h2><p>This device cannot run licensing checks (secure context needed).</p></div>';return new Promise(function(){})}
  var k=localStorage.getItem(KEY),msg='';
  if(k){var r=await verify(k,dev);if(r.ok&&clockOk()){LIC.info={name:r.name,exp:r.exp,id:dev};return}msg=r.ok?'Device clock looks wrong. Set the correct date and time.':r.why}
  await screen(dev,msg)},
 card:function(){var i=LIC.info;if(!i)return'';return'<div class="card"><h2>License</h2><div class="row"><span>Status</span><b class="ok">Activated</b></div><div class="row"><span>Licensed to</span><b>'+(i.name?String(i.name).replace(/[<>&"]/g,''):'-')+'</b></div><div class="row"><span>Valid until</span><b>'+(i.exp==='LIFETIME'?'Lifetime':i.exp)+'</b></div><div class="row"><span>Device ID</span><b style="font:600 13px ui-monospace,Menlo,Consolas,monospace">'+i.id+'</b></div></div>'}};
document.addEventListener('visibilitychange',function(){if(document.hidden||!C.required||!LIC.info)return;var k=localStorage.getItem(KEY);deviceId().then(function(d){return verify(k,d)}).then(function(r){if(!r.ok||!clockOk())location.reload()}).catch(function(){})});
})();
