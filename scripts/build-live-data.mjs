// Builds data/live.json – the game data the app downloads so it keeps up with new versions
// without a reinstall. Sources (all public GitHub repos):
//   Enka.Network API-docs (characters, icons), paimon.moe (materials, items, weapons, banners),
//   genshin-db (talent books, regions, domain days, numeric item ids).
// Usage: node scripts/build-live-data.mjs <enka store/gi> <paimon src/data> <genshin-db src/data/English> <out.json> [overrides.json]
import fs from 'fs';
import os from 'os';
import path from 'path';
import { pathToFileURL } from 'url';

const [enkaDir, paimonDir, gdbDir, outFile, overridesFile] = process.argv.slice(2);
if (!enkaDir || !paimonDir || !gdbDir || !outFile) {
  console.error('usage: build-live-data.mjs <enka> <paimon> <gdb> <out> [overrides]');
  process.exit(1);
}

// ---------- paimon.moe (ES modules without extensions -> copy & rewrite) ----------
const tmp = fs.mkdtempSync(path.join(os.tmpdir(), 'pm-'));
for (const f of fs.readdirSync(paimonDir)) {
  if (!f.endsWith('.js')) continue;
  const src = fs.readFileSync(path.join(paimonDir, f), 'utf8')
    .replace(/from '\.\/([A-Za-z0-9_]+)'/g, "from './$1.mjs'");
  fs.writeFileSync(path.join(tmp, f.replace(/\.js$/, '.mjs')), src);
}
const imp = async (n) => import(pathToFileURL(path.join(tmp, `${n}.mjs`)).href);
const { itemList } = await imp('itemList');
const { characters: pmChars } = await imp('characters');
const { weaponList } = await imp('weaponList');
const { weaponExp } = await imp('weaponExp');
const { banners } = await imp('banners');

// ---------- genshin-db ----------
const readDir = (sub) => {
  const dir = path.join(gdbDir, sub);
  if (!fs.existsSync(dir)) return [];
  return fs.readdirSync(dir).filter(f => f.endsWith('.json')).map(f => JSON.parse(fs.readFileSync(path.join(dir, f), 'utf8')));
};
const gdbMaterials = readDir('materials');
const gdbChars = readDir('characters');
const gdbTalents = readDir('talents');
const matByName = new Map(gdbMaterials.map(m => [m.name.toLowerCase(), m]));
const talentsByName = new Map(gdbTalents.map(t => [t.name, t]));
const gdbCharByName = new Map(gdbChars.map(c => [c.name, c]));

// ---------- Enka ----------
const avatars = JSON.parse(fs.readFileSync(path.join(enkaDir, 'avatars.json'), 'utf8'));
const locs = JSON.parse(fs.readFileSync(path.join(enkaDir, 'locs.json'), 'utf8')).en;
const EL = { Fire: 'Pyro', Water: 'Hydro', Wind: 'Anemo', Electric: 'Electro', Grass: 'Dendro', Ice: 'Cryo', Rock: 'Geo' };
const WP = { WEAPON_SWORD_ONE_HAND: 'Sword', WEAPON_CLAYMORE: 'Claymore', WEAPON_POLE: 'Polearm', WEAPON_BOW: 'Bow', WEAPON_CATALYST: 'Catalyst' };
const DAYS = { Monday: 0, Tuesday: 1, Wednesday: 2 };
const REGIONS = ['Mondstadt', 'Liyue', 'Inazuma', 'Sumeru', 'Fontaine', 'Natlan', 'Nod-Krai', 'Snezhnaya'];
const KQM = { 'Kamisato Ayaka': 'ayaka', 'Kamisato Ayato': 'ayato', 'Kaedehara Kazuha': 'kazuha', 'Arataki Itto': 'itto',
  'Sangonomiya Kokomi': 'kokomi', 'Shikanoin Heizou': 'heizou', 'Yumemizuki Mizuki': 'mizuki', 'Raiden Shogun': 'raiden',
  'Kujou Sara': 'sara', 'Kuki Shinobu': 'shinobu' };

// Talent books: from genshin-db "Teachings of X" materials.
const books = new Map(); // id -> {name, group, domain, region}
for (const m of gdbMaterials) {
  const mm = /^Teachings of (.+)$/.exec(m.name);
  if (!mm || !m.daysOfWeek) continue;
  const name = mm[1];
  books.set(name.toLowerCase(), { name, group: DAYS[m.daysOfWeek[0]] ?? 0,
    domain: (m.dropDomainName || '').replace(/^Domain of Mastery:\s*/, ''), region: '' });
}
function bookFor(charName) {
  const t = talentsByName.get(charName);
  const lvl2 = t?.costs?.lvl2 || [];
  const teach = lvl2.find(x => /^Teachings of /.test(x.name));
  return teach ? teach.name.replace(/^Teachings of /, '').toLowerCase() : '';
}

// Characters
const chars = new Map();
for (const [aid, v] of Object.entries(avatars)) {
  const base = parseInt(aid.split('-')[0], 10);
  if ([10000005, 10000007, 10000117, 10000118].includes(base) || base >= 10000900) continue;
  const name = locs[String(v.NameTextMapHash)];
  if (!name || name.includes('(') || chars.has(name)) continue;
  const icon = (v.SideIconName || '').replace(/^\/ui\/UI_AvatarIcon_Side_/, '').replace(/\.png$/, '');
  const rarity = String(v.QualityType || '').startsWith('QUALITY_ORANGE') ? 5 : 4;
  const g = gdbCharByName.get(name);
  const region = REGIONS.includes(g?.region) ? g.region : 'Other';
  const book = bookFor(name);
  if (book && books.has(book) && !books.get(book).region && region !== 'Other') books.get(book).region = region;
  const slug = KQM[name] || name.toLowerCase().replace(/ /g, '-');
  chars.set(name, [name, EL[v.Element] || '', WP[v.WeaponType] || '', rarity, region, book, icon, slug].join('|'));
}
chars.set('Traveler', 'Traveler||Sword|5|Other||PlayerGirl|');

// Character materials (paimon.moe)
const materials = [];
for (const c of Object.values(pmChars)) {
  if (!c.ascension || !c.material || !c.name) continue;
  const tot = new Map();
  for (const a of c.ascension) for (const it of a.items) {
    if (!it.item || it.item.id === 'none' || !it.amount) continue;
    tot.set(it.item.name, (tot.get(it.item.name) || 0) + it.amount);
  }
  const asc = [...tot.entries()].map(([n, v]) => `${n}:${v}`).join(';');
  if (c.name.startsWith('Traveler (')) {
    if (c.name === 'Traveler (Anemo)') materials.push(`Traveler|${asc}||`);
    continue;
  }
  const common = (c.material.material || []).map(i => i?.name ?? '').join(';');
  materials.push(`${c.name}|${asc}|${common}|${c.material.boss?.name ?? ''}`);
}

// Items (paimon id + numeric id fallback)
const items = Object.values(itemList).filter(i => i.id && i.name && !['unknown', 'none'].includes(i.id))
  .map(i => `${i.name}|${i.id}|${matByName.get(i.name.toLowerCase())?.id ?? ''}`);

// Extra icons for things paimon.moe doesn't list (foods, currencies, gadgets): normalizedname|UI icon file
const norm = (s) => s.toLowerCase().replace(/[^a-z0-9]/g, '');
const paimonNames = new Set(Object.values(itemList).map(i => norm(i.name || '')));
const extraIcons = [];
for (const f of ['foods.json', 'materials.json']) {
  const p = path.join(gdbDir, '..', 'image', f);
  if (!fs.existsSync(p)) continue;
  for (const [key, v] of Object.entries(JSON.parse(fs.readFileSync(p, 'utf8')))) {
    if (v?.filename_icon && !paimonNames.has(key)) extraIcons.push(`${key}|${v.filename_icon}`);
  }
}

// Weapons
const weapons = [];
const domainDays = new Map();
for (const w of Object.values(weaponList)) {
  if (!w.ascension || !w.name) continue;
  const phases = w.ascension.map(p => p.items.filter(i => i.item && i.amount).map(i => `${i.item.name}:${i.amount}`).join(',') + '~' + (p.mora || 0));
  weapons.push([w.name, w.type?.name ?? w.type?.id ?? '', w.rarity, w.id, phases.join(';')].join('|'));
  const first = w.ascension[0]?.items?.[0]?.item?.name;
  const m = first && matByName.get(first.toLowerCase());
  if (m?.daysOfWeek && DAYS[m.daysOfWeek[0]] !== undefined) domainDays.set(first, DAYS[m.daysOfWeek[0]]);
}

// Banners: name ids -> display names
const idToName = {};
for (const [id, c] of Object.entries(pmChars)) if (c?.name) idToName[id] = c.name;
const now = Date.now();
const charBanners = banners.characters
  .map(b => ({ name: b.name, version: b.version || '', start: b.start, end: b.end,
               timezoneDependent: !!b.timezoneDependent,
               featured: (b.featured || []).map(id => idToName[id] || id),
               featuredRare: (b.featuredRare || []).map(id => idToName[id] || id) }))
  .filter(b => b.featured.length > 0 && b.featured.length <= 3);   // skip chronicled / multi-pick banners
let recent = charBanners.filter(b => Date.parse(b.end.replace(' ', 'T') + 'Z') > now - 60 * 86400e3);

// ---------- Genshin Fandom wiki: upcoming banners appear here as soon as they're announced ----------
const UA = 'TeyvatTracker-data-bot/1.0 (+https://github.com/gleamhairfree/genshin-up)';
async function wikiApi(params) {
  const url = 'https://genshin-impact.fandom.com/api.php?' + new URLSearchParams({ format: 'json', formatversion: '2', ...params });
  const res = await fetch(url, { headers: { 'User-Agent': UA } });
  if (!res.ok) throw new Error(`wiki ${res.status}`);
  return res.json();
}
async function wikiBanners() {
  const list = await wikiApi({ action: 'query', list: 'categorymembers', cmtitle: 'Category:Character_Event_Wishes',
    cmsort: 'timestamp', cmdir: 'desc', cmlimit: '30' });
  const titles = (list.query?.categorymembers || []).map(m => m.title).filter(t => /\/\d{4}-\d{2}-\d{2}$/.test(t));
  if (!titles.length) return [];
  const pages = await wikiApi({ action: 'query', prop: 'revisions', rvprop: 'content', rvslots: 'main', titles: titles.join('|') });
  const field = (text, key) => {
    const m = new RegExp(`\\|\\s*${key}\\s*=([^\\n]*)`).exec(text);
    return m ? m[1].replace(/<!--|-->/g, '').trim() : '';
  };
  const out = [];
  for (const p of pages.query?.pages || []) {
    const text = p.revisions?.[0]?.slots?.main?.content || '';
    if (!/\|\s*type\s*=\s*Character Event/.test(text)) continue;
    const start = field(text, 'time_start').slice(0, 19);
    const end = field(text, 'time_end').slice(0, 19);
    const five = field(text, 'character_5_F').split(';').map(x => x.trim()).filter(Boolean);
    const four = field(text, 'character_4_F').split(';').map(x => x.trim()).filter(x => x && !/^Unknown/i.test(x));
    if (!/^\d{4}-\d{2}-\d{2}/.test(start) || !five.length) continue;
    out.push({ name: p.title.replace(/\/\d{4}-\d{2}-\d{2}$/, ''), start: start.length === 10 ? start + ' 00:00:00' : start,
      end: /^\d{4}-\d{2}-\d{2}/.test(end) ? (end.length === 10 ? end + ' 23:59:59' : end) : '',
      featured: five, featuredRare: four });
  }
  // Combine banners that run together (e.g. the two 5★ banners of a phase), like paimon.moe does.
  const byStart = new Map();
  for (const b of out) {
    const key = b.start.slice(0, 10);
    const g = byStart.get(key);
    if (!g) { byStart.set(key, { ...b }); continue; }
    for (const f of b.featured) if (!g.featured.includes(f)) g.featured.push(f);
    if (!g.featuredRare.length) g.featuredRare = b.featuredRare;
    if (!g.end) g.end = b.end;
  }
  return [...byStart.values()];
}

let wiki = [];
if (process.env.FETCH_WIKI === '1') {
  try { wiki = await wikiBanners(); console.log(`Wiki banners: ${wiki.map(b => b.featured.join('+') + ' @' + b.start).join(', ')}`); }
  catch (e) { console.log(`Wiki fetch failed (${e.message}); continuing with paimon.moe only.`); }
}
const sameDay = (a, b) => Math.abs(Date.parse(a.replace(' ', 'T') + 'Z') - Date.parse(b.replace(' ', 'T') + 'Z')) < 36 * 3600e3;
const patchFor = (start) => {
  const vs = charBanners.filter(b => b.version && b.start <= start).sort((a, b) => a.start.localeCompare(b.start));
  return vs.length ? vs[vs.length - 1].version : '';
};
for (const w of wiki) {
  const existing = recent.find(b => sameDay(b.start, w.start));
  if (existing) {
    if (!(existing.featuredRare || []).length && w.featuredRare.length) existing.featuredRare = w.featuredRare;
    continue;
  }
  if (w.end && Date.parse(w.end.replace(' ', 'T') + 'Z') < now - 60 * 86400e3) continue;
  // Missing end date: phases last about three weeks.
  const end = w.end || new Date(Date.parse(w.start.replace(' ', 'T') + 'Z') + 21 * 86400e3 - 3 * 3600e3).toISOString().slice(0, 19).replace('T', ' ');
  recent.push({ name: w.name, version: patchFor(w.start), start: w.start, end, timezoneDependent: false,
    featured: w.featured, featuredRare: w.featuredRare, source: 'wiki' });
}

// ---------- Redemption codes: seria's hoyo-codes API (active list) + wiki (dates, rewards) ----------
async function fetchCodes() {
  const codes = new Map();   // UPPERCASE code -> entry
  try {
    const res = await fetch('https://hoyo-codes.seria.moe/codes?game=genshin', { headers: { 'User-Agent': UA } });
    if (res.ok) {
      for (const c of (await res.json()).codes || []) {
        if (c.status !== 'OK' || !c.code) continue;
        codes.set(c.code.toUpperCase(), { code: c.code, rewards: c.rewards || '', added: '', expires: '' });
      }
    }
  } catch (e) { console.log(`hoyo-codes fetch failed: ${e.message}`); }
  try {
    const page = await wikiApi({ action: 'parse', page: 'Promotional_Code', prop: 'wikitext' });
    let text = page.parse?.wikitext || '';
    const a = text.indexOf('==Active Codes==');
    if (a >= 0) {
      text = text.slice(a + 16);
      const nextHeading = text.search(/\n==[^=]/);
      if (nextHeading > 0) text = text.slice(0, nextHeading);
    }
    text = text.replace(/<!--[\s\S]*?-->/g, '').replace(/\|\s*ref\s*=\s*<ref[\s\S]*?<\/ref>/g, '');
    const today = new Date().toISOString().slice(0, 10);
    for (const m of text.matchAll(/\{\{Code Row\s*\|([\s\S]*?)\}\}/g)) {
      const parts = m[1].split('|').map(x => x.trim());
      if (parts.some(p => /^notacode\s*=\s*yes/i.test(p))) continue;
      const pos = parts.filter(p => !/^\w+\s*=/.test(p));
      const [codeField, server, rewards, added, expires] = pos;
      if (!codeField || server === 'CN') continue;
      if (expires && /^\d{4}-\d{2}-\d{2}/.test(expires) && expires.slice(0, 10) < today) continue;
      for (const code of codeField.split(';').map(x => x.trim()).filter(x => /^[A-Za-z0-9]{6,}$/.test(x))) {
        const key = code.toUpperCase();
        const prev = codes.get(key);
        codes.set(key, { code, rewards: prev?.rewards || rewards || '', added: added || '',
          expires: /^\d{4}/.test(expires || '') ? expires : '' });
      }
    }
  } catch (e) { console.log(`wiki codes fetch failed: ${e.message}`); }
  return [...codes.values()].sort((a, b) => (b.added || '').localeCompare(a.added || ''));
}
let codes = [];
if (process.env.FETCH_WIKI === '1') {
  codes = await fetchCodes();
  console.log(`Codes: ${codes.map(c => c.code).join(', ')}`);
} else if (fs.existsSync(outFile)) {
  codes = JSON.parse(fs.readFileSync(outFile, 'utf8')).codes || [];
}

// Patches: first banner start per version (UTC+8 times)
const patches = new Map();
for (const b of charBanners) {
  if (!b.version) continue;
  if (!patches.has(b.version) || b.start < patches.get(b.version)) patches.set(b.version, b.start);
}

const overrides = overridesFile && fs.existsSync(overridesFile) ? JSON.parse(fs.readFileSync(overridesFile, 'utf8')) : {};
// Hand-entered banners (for anything both sources miss); ignored once a source has that phase.
for (const b of overrides.banners || []) {
  if (!b.start || !b.featured?.length || recent.some(r => sameDay(r.start, b.start))) continue;
  recent.push({ name: b.name || b.featured.join(' & '), version: b.version || patchFor(b.start), start: b.start,
    end: b.end || '', timezoneDependent: !!b.timezoneDependent, featured: b.featured, featuredRare: b.featuredRare || [], source: 'manual' });
}
recent.sort((a, b) => a.start.localeCompare(b.start));

const out = {
  schema: 1,
  generated: new Date().toISOString(),
  charactersRaw: [...chars.values()].sort().join('\n'),
  booksRaw: [...books.entries()].sort((a, b) => a[1].group - b[1].group || a[0].localeCompare(b[0]))
    .map(([id, b]) => `${id}|${b.name}|${b.region || 'Other'}|${b.group}|${b.domain}`).join('\n'),
  materialsRaw: materials.sort().join('\n'),
  itemsRaw: items.join('\n'),
  extraIconsRaw: [...new Set(extraIcons)].sort().join('\n'),
  weaponsRaw: weapons.sort().join('\n'),
  weaponDomainDaysRaw: [...domainDays.entries()].sort().map(([k, v]) => `${k}|${v}`).join('\n'),
  weaponExp,
  banners: recent,
  patches: [...patches.entries()].map(([version, start]) => ({ version, start }))
    .sort((a, b) => a.start.localeCompare(b.start)).slice(-12),
  income: overrides.income || {},
  codes,
  notes: overrides.notes || '',
};

// Only rewrite when something other than the timestamp changed.
if (fs.existsSync(outFile)) {
  const prev = JSON.parse(fs.readFileSync(outFile, 'utf8'));
  const strip = (o) => JSON.stringify({ ...o, generated: '' });
  if (strip(prev) === strip(out)) { console.log('No changes.'); process.exit(0); }
}
fs.mkdirSync(path.dirname(outFile), { recursive: true });
fs.writeFileSync(outFile, JSON.stringify(out, null, 1));
console.log(`Wrote ${outFile}: ${chars.size} characters, ${books.size} books, ${materials.length} material sets, ` +
  `${items.length} items, ${weapons.length} weapons, ${recent.length} banners, ${patches.size} patches`);
