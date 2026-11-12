// Build step: copy www to dist and make the code hard to read (obfuscation). Usage: node tools/protect.js www dist
// Needs: npm install (javascript-obfuscator). Without it the files are copied unchanged and a warning is shown.
const fs=require('fs'),path=require('path');
const src=process.argv[2]||'www',out=process.argv[3]||'dist';
fs.rmSync(out,{recursive:true,force:true});fs.cpSync(src,out,{recursive:true});
let O=null;try{O=require('javascript-obfuscator')}catch(e){console.warn('WARNING: javascript-obfuscator is not installed. Code is NOT obfuscated.')}
const opts={compact:true,identifierNamesGenerator:'hexadecimal',renameGlobals:false,stringArray:true,stringArrayEncoding:['base64'],stringArrayThreshold:0.75,rotateStringArray:true,splitStrings:true,splitStringsChunkLength:8,disableConsoleOutput:true,transformObjectKeys:false,controlFlowFlattening:false,deadCodeInjection:false};
const obf=c=>O?O.obfuscate(c,opts).getObfuscatedCode():c;
const idx=path.join(out,'index.html');let h=fs.readFileSync(idx,'utf8');
const m=h.match(/<script>([\s\S]*)<\/script>/);
if(m){fs.writeFileSync(path.join(out,'app.js'),obf(m[1]));h=h.replace(m[0],'<script src="app.js"></script>');fs.writeFileSync(idx,h)}
for(const f of ['license.js','db.js']){const p=path.join(out,f);if(fs.existsSync(p))fs.writeFileSync(p,obf(fs.readFileSync(p,'utf8')))}
console.log('protect: done ->',out,O?'(obfuscated)':'(not obfuscated)');
