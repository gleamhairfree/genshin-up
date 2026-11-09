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
const recent = charBanners.filter(b => Date.parse(b.end.replace(' ', 'T') + 'Z') > now - 60 * 86400e3);

// Patches: first banner start per version (UTC+8 times)
const patches = new Map();
for (const b of charBanners) {
  if (!b.version) continue;
  if (!patches.has(b.version) || b.start < patches.get(b.version)) patches.set(b.version, b.start);
}

const overrides = overridesFile && fs.existsSync(overridesFile) ? JSON.parse(fs.readFileSync(overridesFile, 'utf8')) : {};

const out = {
  schema: 1,
  generated: new Date().toISOString(),
  charactersRaw: [...chars.values()].sort().join('\n'),
  booksRaw: [...books.entries()].sort((a, b) => a[1].group - b[1].group || a[0].localeCompare(b[0]))
    .map(([id, b]) => `${id}|${b.name}|${b.region || 'Other'}|${b.group}|${b.domain}`).join('\n'),
  materialsRaw: materials.sort().join('\n'),
  itemsRaw: items.join('\n'),
  weaponsRaw: weapons.sort().join('\n'),
  weaponDomainDaysRaw: [...domainDays.entries()].sort().map(([k, v]) => `${k}|${v}`).join('\n'),
  weaponExp,
  banners: recent,
  patches: [...patches.entries()].map(([version, start]) => ({ version, start }))
    .sort((a, b) => a.start.localeCompare(b.start)).slice(-12),
  income: overrides.income || {},
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
