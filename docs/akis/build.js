// Builds docs/kullanici-akislari.html from flows.js + extras.js. Run: node docs/akis/build.js
const fs = require('fs');
const path = require('path');
const { renderFlow, renderWire, renderNav, esc } = require('./render');
const { flows } = require('./flows');
const { wires, navNodes, navEdges, rules, errorCatalog, ux } = require('./extras');

const sevClass = { Yüksek: 'high', Orta: 'mid', Düşük: 'low' };

const css = `
:root{--bg:#F5F6F2;--surface:#FFFFFF;--sunk:#ECEEE8;--ink:#1F2621;--soft:#5A645C;--faint:#8A938B;--line:#D9DDD4;
--accent:#2F5D3A;--accent-soft:#E1EDE2;--coral:#C4533C;--coral-soft:#F6E2DC;--amber:#8A6516;--amber-soft:#F4EAD0;--blue:#2F5F7A;--blue-soft:#DDEAF1;}
@media (prefers-color-scheme: dark){:root:not([data-theme="light"]){--bg:#151A16;--surface:#1D241F;--sunk:#19201B;--ink:#E7ECE6;--soft:#A5AFA6;--faint:#7C867D;--line:#2F3932;
--accent:#86C093;--accent-soft:#25362A;--coral:#E58C77;--coral-soft:#3C2620;--amber:#D8B15E;--amber-soft:#3A2F17;--blue:#86B6CF;--blue-soft:#1D323D;}}
:root[data-theme="dark"]{--bg:#151A16;--surface:#1D241F;--sunk:#19201B;--ink:#E7ECE6;--soft:#A5AFA6;--faint:#7C867D;--line:#2F3932;
--accent:#86C093;--accent-soft:#25362A;--coral:#E58C77;--coral-soft:#3C2620;--amber:#D8B15E;--amber-soft:#3A2F17;--blue:#86B6CF;--blue-soft:#1D323D;}
*{box-sizing:border-box}
body{margin:0;background:var(--bg);color:var(--ink);font:15px/1.6 system-ui,-apple-system,"Segoe UI",Roboto,sans-serif}
.wrap{max-width:1040px;margin:0 auto;padding:0 20px 80px}
header.top{padding:48px 0 24px;border-bottom:1px solid var(--line)}
.eyebrow{font-size:12px;letter-spacing:.1em;text-transform:uppercase;color:var(--accent);font-weight:700}
h1{font-size:34px;line-height:1.15;margin:8px 0 10px;text-wrap:balance}
h2{font-size:24px;margin:56px 0 6px;text-wrap:balance}
h3{font-size:19px;margin:0 0 4px;text-wrap:balance}
h4{font-size:12px;letter-spacing:.08em;text-transform:uppercase;color:var(--soft);margin:22px 0 8px}
p.lede{color:var(--soft);max-width:68ch;margin:6px 0}
nav.toc{display:flex;flex-wrap:wrap;gap:8px;margin:20px 0 0}
nav.toc a{font-size:13px;padding:5px 11px;border:1px solid var(--line);border-radius:999px;color:var(--ink);text-decoration:none;background:var(--surface)}
nav.toc a:hover{border-color:var(--accent);color:var(--accent)}
section.flow-card{background:var(--surface);border:1px solid var(--line);border-radius:14px;padding:22px;margin:18px 0}
.fid{display:inline-block;font-size:12px;font-weight:700;color:var(--accent);background:var(--accent-soft);border-radius:6px;padding:2px 8px;margin-right:8px;vertical-align:2px}
.grp{font-size:12px;color:var(--faint);margin-left:6px}
.story{color:var(--soft);font-style:italic;margin:4px 0 12px}
.meta{display:grid;grid-template-columns:1fr 1fr;gap:10px;margin:12px 0}
.meta div{background:var(--sunk);border-radius:8px;padding:9px 12px;font-size:13.5px}
.meta b{display:block;font-size:11px;letter-spacing:.07em;text-transform:uppercase;color:var(--soft)}
.cols{display:grid;grid-template-columns:minmax(0,1.05fr) minmax(0,1fr);gap:26px;align-items:start}
.cols ol,.cols ul{margin:6px 0;padding-left:20px}
.cols li{margin-bottom:6px;font-size:14.5px}
.diagram{background:var(--sunk);border:1px solid var(--line);border-radius:10px;padding:10px;overflow-x:auto}
svg.flow{width:100%;min-width:560px;height:auto;display:block}
svg.flow.nav{min-width:700px}
svg.wire{width:100%;max-width:250px;height:auto;display:block}
.nd{stroke-width:1.4}
.nd-start,.nd-end{fill:var(--accent);stroke:var(--accent)}
.nd-screen{fill:var(--surface);stroke:var(--accent)}
.nd-action{fill:var(--surface);stroke:var(--line)}
.nd-decision{fill:var(--amber-soft);stroke:var(--amber)}
.nd-error{fill:var(--coral-soft);stroke:var(--coral)}
.nd-alt{fill:var(--blue-soft);stroke:var(--blue)}
.nt{font:12.5px system-ui,sans-serif;fill:var(--ink)}
.nt-start,.nt-end{fill:#fff;font-weight:600}
:root[data-theme="dark"] .nt-start,:root[data-theme="dark"] .nt-end{fill:#0f1a12}
@media (prefers-color-scheme: dark){:root:not([data-theme="light"]) .nt-start,:root:not([data-theme="light"]) .nt-end{fill:#0f1a12}}
.edge{stroke:var(--faint);stroke-width:1.4;fill:none}.edge-err{stroke:var(--coral)}
.navedge{stroke:var(--faint);stroke-width:1.2;fill:none}
.arrowhead{fill:var(--faint)}
.elabel{font:11px system-ui,sans-serif;fill:var(--soft)}
table{border-collapse:collapse;width:100%;font-size:14px}
th,td{text-align:left;vertical-align:top;padding:8px 10px;border-bottom:1px solid var(--line)}
th{font-size:11.5px;letter-spacing:.07em;text-transform:uppercase;color:var(--soft);font-weight:700}
.tablewrap{overflow-x:auto;background:var(--surface);border:1px solid var(--line);border-radius:12px}
td.msg{font-family:ui-monospace,Consolas,monospace;font-size:12.8px;color:var(--ink)}
.errs td:first-child{width:34%;color:var(--soft)}
.pill{display:inline-block;font-size:11px;font-weight:800;border-radius:999px;padding:2px 9px}
.pill.high{background:var(--coral-soft);color:var(--coral)}.pill.mid{background:var(--amber-soft);color:var(--amber)}.pill.low{background:var(--blue-soft);color:var(--blue)}
.verified{font-size:11px;color:var(--accent);font-weight:700;margin-left:6px}
.wires{display:grid;grid-template-columns:repeat(auto-fill,minmax(230px,1fr));gap:22px;margin-top:14px}
.wirebox{background:var(--sunk);border:1px solid var(--line);border-radius:12px;padding:14px}
.wirebox h3{font-size:15px}.wirebox p{font-size:12.5px;color:var(--soft);margin:2px 0 10px}
.w-phone{fill:var(--surface);stroke:var(--faint);stroke-width:2}.w-notch{fill:var(--line)}
.w-bar{fill:var(--accent-soft)}.w-title{font:700 13px system-ui;fill:var(--ink)}
.w-text{font:11.5px system-ui;fill:var(--ink)}.w-bold{font:700 11.5px system-ui;fill:var(--ink)}
.w-tiny{font:10.5px system-ui;fill:var(--soft)}.w-small{font:11px system-ui;fill:var(--soft)}.w-hint{font:11.5px system-ui;fill:var(--faint)}
.w-banner{fill:var(--accent-soft)}.w-input{fill:var(--surface);stroke:var(--line);stroke-width:1.2}
.w-btn{fill:var(--accent)}.w-btn-a{fill:var(--coral)}.w-btn-t{font:700 12px system-ui;fill:#fff}
.w-btn-o{fill:none;stroke:var(--accent);stroke-width:1.2}.w-btn-ot{font:600 12px system-ui;fill:var(--accent)}
.w-card{fill:var(--surface);stroke:var(--line);stroke-width:1.2}.w-avatar{fill:var(--accent-soft)}
.w-sw-on{fill:var(--accent)}.w-sw-off{fill:var(--line)}.w-knob{fill:#fff}
.w-chip{fill:var(--sunk);stroke:var(--line)}.w-fab{fill:var(--accent)}
.legend{display:flex;flex-wrap:wrap;gap:14px;margin:12px 0;font-size:13px;color:var(--soft)}
.legend span{display:inline-flex;align-items:center;gap:6px}
.legend i{width:16px;height:12px;border-radius:3px;border:1.4px solid;display:inline-block}
.sw-start{background:var(--accent);border-color:var(--accent)!important}.sw-screen{background:var(--surface);border-color:var(--accent)!important}
.sw-action{background:var(--surface);border-color:var(--line)!important}.sw-decision{background:var(--amber-soft);border-color:var(--amber)!important}
.sw-error{background:var(--coral-soft);border-color:var(--coral)!important}.sw-alt{background:var(--blue-soft);border-color:var(--blue)!important}
@media(max-width:760px){.cols{grid-template-columns:1fr}.meta{grid-template-columns:1fr}h1{font-size:27px}}
footer{margin-top:60px;padding-top:20px;border-top:1px solid var(--line);color:var(--faint);font-size:13px}
`;

const groups = [...new Set(flows.map((f) => f.group))];

function storiesTable() {
  const rows = flows
    .map((f) => `<tr><td><a href="#${f.id}">${f.id}</a></td><td>${esc(f.group)}</td><td>${esc(f.story)}</td><td>${esc(f.start)}</td><td>${esc(f.end)}</td></tr>`)
    .join('');
  return `<div class="tablewrap"><table><thead><tr><th>No</th><th>Alan</th><th>Kullanıcı hikâyesi</th><th>Başlangıç</th><th>Bitiş</th></tr></thead><tbody>${rows}</tbody></table></div>`;
}

function flowCard(f) {
  const errRows = f.errs.map(([c, m]) => `<tr><td>${esc(c)}</td><td class="msg">${esc(m)}</td></tr>`).join('');
  return `<section class="flow-card" id="${f.id}">
<h3><span class="fid">${f.id}</span>${esc(f.title)}<span class="grp">${esc(f.group)}</span></h3>
<p class="story">“${esc(f.story)}”</p>
<div class="meta"><div><b>Başlangıç noktası</b>${esc(f.start)}</div><div><b>Bitiş noktası</b>${esc(f.end)}</div></div>
<div class="cols">
 <div><h4>Adımlar</h4><ol>${f.steps.map((s) => `<li>${esc(s)}</li>`).join('')}</ol>
 <h4>Alternatif yollar</h4><ul>${f.alts.map((s) => `<li>${esc(s)}</li>`).join('')}</ul></div>
 <div class="diagram">${renderFlow(f.nodes)}</div>
</div>
<h4>Hata durumları ve kullanıcıya gösterilen geri bildirim</h4>
<div class="tablewrap errs"><table><thead><tr><th>Durum</th><th>Gösterilen mesaj</th></tr></thead><tbody>${errRows}</tbody></table></div>
</section>`;
}

const wireHtml = wires
  .map((w) => {
    const r = renderWire(w.title, w.els);
    return `<div class="wirebox"><h3>${w.id} · ${esc(w.title)}</h3><p>${esc(w.note)}</p>${r.svg}</div>`;
  })
  .join('');

const html = `<!doctype html>
<html lang="tr"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>CheckIt Kullanıcı Akışları</title><style>${css}</style></head>
<body><div class="wrap">
<header class="top">
<div class="eyebrow">CheckIt · Ürün dokümanı · 8 Ekim 2026</div>
<h1>Kullanıcı akışları, ekranlar ve hata durumları</h1>
<p class="lede">Uygulamanın kodundan çıkarılan ${flows.length} temel kullanıcı görevi: her birinin başlangıç ve bitiş noktası, adımları, alternatif yolları, hata mesajları ve akış diyagramı. Metinler uygulamadaki gerçek Türkçe ifadelerdir. Wireframe'ler gerçek ekran görüntüsü değil, yapıyı gösteren şematik çizimlerdir.</p>
<nav class="toc"><a href="#harita">Ekran haritası</a><a href="#hikayeler">Kullanıcı görevleri</a><a href="#wireframe">Wireframe'ler</a><a href="#akislar">Akış detayları</a><a href="#kurallar">Kurallar</a><a href="#hatalar">Hata kataloğu</a><a href="#ux">UX gözlemleri</a></nav>
</header>

<h2 id="harita">1. Ekran haritası</h2>
<p class="lede">Hangi ekrandan hangisine geçildiği. Ana sayfa merkezdir; Profil, Davetlerim, Arşiv ve Bekleyen Maddeler üst çubuktaki simgelerle açılır.</p>
<div class="legend"><span><i class="sw-start"></i>Başlangıç</span><span><i class="sw-screen"></i>Ekran</span><span><i class="sw-action"></i>İşlem</span><span><i class="sw-decision"></i>Karar</span><span><i class="sw-alt"></i>Alternatif / panel</span><span><i class="sw-error"></i>Hata / engel</span></div>
<div class="diagram">${renderNav(navNodes, navEdges)}</div>

<h2 id="hikayeler">2. Temel kullanıcı görevleri</h2>
<p class="lede">Her satır bir akışa bağlanır. Başlangıç ve bitiş, kullanıcının görevi başlattığı ve tamamlanmış saydığı noktadır.</p>
${storiesTable()}

<h2 id="wireframe">3. Ana ekranlar (wireframe)</h2>
<p class="lede">Yedi ana ekranın şematik çizimi: neyin nerede olduğunu gösterir, piksel düzeni değildir.</p>
<div class="wires">${wireHtml}</div>

<h2 id="akislar">4. Akış detayları</h2>
<p class="lede">Diyagram okuma: sarı altıgen bir karardır, kırmızı kutular hata ya da engeli, mavi kutular alternatif yolu gösterir. Okla yandaki kutuya giden çizgi, o noktadan çıkış yoludur.</p>
<div class="legend"><span><i class="sw-start"></i>Başlangıç / bitiş</span><span><i class="sw-screen"></i>Ekran</span><span><i class="sw-action"></i>İşlem</span><span><i class="sw-decision"></i>Karar</span><span><i class="sw-alt"></i>Alternatif</span><span><i class="sw-error"></i>Hata</span></div>
${flows.map(flowCard).join('\n')}

<h2 id="kurallar">5. Akışları etkileyen kurallar</h2>
<div class="tablewrap"><table><thead><tr><th>Kural</th><th>Ne olur</th></tr></thead><tbody>${rules.map(([a, b]) => `<tr><td><b>${esc(a)}</b></td><td>${esc(b)}</td></tr>`).join('')}</tbody></table></div>

<h2 id="hatalar">6. Hata mesajı kataloğu</h2>
<p class="lede">Kullanıcının görebileceği ortak hata mesajları. Akışlara özgü mesajlar ilgili akış kartında da yazılıdır.</p>
<div class="tablewrap errs"><table><thead><tr><th>Tür</th><th>Mesaj</th><th>Ne zaman</th></tr></thead><tbody>${errorCatalog.map(([a, b, c]) => `<tr><td>${esc(a)}</td><td class="msg">${esc(b)}</td><td>${esc(c)}</td></tr>`).join('')}</tbody></table></div>

<h2 id="ux">7. UX gözlemleri</h2>
<p class="lede">Akışlar incelenirken bulunanlar. "Doğrulandı" işaretli olanları kodu kendim yeniden okuyarak teyit ettim; diğerleri kod taramasından geldi ve düzeltmeye başlamadan önce tekrar doğrulanmalı. Yüksek öncelikliler mağaza yayınından önce ele alınmalı.</p>
<div class="tablewrap"><table><thead><tr><th>No</th><th>Önem</th><th>Sorun</th><th>Önerilen çözüm</th></tr></thead><tbody>${ux
  .map(([id, sev, title, detail, fix, ver]) => `<tr><td>${id}</td><td><span class="pill ${sevClass[sev]}">${sev}</span></td><td><b>${esc(title)}</b>${ver ? '<span class="verified">doğrulandı</span>' : ''}<br><span style="color:var(--soft);font-size:13px">${esc(detail)}</span></td><td>${esc(fix)}</td></tr>`)
  .join('')}</tbody></table></div>

<footer>Bu doküman <code>docs/akis/</code> altındaki betiklerden üretilir (<code>node docs/akis/build.js</code>). Kod değiştikçe akış verisi güncellenip yeniden üretilmelidir.</footer>
</div></body></html>`;

const out = path.join(__dirname, '..', 'kullanici-akislari.html');
fs.writeFileSync(out, html);
console.log('written', out, (html.length / 1024).toFixed(0) + ' KB');
