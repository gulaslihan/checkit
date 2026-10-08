// SVG renderers for the user-flow document: flowcharts, wireframes, navigation map.
const esc = (s) => String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');

function wrap(text, maxChars) {
  const words = String(text).split(/\s+/);
  const lines = [];
  let cur = '';
  for (const w of words) {
    if ((cur + ' ' + w).trim().length > maxChars && cur) {
      lines.push(cur);
      cur = w;
    } else {
      cur = (cur + ' ' + w).trim();
    }
  }
  if (cur) lines.push(cur);
  return lines;
}

function textBlock(lines, x, y, cls, lh = 16, anchor = 'middle') {
  return lines
    .map((l, i) => `<text x="${x}" y="${y + i * lh}" class="${cls}" text-anchor="${anchor}">${esc(l)}</text>`)
    .join('');
}

// Flowchart: vertical main chain, optional side exits to the right.
function renderFlow(nodes) {
  const mainX = 16, mainW = 290, sideX = 406, sideW = 240, W = 654, gap = 28, pad = 11, lh = 16;
  const mainChars = 41, sideChars = 32;
  let y = 14;
  let out = '';
  const rows = [];
  for (const n of nodes) {
    const ml = wrap(n.t, mainChars);
    const mh = pad * 2 + ml.length * lh - 4;
    let sl = null, sh = 0;
    if (n.side) {
      sl = wrap(n.side.t, sideChars);
      sh = pad * 2 + sl.length * lh - 4;
    }
    const rh = Math.max(mh, sh);
    rows.push({ n, ml, mh, sl, sh, rh, y });
    y += rh + gap;
  }
  const H = y - gap + 14;
  out += `<defs><marker id="ah" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0,0 L10,5 L0,10 z" class="arrowhead"/></marker></defs>`;
  rows.forEach((r, i) => {
    const { n, ml, mh, sl, sh, rh } = r;
    const my = r.y + (rh - mh) / 2;
    const cy = my + mh / 2;
    const k = n.k || 'action';
    if (k === 'start' || k === 'end') {
      out += `<rect x="${mainX}" y="${my}" width="${mainW}" height="${mh}" rx="${mh / 2}" class="nd nd-${k}"/>`;
    } else if (k === 'decision') {
      const c = 14;
      out += `<polygon points="${mainX + c},${my} ${mainX + mainW - c},${my} ${mainX + mainW},${cy} ${mainX + mainW - c},${my + mh} ${mainX + c},${my + mh} ${mainX},${cy}" class="nd nd-decision"/>`;
    } else {
      out += `<rect x="${mainX}" y="${my}" width="${mainW}" height="${mh}" rx="8" class="nd nd-${k}"/>`;
    }
    out += textBlock(ml, mainX + mainW / 2, my + pad + 11, `nt nt-${k}`, lh);
    if (i < rows.length - 1) {
      const ny = rows[i + 1].y + (rows[i + 1].rh - rows[i + 1].mh) / 2;
      out += `<line x1="${mainX + mainW / 2}" y1="${my + mh}" x2="${mainX + mainW / 2}" y2="${ny - 1}" class="edge" marker-end="url(#ah)"/>`;
      if (k === 'decision') {
        out += `<text x="${mainX + mainW / 2 + 8}" y="${my + mh + 16}" class="elabel">${esc(n.yes || 'Evet')}</text>`;
      } else if (n.next) {
        out += `<text x="${mainX + mainW / 2 + 8}" y="${my + mh + 16}" class="elabel">${esc(n.next)}</text>`;
      }
    }
    if (n.side) {
      const sy = r.y + (rh - sh) / 2;
      const scy = sy + sh / 2;
      const sk = n.side.k || 'alt';
      out += `<line x1="${mainX + mainW}" y1="${cy}" x2="${sideX - 1}" y2="${scy}" class="edge ${sk === 'error' ? 'edge-err' : ''}" marker-end="url(#ah)"/>`;
      if (n.side.label) {
        const ll = wrap(n.side.label, 14);
        const gx = (mainX + mainW + sideX) / 2;
        const baseY = Math.min(cy, scy) - 6 - (ll.length - 1) * 12;
        out += textBlock(ll, gx, baseY, 'elabel', 12, 'middle');
      }
      out += `<rect x="${sideX}" y="${sy}" width="${sideW}" height="${sh}" rx="8" class="nd nd-${sk}"/>`;
      out += textBlock(sl, sideX + sideW / 2, sy + pad + 11, `nt nt-${sk}`, lh);
    }
  });
  return `<svg class="flow" viewBox="0 0 ${W} ${H}" role="img" aria-label="Akış diyagramı" xmlns="http://www.w3.org/2000/svg">${out}</svg>`;
}

// Wireframe: a phone with stacked simple elements.
function renderWire(title, els) {
  const W = 250, px = 12, inner = W - px * 2;
  let y = 30;
  let out = '';
  const draw = [];
  for (const e of els) {
    switch (e.t) {
      case 'bar': {
        draw.push(`<rect x="0" y="${y}" width="${W}" height="44" class="w-bar"/>`);
        draw.push(`<text x="${px}" y="${y + 27}" class="w-title">${esc(e.text)}</text>`);
        if (e.right) draw.push(`<text x="${W - px}" y="${y + 27}" text-anchor="end" class="w-small">${esc(e.right)}</text>`);
        y += 52;
        break;
      }
      case 'text': {
        const ls = wrap(e.text, 38);
        draw.push(textBlock(ls, px, y + 12, e.bold ? 'w-bold' : 'w-text', 14, 'start'));
        y += ls.length * 14 + 8;
        break;
      }
      case 'banner': {
        const ls = wrap(e.text, 40);
        const h = ls.length * 13 + 14;
        draw.push(`<rect x="${px}" y="${y}" width="${inner}" height="${h}" rx="8" class="w-banner"/>`);
        draw.push(textBlock(ls, px + 8, y + 17, 'w-tiny', 13, 'start'));
        y += h + 10;
        break;
      }
      case 'input': {
        draw.push(`<rect x="${px}" y="${y}" width="${inner}" height="32" rx="8" class="w-input"/>`);
        draw.push(`<text x="${px + 10}" y="${y + 20}" class="w-hint">${esc(e.text)}</text>`);
        if (e.right) draw.push(`<text x="${W - px - 10}" y="${y + 20}" text-anchor="end" class="w-hint">${esc(e.right)}</text>`);
        y += 42;
        break;
      }
      case 'btn': {
        draw.push(`<rect x="${px}" y="${y}" width="${inner}" height="34" rx="17" class="${e.primary === false ? 'w-btn-o' : e.accent ? 'w-btn-a' : 'w-btn'}"/>`);
        draw.push(`<text x="${W / 2}" y="${y + 21}" text-anchor="middle" class="${e.primary === false ? 'w-btn-ot' : 'w-btn-t'}">${esc(e.text)}</text>`);
        y += 44;
        break;
      }
      case 'row': {
        const h = e.sub ? 46 : 34;
        draw.push(`<rect x="${px}" y="${y}" width="${inner}" height="${h}" rx="8" class="w-card"/>`);
        draw.push(`<circle cx="${px + 18}" cy="${y + h / 2}" r="10" class="w-avatar"/>`);
        draw.push(`<text x="${px + 36}" y="${y + (e.sub ? 19 : h / 2 + 4)}" class="w-bold">${esc(e.text)}</text>`);
        if (e.sub) draw.push(`<text x="${px + 36}" y="${y + 34}" class="w-tiny">${esc(e.sub)}</text>`);
        if (e.right) draw.push(`<text x="${W - px - 8}" y="${y + h / 2 + 4}" text-anchor="end" class="w-small">${esc(e.right)}</text>`);
        y += h + 8;
        break;
      }
      case 'toggle': {
        draw.push(`<rect x="${px}" y="${y}" width="${inner}" height="34" rx="8" class="w-card"/>`);
        draw.push(`<text x="${px + 10}" y="${y + 21}" class="w-text">${esc(e.text)}</text>`);
        draw.push(`<rect x="${W - px - 38}" y="${y + 9}" width="28" height="16" rx="8" class="${e.on === false ? 'w-sw-off' : 'w-sw-on'}"/>`);
        draw.push(`<circle cx="${e.on === false ? W - px - 30 : W - px - 20}" cy="${y + 17}" r="6" class="w-knob"/>`);
        y += 42;
        break;
      }
      case 'chips': {
        let cx = px;
        for (const c of e.items) {
          const cw = c.length * 6 + 18;
          if (cx + cw > W - px) break;
          draw.push(`<rect x="${cx}" y="${y}" width="${cw}" height="22" rx="11" class="w-chip"/>`);
          draw.push(`<text x="${cx + cw / 2}" y="${y + 15}" text-anchor="middle" class="w-tiny">${esc(c)}</text>`);
          cx += cw + 6;
        }
        y += 32;
        break;
      }
      case 'section': {
        draw.push(`<rect x="${px}" y="${y + 2}" width="18" height="18" rx="5" class="w-avatar"/>`);
        draw.push(`<text x="${px + 26}" y="${y + 16}" class="w-bold">${esc(e.text)}</text>`);
        draw.push(`<text x="${W - px}" y="${y + 16}" text-anchor="end" class="w-small">⌄</text>`);
        y += 30;
        break;
      }
      case 'gap':
        y += e.h || 10;
        break;
      case 'fab': {
        draw.push(`<rect x="${W - px - 118}" y="${y}" width="118" height="38" rx="19" class="w-fab"/>`);
        draw.push(`<text x="${W - px - 59}" y="${y + 24}" text-anchor="middle" class="w-btn-t">+ ${esc(e.text)}</text>`);
        y += 48;
        break;
      }
    }
  }
  const H = y + 16;
  out += `<rect x="1" y="1" width="${W - 2}" height="${H - 2}" rx="22" class="w-phone"/>`;
  out += `<rect x="${W / 2 - 28}" y="9" width="56" height="6" rx="3" class="w-notch"/>`;
  out += draw.join('');
  return { svg: `<svg class="wire" viewBox="0 0 ${W} ${H}" role="img" aria-label="${esc(title)} wireframe" xmlns="http://www.w3.org/2000/svg">${out}</svg>`, H };
}

// Navigation map: fixed node positions, curved edges.
function renderNav(nodes, edges) {
  const w = 132, h = 36;
  const byId = Object.fromEntries(nodes.map((n) => [n.id, n]));
  let out = `<defs><marker id="nah" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" markerHeight="6" orient="auto"><path d="M0,0 L10,5 L0,10 z" class="arrowhead"/></marker></defs>`;
  for (const [a, b, label] of edges) {
    const A = byId[a], B = byId[b];
    const x1 = A.x + w, y1 = A.y + h / 2, x2 = B.x, y2 = B.y + h / 2;
    const dx = Math.max(24, Math.abs(x2 - x1) / 2);
    out += `<path d="M${x1},${y1} C${x1 + dx},${y1} ${x2 - dx},${y2} ${x2 - 1},${y2}" class="navedge" marker-end="url(#nah)"/>`;
    if (label) out += `<text x="${(x1 + x2) / 2}" y="${(y1 + y2) / 2 - 4}" text-anchor="middle" class="elabel">${esc(label)}</text>`;
  }
  for (const n of nodes) {
    out += `<rect x="${n.x}" y="${n.y}" width="${w}" height="${h}" rx="8" class="nd nd-${n.k || 'screen'}"/>`;
    const ls = wrap(n.t, 20);
    out += textBlock(ls, n.x + w / 2, n.y + (ls.length === 1 ? 22 : 15), `nt nt-${n.k || 'screen'}`, 14);
  }
  const W = Math.max(...nodes.map((n) => n.x)) + w + 12;
  const H = Math.max(...nodes.map((n) => n.y)) + h + 12;
  return `<svg class="flow nav" viewBox="0 0 ${W} ${H}" role="img" aria-label="Ekran gezinme haritası" xmlns="http://www.w3.org/2000/svg">${out}</svg>`;
}

module.exports = { renderFlow, renderWire, renderNav, esc };
