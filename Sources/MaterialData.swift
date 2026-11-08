import Foundation

// Generated from paimon.moe's public data (src/data/characters.js, itemList.js).
// Format: Name|Item:Count;...|Common1;Common2;Common3|WeeklyBoss
enum MaterialData {
    static let characterMaterialsRaw = """
    Aino|Varunada Lazurite Sliver:1;Portable Bearing:168;Broken Drive Shaft:18;Varunada Lazurite Fragment:9;Precision Kuuvahki Stamping Die:46;Reinforced Drive Shaft:30;Varunada Lazurite Chunk:9;Precision Drive Shaft:36;Varunada Lazurite Gemstone:6|Broken Drive Shaft;Reinforced Drive Shaft;Precision Drive Shaft|Silken Feather
    Albedo|Prithiva Topaz Sliver:1;Cecilia:168;Divining Scroll:18;Prithiva Topaz Fragment:9;Basalt Pillar:46;Sealed Scroll:30;Prithiva Topaz Chunk:9;Forbidden Curse Scroll:36;Prithiva Topaz Gemstone:6|Divining Scroll;Sealed Scroll;Forbidden Curse Scroll|Tusk of Monoceros Caeli
    Alhaitham|Nagadus Emerald Sliver:1;Sand Grease Pupa:168;Faded Red Satin:18;Nagadus Emerald Fragment:9;Pseudo-Stamens:46;Trimmed Red Silk:30;Nagadus Emerald Chunk:9;Rich Red Brocade:36;Nagadus Emerald Gemstone:6|Faded Red Satin;Trimmed Red Silk;Rich Red Brocade|Mirror of Mushin
    Aloy|Shivada Jade Sliver:1;Crystal Marrow:168;Spectral Husk:18;Shivada Jade Fragment:9;Crystalline Bloom:46;Spectral Heart:30;Shivada Jade Chunk:9;Spectral Nucleus:36;Shivada Jade Gemstone:6|Spectral Husk;Spectral Heart;Spectral Nucleus|Molten Moment
    Alyosha|Vajrada Amethyst Sliver:1;Flockingweed:168;Chimeric Core:18;Vajrada Amethyst Fragment:9;Severed Tail of the Sky-Roamer:46;Symbiotic Chimeric Nucleus:30;Vajrada Amethyst Chunk:9;Prime Chimeric Nexus:36;Vajrada Amethyst Gemstone:6|Chimeric Core;Symbiotic Chimeric Nucleus;Prime Chimeric Nexus|Elixir of the Heretic
    Amber|Agnidus Agate Sliver:1;Small Lamp Grass:168;Firm Arrowhead:18;Agnidus Agate Fragment:9;Everflame Seed:46;Sharp Arrowhead:30;Agnidus Agate Chunk:9;Weathered Arrowhead:36;Agnidus Agate Gemstone:6|Firm Arrowhead;Sharp Arrowhead;Weathered Arrowhead|Dvalin's Sigh
    Arataki Itto|Prithiva Topaz Sliver:1;Onikabuto:168;Slime Condensate:18;Prithiva Topaz Fragment:9;Riftborn Regalia:46;Slime Secretions:30;Prithiva Topaz Chunk:9;Slime Concentrate:36;Prithiva Topaz Gemstone:6|Slime Condensate;Slime Secretions;Slime Concentrate|Ashen Heart
    Arlecchino|Agnidus Agate Sliver:1;Rainbow Rose:168;Recruit's Insignia:18;Agnidus Agate Fragment:9;Fragment of a Golden Melody:46;Sergeant's Insignia:30;Agnidus Agate Chunk:9;Lieutenant's Insignia:36;Agnidus Agate Gemstone:6|Recruit's Insignia;Sergeant's Insignia;Lieutenant's Insignia|Fading Candle
    Baizhu|Nagadus Emerald Sliver:1;Violetgrass:168;Fungal Spores:18;Nagadus Emerald Fragment:9;Evergloom Ring:46;Luminescent Pollen:30;Nagadus Emerald Chunk:9;Crystalline Cyst Dust:36;Nagadus Emerald Gemstone:6|Fungal Spores;Luminescent Pollen;Crystalline Cyst Dust|Worldspan Fern
    Barbara|Varunada Lazurite Sliver:1;Philanemo Mushroom:168;Divining Scroll:18;Varunada Lazurite Fragment:9;Cleansing Heart:46;Sealed Scroll:30;Varunada Lazurite Chunk:9;Forbidden Curse Scroll:36;Varunada Lazurite Gemstone:6|Divining Scroll;Sealed Scroll;Forbidden Curse Scroll|Ring of Boreas
    Beidou|Vajrada Amethyst Sliver:1;Noctilucous Jade:168;Treasure Hoarder Insignia:18;Vajrada Amethyst Fragment:9;Lightning Prism:46;Silver Raven Insignia:30;Vajrada Amethyst Chunk:9;Golden Raven Insignia:36;Vajrada Amethyst Gemstone:6|Treasure Hoarder Insignia;Silver Raven Insignia;Golden Raven Insignia|Dvalin's Sigh
    Bennett|Agnidus Agate Sliver:1;Windwheel Aster:168;Treasure Hoarder Insignia:18;Agnidus Agate Fragment:9;Everflame Seed:46;Silver Raven Insignia:30;Agnidus Agate Chunk:9;Golden Raven Insignia:36;Agnidus Agate Gemstone:6|Treasure Hoarder Insignia;Silver Raven Insignia;Golden Raven Insignia|Dvalin's Plume
    Candace|Varunada Lazurite Sliver:1;Henna Berry:168;Faded Red Satin:18;Varunada Lazurite Fragment:9;Light Guiding Tetrahedron:46;Trimmed Red Silk:30;Varunada Lazurite Chunk:9;Rich Red Brocade:36;Varunada Lazurite Gemstone:6|Faded Red Satin;Trimmed Red Silk;Rich Red Brocade|Tears of the Calamitous God
    Charlotte|Shivada Jade Sliver:1;Beryl Conch:168;Meshing Gear:18;Shivada Jade Fragment:9;"Tourbillon Device":46;Mechanical Spur Gear:30;Shivada Jade Chunk:9;Artificed Dynamic Gear:36;Shivada Jade Gemstone:6|Meshing Gear;Mechanical Spur Gear;Artificed Dynamic Gear|Lightless Silk String
    Chasca|Vayuda Turquoise Sliver:1;Withering Purpurbloom:168;Juvenile Fang:18;Vayuda Turquoise Fragment:9;Ensnaring Gaze:46;Seasoned Fang:30;Vayuda Turquoise Chunk:9;Tyrant's Fang:36;Vayuda Turquoise Gemstone:6|Juvenile Fang;Seasoned Fang;Tyrant's Fang|Silken Feather
    Chevreuse|Agnidus Agate Sliver:1;Lumidouce Bell:168;Meshing Gear:18;Agnidus Agate Fragment:9;Fontemer Unihorn:46;Mechanical Spur Gear:30;Agnidus Agate Chunk:9;Artificed Dynamic Gear:36;Agnidus Agate Gemstone:6|Meshing Gear;Mechanical Spur Gear;Artificed Dynamic Gear|Lightless Eye of the Maelstrom
    Chiori|Prithiva Topaz Sliver:1;Dendrobium:168;Spectral Husk:18;Prithiva Topaz Fragment:9;Artificed Spare Clockwork Component — Coppelius:46;Spectral Heart:30;Prithiva Topaz Chunk:9;Spectral Nucleus:36;Prithiva Topaz Gemstone:6|Spectral Husk;Spectral Heart;Spectral Nucleus|Lightless Silk String
    Chongyun|Shivada Jade Sliver:1;Cor Lapis:168;Damaged Mask:18;Shivada Jade Fragment:9;Hoarfrost Core:46;Stained Mask:30;Shivada Jade Chunk:9;Ominous Mask:36;Shivada Jade Gemstone:6|Damaged Mask;Stained Mask;Ominous Mask|Dvalin's Sigh
    Citlali|Shivada Jade Sliver:1;Quenepa Berry:168;Juvenile Fang:18;Shivada Jade Fragment:9;Talisman of the Enigmatic Land:46;Seasoned Fang:30;Shivada Jade Chunk:9;Tyrant's Fang:36;Shivada Jade Gemstone:6|Juvenile Fang;Seasoned Fang;Tyrant's Fang|Denial and Judgment
    Clorinde|Vajrada Amethyst Sliver:1;Lumitoile:168;Transoceanic Pearl:18;Vajrada Amethyst Fragment:9;Fontemer Unihorn:46;Transoceanic Chunk:30;Vajrada Amethyst Chunk:9;Xenochromatic Crystal:36;Vajrada Amethyst Gemstone:6|Transoceanic Pearl;Transoceanic Chunk;Xenochromatic Crystal|Everamber
    Collei|Nagadus Emerald Sliver:1;Rukkhashava Mushrooms:168;Firm Arrowhead:18;Nagadus Emerald Fragment:9;Majestic Hooked Beak:46;Sharp Arrowhead:30;Nagadus Emerald Chunk:9;Weathered Arrowhead:36;Nagadus Emerald Gemstone:6|Firm Arrowhead;Sharp Arrowhead;Weathered Arrowhead|Tears of the Calamitous God
    Columbina|Varunada Lazurite Sliver:1;Winter Icelea:168;Slime Condensate:18;Varunada Lazurite Fragment:9;Radiant Antler:46;Slime Secretions:30;Varunada Lazurite Chunk:9;Slime Concentrate:36;Varunada Lazurite Gemstone:6|Slime Condensate;Slime Secretions;Slime Concentrate|Mask of the Virtuous Doctor
    Cyno|Vajrada Amethyst Sliver:1;Scarab:168;Divining Scroll:18;Vajrada Amethyst Fragment:9;Thunderclap Fruitcore:46;Sealed Scroll:30;Vajrada Amethyst Chunk:9;Forbidden Curse Scroll:36;Vajrada Amethyst Gemstone:6|Divining Scroll;Sealed Scroll;Forbidden Curse Scroll|Mudra of the Malefic General
    Dahlia|Varunada Lazurite Sliver:1;Calla Lily:168;Firm Arrowhead:18;Varunada Lazurite Fragment:9;Secret Source Airflow Accumulator:46;Sharp Arrowhead:30;Varunada Lazurite Chunk:9;Weathered Arrowhead:36;Varunada Lazurite Gemstone:6|Firm Arrowhead;Sharp Arrowhead;Weathered Arrowhead|Eroded Scale-Feather
    Dehya|Agnidus Agate Sliver:1;Sand Grease Pupa:168;Faded Red Satin:18;Agnidus Agate Fragment:9;Light Guiding Tetrahedron:46;Trimmed Red Silk:30;Agnidus Agate Chunk:9;Rich Red Brocade:36;Agnidus Agate Gemstone:6|Faded Red Satin;Trimmed Red Silk;Rich Red Brocade|Puppet Strings
    Diluc|Agnidus Agate Sliver:1;Small Lamp Grass:168;Recruit's Insignia:18;Agnidus Agate Fragment:9;Everflame Seed:46;Sergeant's Insignia:30;Agnidus Agate Chunk:9;Lieutenant's Insignia:36;Agnidus Agate Gemstone:6|Recruit's Insignia;Sergeant's Insignia;Lieutenant's Insignia|Dvalin's Plume
    Diona|Shivada Jade Sliver:1;Calla Lily:168;Firm Arrowhead:18;Shivada Jade Fragment:9;Hoarfrost Core:46;Sharp Arrowhead:30;Shivada Jade Chunk:9;Weathered Arrowhead:36;Shivada Jade Gemstone:6|Firm Arrowhead;Sharp Arrowhead;Weathered Arrowhead|Shard of a Foul Legacy
    Dori|Vajrada Amethyst Sliver:1;Kalpalata Lotus:168;Faded Red Satin:18;Vajrada Amethyst Fragment:9;Thunderclap Fruitcore:46;Trimmed Red Silk:30;Vajrada Amethyst Chunk:9;Rich Red Brocade:36;Vajrada Amethyst Gemstone:6|Faded Red Satin;Trimmed Red Silk;Rich Red Brocade|Bloodjade Branch
    Durin|Agnidus Agate Sliver:1;Frostlamp Flower:168;Tattered Warrant:18;Agnidus Agate Fragment:9;Cyclic Military Kuuvahki Core:46;Immaculate Warrant:30;Agnidus Agate Chunk:9;Frost-Etched Warrant:36;Agnidus Agate Gemstone:6|Tattered Warrant;Immaculate Warrant;Frost-Etched Warrant|Eroded Sunfire
    Emilie|Nagadus Emerald Sliver:1;Lakelight Lily:168;Meshing Gear:18;Nagadus Emerald Fragment:9;Fragment of a Golden Melody:46;Mechanical Spur Gear:30;Nagadus Emerald Chunk:9;Artificed Dynamic Gear:36;Nagadus Emerald Gemstone:6|Meshing Gear;Mechanical Spur Gear;Artificed Dynamic Gear|Silken Feather
    Escoffier|Shivada Jade Sliver:1;Beryl Conch:168;Meshing Gear:18;Shivada Jade Fragment:9;Secret Source Airflow Accumulator:46;Mechanical Spur Gear:30;Shivada Jade Chunk:9;Artificed Dynamic Gear:36;Shivada Jade Gemstone:6|Meshing Gear;Mechanical Spur Gear;Artificed Dynamic Gear|Eroded Horn
    Eula|Shivada Jade Sliver:1;Dandelion Seed:168;Damaged Mask:18;Shivada Jade Fragment:9;Crystalline Bloom:46;Stained Mask:30;Shivada Jade Chunk:9;Ominous Mask:36;Shivada Jade Gemstone:6|Damaged Mask;Stained Mask;Ominous Mask|Dragon Lord's Crown
    Faruzan|Vayuda Turquoise Sliver:1;Henna Berry:168;Faded Red Satin:18;Vayuda Turquoise Fragment:9;Light Guiding Tetrahedron:46;Trimmed Red Silk:30;Vayuda Turquoise Chunk:9;Rich Red Brocade:36;Vayuda Turquoise Gemstone:6|Faded Red Satin;Trimmed Red Silk;Rich Red Brocade|Puppet Strings
    Fischl|Vajrada Amethyst Sliver:1;Small Lamp Grass:168;Firm Arrowhead:18;Vajrada Amethyst Fragment:9;Lightning Prism:46;Sharp Arrowhead:30;Vajrada Amethyst Chunk:9;Weathered Arrowhead:36;Vajrada Amethyst Gemstone:6|Firm Arrowhead;Sharp Arrowhead;Weathered Arrowhead|Spirit Locket of Boreas
    Flins|Vajrada Amethyst Sliver:1;Frostlamp Flower:168;Broken Drive Shaft:18;Vajrada Amethyst Fragment:9;Precision Kuuvahki Stamping Die:46;Reinforced Drive Shaft:30;Vajrada Amethyst Chunk:9;Precision Drive Shaft:36;Vajrada Amethyst Gemstone:6|Broken Drive Shaft;Reinforced Drive Shaft;Precision Drive Shaft|Ascended Sample: Queen
    Freminet|Shivada Jade Sliver:1;Romaritime Flower:168;Transoceanic Pearl:18;Shivada Jade Fragment:9;Artificed Spare Clockwork Component — Coppelius:46;Transoceanic Chunk:30;Shivada Jade Chunk:9;Xenochromatic Crystal:36;Shivada Jade Gemstone:6|Transoceanic Pearl;Transoceanic Chunk;Xenochromatic Crystal|Worldspan Fern
    Furina|Varunada Lazurite Sliver:1;Lakelight Lily:168;Whopperflower Nectar:18;Varunada Lazurite Fragment:9;Water That Failed To Transcend:46;Shimmering Nectar:30;Varunada Lazurite Chunk:9;Energy Nectar:36;Varunada Lazurite Gemstone:6|Whopperflower Nectar;Shimmering Nectar;Energy Nectar|Lightless Mass
    Gaming|Agnidus Agate Sliver:1;Starconch:168;Slime Condensate:18;Agnidus Agate Fragment:9;Emperor's Resolution:46;Slime Secretions:30;Agnidus Agate Chunk:9;Slime Concentrate:36;Agnidus Agate Gemstone:6|Slime Condensate;Slime Secretions;Slime Concentrate|Lightless Mass
    Ganyu|Shivada Jade Sliver:1;Qingxin:168;Whopperflower Nectar:18;Shivada Jade Fragment:9;Hoarfrost Core:46;Shimmering Nectar:30;Shivada Jade Chunk:9;Energy Nectar:36;Shivada Jade Gemstone:6|Whopperflower Nectar;Shimmering Nectar;Energy Nectar|Shadow of the Warrior
    Gorou|Prithiva Topaz Sliver:1;Sango Pearl:168;Spectral Husk:18;Prithiva Topaz Fragment:9;Perpetual Heart:46;Spectral Heart:30;Prithiva Topaz Chunk:9;Spectral Nucleus:36;Prithiva Topaz Gemstone:6|Spectral Husk;Spectral Heart;Spectral Nucleus|Molten Moment
    Hu Tao|Agnidus Agate Sliver:1;Silk Flower:168;Whopperflower Nectar:18;Agnidus Agate Fragment:9;Juvenile Jade:46;Shimmering Nectar:30;Agnidus Agate Chunk:9;Energy Nectar:36;Agnidus Agate Gemstone:6|Whopperflower Nectar;Shimmering Nectar;Energy Nectar|Shard of a Foul Legacy
    Iansan|Vajrada Amethyst Sliver:1;Dracolite:168;Sentry's Wooden Whistle:18;Vajrada Amethyst Fragment:9;Ensnaring Gaze:46;Warrior's Metal Whistle:30;Vajrada Amethyst Chunk:9;Saurian-Crowned Warrior's Golden Whistle:36;Vajrada Amethyst Gemstone:6|Sentry's Wooden Whistle;Warrior's Metal Whistle;Saurian-Crowned Warrior's Golden Whistle|Denial and Judgment
    Ifa|Vayuda Turquoise Sliver:1;Saurian Claw Succulent:168;Juvenile Fang:18;Vayuda Turquoise Fragment:9;Sparkless Statue Core:46;Seasoned Fang:30;Vayuda Turquoise Chunk:9;Tyrant's Fang:36;Vayuda Turquoise Gemstone:6|Juvenile Fang;Seasoned Fang;Tyrant's Fang|Ascended Sample: Rook
    Illuga|Prithiva Topaz Sliver:1;Pine Amber:168;Broken Drive Shaft:18;Prithiva Topaz Fragment:9;Cyclic Military Kuuvahki Core:46;Reinforced Drive Shaft:30;Prithiva Topaz Chunk:9;Precision Drive Shaft:36;Prithiva Topaz Gemstone:6|Broken Drive Shaft;Reinforced Drive Shaft;Precision Drive Shaft|Eroded Horn
    Ineffa|Vajrada Amethyst Sliver:1;Glowing Hornshroom:168;Sentry's Wooden Whistle:18;Vajrada Amethyst Fragment:9;Secret Source Airflow Accumulator:46;Warrior's Metal Whistle:30;Vajrada Amethyst Chunk:9;Saurian-Crowned Warrior's Golden Whistle:36;Vajrada Amethyst Gemstone:6|Sentry's Wooden Whistle;Warrior's Metal Whistle;Saurian-Crowned Warrior's Golden Whistle|Eroded Sunfire
    Jahoda|Vayuda Turquoise Sliver:1;Portable Bearing:168;Broken Drive Shaft:18;Vayuda Turquoise Fragment:9;Lightbearing Scale-Feather:46;Reinforced Drive Shaft:30;Vayuda Turquoise Chunk:9;Precision Drive Shaft:36;Vayuda Turquoise Gemstone:6|Broken Drive Shaft;Reinforced Drive Shaft;Precision Drive Shaft|Ascended Sample: Knight
    Jean|Vayuda Turquoise Sliver:1;Dandelion Seed:168;Damaged Mask:18;Vayuda Turquoise Fragment:9;Hurricane Seed:46;Stained Mask:30;Vayuda Turquoise Chunk:9;Ominous Mask:36;Vayuda Turquoise Gemstone:6|Damaged Mask;Stained Mask;Ominous Mask|Dvalin's Plume
    Kachina|Prithiva Topaz Sliver:1;Quenepa Berry:168;Sentry's Wooden Whistle:18;Prithiva Topaz Fragment:9;Overripe Flamegranate:46;Warrior's Metal Whistle:30;Prithiva Topaz Chunk:9;Saurian-Crowned Warrior's Golden Whistle:36;Prithiva Topaz Gemstone:6|Sentry's Wooden Whistle;Warrior's Metal Whistle;Saurian-Crowned Warrior's Golden Whistle|Fading Candle
    Kaedehara Kazuha|Vayuda Turquoise Sliver:1;Sea Ganoderma:168;Treasure Hoarder Insignia:18;Vayuda Turquoise Fragment:9;Marionette Core:46;Silver Raven Insignia:30;Vayuda Turquoise Chunk:9;Golden Raven Insignia:36;Vayuda Turquoise Gemstone:6|Treasure Hoarder Insignia;Silver Raven Insignia;Golden Raven Insignia|Gilded Scale
    Kaeya|Shivada Jade Sliver:1;Calla Lily:168;Treasure Hoarder Insignia:18;Shivada Jade Fragment:9;Hoarfrost Core:46;Silver Raven Insignia:30;Shivada Jade Chunk:9;Golden Raven Insignia:36;Shivada Jade Gemstone:6|Treasure Hoarder Insignia;Silver Raven Insignia;Golden Raven Insignia|Spirit Locket of Boreas
    Kamisato Ayaka|Shivada Jade Sliver:1;Sakura Bloom:168;Old Handguard:18;Shivada Jade Fragment:9;Perpetual Heart:46;Kageuchi Handguard:30;Shivada Jade Chunk:9;Famed Handguard:36;Shivada Jade Gemstone:6|Old Handguard;Kageuchi Handguard;Famed Handguard|Bloodjade Branch
    Kamisato Ayato|Varunada Lazurite Sliver:1;Sakura Bloom:168;Old Handguard:18;Varunada Lazurite Fragment:9;Dew of Repudiation:46;Kageuchi Handguard:30;Varunada Lazurite Chunk:9;Famed Handguard:36;Varunada Lazurite Gemstone:6|Old Handguard;Kageuchi Handguard;Famed Handguard|Mudra of the Malefic General
    Kaveh|Nagadus Emerald Sliver:1;Mourning Flower:168;Fungal Spores:18;Nagadus Emerald Fragment:9;Quelled Creeper:46;Luminescent Pollen:30;Nagadus Emerald Chunk:9;Crystalline Cyst Dust:36;Nagadus Emerald Gemstone:6|Fungal Spores;Luminescent Pollen;Crystalline Cyst Dust|Primordial Greenbloom
    Keqing|Vajrada Amethyst Sliver:1;Cor Lapis:168;Whopperflower Nectar:18;Vajrada Amethyst Fragment:9;Lightning Prism:46;Shimmering Nectar:30;Vajrada Amethyst Chunk:9;Energy Nectar:36;Vajrada Amethyst Gemstone:6|Whopperflower Nectar;Shimmering Nectar;Energy Nectar|Ring of Boreas
    Kinich|Nagadus Emerald Sliver:1;Saurian Claw Succulent:168;Juvenile Fang:18;Nagadus Emerald Fragment:9;Overripe Flamegranate:46;Seasoned Fang:30;Nagadus Emerald Chunk:9;Tyrant's Fang:36;Nagadus Emerald Gemstone:6|Juvenile Fang;Seasoned Fang;Tyrant's Fang|Denial and Judgment
    Kirara|Nagadus Emerald Sliver:1;Amakumo Fruit:168;Spectral Husk:18;Nagadus Emerald Fragment:9;Evergloom Ring:46;Spectral Heart:30;Nagadus Emerald Chunk:9;Spectral Nucleus:36;Nagadus Emerald Gemstone:6|Spectral Husk;Spectral Heart;Spectral Nucleus|Everamber
    Klee|Agnidus Agate Sliver:1;Philanemo Mushroom:168;Divining Scroll:18;Agnidus Agate Fragment:9;Everflame Seed:46;Sealed Scroll:30;Agnidus Agate Chunk:9;Forbidden Curse Scroll:36;Agnidus Agate Gemstone:6|Divining Scroll;Sealed Scroll;Forbidden Curse Scroll|Ring of Boreas
    Kujou Sara|Vajrada Amethyst Sliver:1;Dendrobium:168;Damaged Mask:18;Vajrada Amethyst Fragment:9;Storm Beads:46;Stained Mask:30;Vajrada Amethyst Chunk:9;Ominous Mask:36;Vajrada Amethyst Gemstone:6|Damaged Mask;Stained Mask;Ominous Mask|Ashen Heart
    Kuki Shinobu|Vajrada Amethyst Sliver:1;Naku Weed:168;Spectral Husk:18;Vajrada Amethyst Fragment:9;Runic Fang:46;Spectral Heart:30;Vajrada Amethyst Chunk:9;Spectral Nucleus:36;Vajrada Amethyst Gemstone:6|Spectral Husk;Spectral Heart;Spectral Nucleus|Tears of the Calamitous God
    Lan Yan|Vayuda Turquoise Sliver:1;Clearwater Jade:168;Whopperflower Nectar:18;Vayuda Turquoise Fragment:9;Gold-Inscribed Secret Source Core:46;Shimmering Nectar:30;Vayuda Turquoise Chunk:9;Energy Nectar:36;Vayuda Turquoise Gemstone:6|Whopperflower Nectar;Shimmering Nectar;Energy Nectar|Eroded Sunfire
    Lauma|Nagadus Emerald Sliver:1;Moonfall Silver:168;Tattered Warrant:18;Nagadus Emerald Fragment:9;Lightbearing Scale-Feather:46;Immaculate Warrant:30;Nagadus Emerald Chunk:9;Frost-Etched Warrant:36;Nagadus Emerald Gemstone:6|Tattered Warrant;Immaculate Warrant;Frost-Etched Warrant|Eroded Scale-Feather
    Layla|Shivada Jade Sliver:1;Nilotpala Lotus:168;Divining Scroll:18;Shivada Jade Fragment:9;Perpetual Caliber:46;Sealed Scroll:30;Shivada Jade Chunk:9;Forbidden Curse Scroll:36;Shivada Jade Gemstone:6|Divining Scroll;Sealed Scroll;Forbidden Curse Scroll|Mirror of Mushin
    Linnea|Prithiva Topaz Sliver:1;Etherwing Moth:168;Tattered Warrant:18;Prithiva Topaz Fragment:9;Plume of the Fallen Watcher:46;Immaculate Warrant:30;Prithiva Topaz Chunk:9;Frost-Etched Warrant:36;Prithiva Topaz Gemstone:6|Tattered Warrant;Immaculate Warrant;Frost-Etched Warrant|Elixir of the Heretic
    Lisa|Vajrada Amethyst Sliver:1;Valberry:168;Slime Condensate:18;Vajrada Amethyst Fragment:9;Lightning Prism:46;Slime Secretions:30;Vajrada Amethyst Chunk:9;Slime Concentrate:36;Vajrada Amethyst Gemstone:6|Slime Condensate;Slime Secretions;Slime Concentrate|Dvalin's Claw
    Lohen|Shivada Jade Sliver:1;Etherwing Moth:168;Firm Arrowhead:18;Shivada Jade Fragment:9;Prismatic Severed Tail:46;Sharp Arrowhead:30;Shivada Jade Chunk:9;Weathered Arrowhead:36;Shivada Jade Gemstone:6|Firm Arrowhead;Sharp Arrowhead;Weathered Arrowhead|Ascended Sample: Knight
    Lynette|Vayuda Turquoise Sliver:1;Lumidouce Bell:168;Meshing Gear:18;Vayuda Turquoise Fragment:9;Artificed Spare Clockwork Component — Coppelius:46;Mechanical Spur Gear:30;Vayuda Turquoise Chunk:9;Artificed Dynamic Gear:36;Vayuda Turquoise Gemstone:6|Meshing Gear;Mechanical Spur Gear;Artificed Dynamic Gear|Everamber
    Lyney|Agnidus Agate Sliver:1;Rainbow Rose:168;Recruit's Insignia:18;Agnidus Agate Fragment:9;Emperor's Resolution:46;Sergeant's Insignia:30;Agnidus Agate Chunk:9;Lieutenant's Insignia:36;Agnidus Agate Gemstone:6|Recruit's Insignia;Sergeant's Insignia;Lieutenant's Insignia|Primordial Greenbloom
    Mavuika|Agnidus Agate Sliver:1;Withering Purpurbloom:168;Sentry's Wooden Whistle:18;Agnidus Agate Fragment:9;Gold-Inscribed Secret Source Core:46;Warrior's Metal Whistle:30;Agnidus Agate Chunk:9;Saurian-Crowned Warrior's Golden Whistle:36;Agnidus Agate Gemstone:6|Sentry's Wooden Whistle;Warrior's Metal Whistle;Saurian-Crowned Warrior's Golden Whistle|Eroded Horn
    Mika|Shivada Jade Sliver:1;Wolfhook:168;Recruit's Insignia:18;Shivada Jade Fragment:9;Pseudo-Stamens:46;Sergeant's Insignia:30;Shivada Jade Chunk:9;Lieutenant's Insignia:36;Shivada Jade Gemstone:6|Recruit's Insignia;Sergeant's Insignia;Lieutenant's Insignia|Mirror of Mushin
    Mitya|Vajrada Amethyst Sliver:1;Kristallfold:168;Chimeric Core:18;Vajrada Amethyst Fragment:9;Shattered Stability Anchor:46;Symbiotic Chimeric Nucleus:30;Vajrada Amethyst Chunk:9;Prime Chimeric Nexus:36;Vajrada Amethyst Gemstone:6|Chimeric Core;Symbiotic Chimeric Nucleus;Prime Chimeric Nexus|Mask of the Virtuous Doctor
    Mona|Varunada Lazurite Sliver:1;Philanemo Mushroom:168;Whopperflower Nectar:18;Varunada Lazurite Fragment:9;Cleansing Heart:46;Shimmering Nectar:30;Varunada Lazurite Chunk:9;Energy Nectar:36;Varunada Lazurite Gemstone:6|Whopperflower Nectar;Shimmering Nectar;Energy Nectar|Ring of Boreas
    Mualani|Varunada Lazurite Sliver:1;Sprayfeather Gill:168;Sentry's Wooden Whistle:18;Varunada Lazurite Fragment:9;Mark of the Binding Blessing:46;Warrior's Metal Whistle:30;Varunada Lazurite Chunk:9;Saurian-Crowned Warrior's Golden Whistle:36;Varunada Lazurite Gemstone:6|Sentry's Wooden Whistle;Warrior's Metal Whistle;Saurian-Crowned Warrior's Golden Whistle|Lightless Mass
    Nahida|Nagadus Emerald Sliver:1;Kalpalata Lotus:168;Fungal Spores:18;Nagadus Emerald Fragment:9;Quelled Creeper:46;Luminescent Pollen:30;Nagadus Emerald Chunk:9;Crystalline Cyst Dust:36;Nagadus Emerald Gemstone:6|Fungal Spores;Luminescent Pollen;Crystalline Cyst Dust|Puppet Strings
    Navia|Prithiva Topaz Sliver:1;Spring of the First Dewdrop:168;Transoceanic Pearl:18;Prithiva Topaz Fragment:9;Artificed Spare Clockwork Component — Coppelius:46;Transoceanic Chunk:30;Prithiva Topaz Chunk:9;Xenochromatic Crystal:36;Prithiva Topaz Gemstone:6|Transoceanic Pearl;Transoceanic Chunk;Xenochromatic Crystal|Lightless Silk String
    Nefer|Nagadus Emerald Sliver:1;Moonfall Silver:168;Tattered Warrant:18;Nagadus Emerald Fragment:9;Radiant Antler:46;Immaculate Warrant:30;Nagadus Emerald Chunk:9;Frost-Etched Warrant:36;Nagadus Emerald Gemstone:6|Tattered Warrant;Immaculate Warrant;Frost-Etched Warrant|Ascended Sample: Rook
    Neuvillette|Varunada Lazurite Sliver:1;Lumitoile:168;Transoceanic Pearl:18;Varunada Lazurite Fragment:9;Fontemer Unihorn:46;Transoceanic Chunk:30;Varunada Lazurite Chunk:9;Xenochromatic Crystal:36;Varunada Lazurite Gemstone:6|Transoceanic Pearl;Transoceanic Chunk;Xenochromatic Crystal|Everamber
    Nicole|Agnidus Agate Sliver:1;Pine Amber:168;Tattered Warrant:18;Agnidus Agate Fragment:9;Remnant of the Dreadwing:46;Immaculate Warrant:30;Agnidus Agate Chunk:9;Frost-Etched Warrant:36;Agnidus Agate Gemstone:6|Tattered Warrant;Immaculate Warrant;Frost-Etched Warrant|Counterfeit Resin
    Nilou|Varunada Lazurite Sliver:1;Padisarah:168;Fungal Spores:18;Varunada Lazurite Fragment:9;Perpetual Caliber:46;Luminescent Pollen:30;Varunada Lazurite Chunk:9;Crystalline Cyst Dust:36;Varunada Lazurite Gemstone:6|Fungal Spores;Luminescent Pollen;Crystalline Cyst Dust|Tears of the Calamitous God
    Ningguang|Prithiva Topaz Sliver:1;Glaze Lily:168;Recruit's Insignia:18;Prithiva Topaz Fragment:9;Basalt Pillar:46;Sergeant's Insignia:30;Prithiva Topaz Chunk:9;Lieutenant's Insignia:36;Prithiva Topaz Gemstone:6|Recruit's Insignia;Sergeant's Insignia;Lieutenant's Insignia|Spirit Locket of Boreas
    Noelle|Prithiva Topaz Sliver:1;Valberry:168;Damaged Mask:18;Prithiva Topaz Fragment:9;Basalt Pillar:46;Stained Mask:30;Prithiva Topaz Chunk:9;Ominous Mask:36;Prithiva Topaz Gemstone:6|Damaged Mask;Stained Mask;Ominous Mask|Dvalin's Claw
    Odette|Shivada Jade Sliver:1;Frostfairy Flower:168;Ethereal Glimmershard:18;Shivada Jade Fragment:9;Unscorched Blossom Branch:46;Ethereal Crystal:30;Shivada Jade Chunk:9;Ethereal Crystalscale Stone:36;Shivada Jade Gemstone:6|Ethereal Glimmershard;Ethereal Crystal;Ethereal Crystalscale Stone|Twisted Withered Branch
    Ororon|Vajrada Amethyst Sliver:1;Glowing Hornshroom:168;Juvenile Fang:18;Vajrada Amethyst Fragment:9;Mark of the Binding Blessing:46;Seasoned Fang:30;Vajrada Amethyst Chunk:9;Tyrant's Fang:36;Vajrada Amethyst Gemstone:6|Juvenile Fang;Seasoned Fang;Tyrant's Fang|Lightless Silk String
    Prune|Vayuda Turquoise Sliver:1;Winter Icelea:168;Treasure Hoarder Insignia:18;Vayuda Turquoise Fragment:9;Radiant Antler:46;Silver Raven Insignia:30;Vayuda Turquoise Chunk:9;Golden Raven Insignia:36;Vayuda Turquoise Gemstone:6|Treasure Hoarder Insignia;Silver Raven Insignia;Golden Raven Insignia|Mask of the Virtuous Doctor
    Qiqi|Shivada Jade Sliver:1;Violetgrass:168;Divining Scroll:18;Shivada Jade Fragment:9;Hoarfrost Core:46;Sealed Scroll:30;Shivada Jade Chunk:9;Forbidden Curse Scroll:36;Shivada Jade Gemstone:6|Divining Scroll;Sealed Scroll;Forbidden Curse Scroll|Tail of Boreas
    Raiden Shogun|Vajrada Amethyst Sliver:1;Amakumo Fruit:168;Old Handguard:18;Vajrada Amethyst Fragment:9;Storm Beads:46;Kageuchi Handguard:30;Vajrada Amethyst Chunk:9;Famed Handguard:36;Vajrada Amethyst Gemstone:6|Old Handguard;Kageuchi Handguard;Famed Handguard|Molten Moment
    Razor|Vajrada Amethyst Sliver:1;Wolfhook:168;Damaged Mask:18;Vajrada Amethyst Fragment:9;Lightning Prism:46;Stained Mask:30;Vajrada Amethyst Chunk:9;Ominous Mask:36;Vajrada Amethyst Gemstone:6|Damaged Mask;Stained Mask;Ominous Mask|Dvalin's Claw
    Rosaria|Shivada Jade Sliver:1;Valberry:168;Recruit's Insignia:18;Shivada Jade Fragment:9;Hoarfrost Core:46;Sergeant's Insignia:30;Shivada Jade Chunk:9;Lieutenant's Insignia:36;Shivada Jade Gemstone:6|Recruit's Insignia;Sergeant's Insignia;Lieutenant's Insignia|Shadow of the Warrior
    Sandrone|Shivada Jade Sliver:1;Subdetection Unit:168;Broken Drive Shaft:18;Shivada Jade Fragment:9;Plume of the Fallen Watcher:46;Reinforced Drive Shaft:30;Shivada Jade Chunk:9;Precision Drive Shaft:36;Shivada Jade Gemstone:6|Broken Drive Shaft;Reinforced Drive Shaft;Precision Drive Shaft|Madman's Restraint
    Sangonomiya Kokomi|Varunada Lazurite Sliver:1;Sango Pearl:168;Spectral Husk:18;Varunada Lazurite Fragment:9;Dew of Repudiation:46;Spectral Heart:30;Varunada Lazurite Chunk:9;Spectral Nucleus:36;Varunada Lazurite Gemstone:6|Spectral Husk;Spectral Heart;Spectral Nucleus|Hellfire Butterfly
    Sayu|Vayuda Turquoise Sliver:1;Crystal Marrow:168;Whopperflower Nectar:18;Vayuda Turquoise Fragment:9;Marionette Core:46;Shimmering Nectar:30;Vayuda Turquoise Chunk:9;Energy Nectar:36;Vayuda Turquoise Gemstone:6|Whopperflower Nectar;Shimmering Nectar;Energy Nectar|Gilded Scale
    Sethos|Vajrada Amethyst Sliver:1;Trishiraite:168;Faded Red Satin:18;Vajrada Amethyst Fragment:9;Cloudseam Scale:46;Trimmed Red Silk:30;Vajrada Amethyst Chunk:9;Rich Red Brocade:36;Vajrada Amethyst Gemstone:6|Faded Red Satin;Trimmed Red Silk;Rich Red Brocade|Daka's Bell
    Shenhe|Shivada Jade Sliver:1;Qingxin:168;Whopperflower Nectar:18;Shivada Jade Fragment:9;Dragonheir's False Fin:46;Shimmering Nectar:30;Shivada Jade Chunk:9;Energy Nectar:36;Shivada Jade Gemstone:6|Whopperflower Nectar;Shimmering Nectar;Energy Nectar|Hellfire Butterfly
    Shikanoin Heizou|Vayuda Turquoise Sliver:1;Onikabuto:168;Treasure Hoarder Insignia:18;Vayuda Turquoise Fragment:9;Runic Fang:46;Silver Raven Insignia:30;Vayuda Turquoise Chunk:9;Golden Raven Insignia:36;Vayuda Turquoise Gemstone:6|Treasure Hoarder Insignia;Silver Raven Insignia;Golden Raven Insignia|The Meaning of Aeons
    Sigewinne|Varunada Lazurite Sliver:1;Romaritime Flower:168;Transoceanic Pearl:18;Varunada Lazurite Fragment:9;Water That Failed To Transcend:46;Transoceanic Chunk:30;Varunada Lazurite Chunk:9;Xenochromatic Crystal:36;Varunada Lazurite Gemstone:6|Transoceanic Pearl;Transoceanic Chunk;Xenochromatic Crystal|Lightless Eye of the Maelstrom
    Skirk|Shivada Jade Sliver:1;Skysplit Gembloom:168;Meshing Gear:18;Shivada Jade Fragment:9;Ensnaring Gaze:46;Mechanical Spur Gear:30;Shivada Jade Chunk:9;Artificed Dynamic Gear:36;Shivada Jade Gemstone:6|Meshing Gear;Mechanical Spur Gear;Artificed Dynamic Gear|Ascended Sample: Knight
    Sucrose|Vayuda Turquoise Sliver:1;Windwheel Aster:168;Whopperflower Nectar:18;Vayuda Turquoise Fragment:9;Hurricane Seed:46;Shimmering Nectar:30;Vayuda Turquoise Chunk:9;Energy Nectar:36;Vayuda Turquoise Gemstone:6|Whopperflower Nectar;Shimmering Nectar;Energy Nectar|Spirit Locket of Boreas
    Tartaglia|Varunada Lazurite Sliver:1;Starconch:168;Recruit's Insignia:18;Varunada Lazurite Fragment:9;Cleansing Heart:46;Sergeant's Insignia:30;Varunada Lazurite Chunk:9;Lieutenant's Insignia:36;Varunada Lazurite Gemstone:6|Recruit's Insignia;Sergeant's Insignia;Lieutenant's Insignia|Shard of a Foul Legacy
    Thoma|Agnidus Agate Sliver:1;Fluorescent Fungus:168;Treasure Hoarder Insignia:18;Agnidus Agate Fragment:9;Smoldering Pearl:46;Silver Raven Insignia:30;Agnidus Agate Chunk:9;Golden Raven Insignia:36;Agnidus Agate Gemstone:6|Treasure Hoarder Insignia;Silver Raven Insignia;Golden Raven Insignia|Hellfire Butterfly
    Tighnari|Nagadus Emerald Sliver:1;Nilotpala Lotus:168;Fungal Spores:18;Nagadus Emerald Fragment:9;Majestic Hooked Beak:46;Luminescent Pollen:30;Nagadus Emerald Chunk:9;Crystalline Cyst Dust:36;Nagadus Emerald Gemstone:6|Fungal Spores;Luminescent Pollen;Crystalline Cyst Dust|The Meaning of Aeons
    Valeriy|Vajrada Amethyst Sliver:1;Fairy Wormwood:168;Ethereal Glimmershard:18;Vajrada Amethyst Fragment:9;Severed Tail of the Sky-Roamer:46;Ethereal Crystal:30;Vajrada Amethyst Chunk:9;Ethereal Crystalscale Stone:36;Vajrada Amethyst Gemstone:6|Ethereal Glimmershard;Ethereal Crystal;Ethereal Crystalscale Stone|Counterfeit Resin
    Varesa|Vajrada Amethyst Sliver:1;Skysplit Gembloom:168;Juvenile Fang:18;Vajrada Amethyst Fragment:9;Sparkless Statue Core:46;Seasoned Fang:30;Vajrada Amethyst Chunk:9;Tyrant's Fang:36;Vajrada Amethyst Gemstone:6|Juvenile Fang;Seasoned Fang;Tyrant's Fang|Eroded Scale-Feather
    Varka|Vayuda Turquoise Sliver:1;Wolfhook:168;Broken Drive Shaft:18;Vayuda Turquoise Fragment:9;Prismatic Severed Tail:46;Reinforced Drive Shaft:30;Vayuda Turquoise Chunk:9;Precision Drive Shaft:36;Vayuda Turquoise Gemstone:6|Broken Drive Shaft;Reinforced Drive Shaft;Precision Drive Shaft|Ascended Sample: Rook
    Venti|Vayuda Turquoise Sliver:1;Cecilia:168;Slime Condensate:18;Vayuda Turquoise Fragment:9;Hurricane Seed:46;Slime Secretions:30;Vayuda Turquoise Chunk:9;Slime Concentrate:36;Vayuda Turquoise Gemstone:6|Slime Condensate;Slime Secretions;Slime Concentrate|Tail of Boreas
    Vesna|Vayuda Turquoise Sliver:1;Golden Fern:168;Ethereal Glimmershard:18;Vayuda Turquoise Fragment:9;Vagabond's Cracked Armor:46;Ethereal Crystal:30;Vayuda Turquoise Chunk:9;Ethereal Crystalscale Stone:36;Vayuda Turquoise Gemstone:6|Ethereal Glimmershard;Ethereal Crystal;Ethereal Crystalscale Stone|Profaned Sprout
    Vodyanitsa|Varunada Lazurite Sliver:1;Frostfairy Flower:168;Chimeric Core:18;Varunada Lazurite Fragment:9;Unscorched Blossom Branch:46;Symbiotic Chimeric Nucleus:30;Varunada Lazurite Chunk:9;Prime Chimeric Nexus:36;Varunada Lazurite Gemstone:6|Chimeric Core;Symbiotic Chimeric Nucleus;Prime Chimeric Nexus|Madman's Restraint
    Wanderer|Vayuda Turquoise Sliver:1;Rukkhashava Mushrooms:168;Old Handguard:18;Vayuda Turquoise Fragment:9;Perpetual Caliber:46;Kageuchi Handguard:30;Vayuda Turquoise Chunk:9;Famed Handguard:36;Vayuda Turquoise Gemstone:6|Old Handguard;Kageuchi Handguard;Famed Handguard|Daka's Bell
    Wriothesley|Shivada Jade Sliver:1;Subdetection Unit:168;Meshing Gear:18;Shivada Jade Fragment:9;"Tourbillon Device":46;Mechanical Spur Gear:30;Shivada Jade Chunk:9;Artificed Dynamic Gear:36;Shivada Jade Gemstone:6|Meshing Gear;Mechanical Spur Gear;Artificed Dynamic Gear|Primordial Greenbloom
    Xiangling|Agnidus Agate Sliver:1;Jueyun Chili:168;Slime Condensate:18;Agnidus Agate Fragment:9;Everflame Seed:46;Slime Secretions:30;Agnidus Agate Chunk:9;Slime Concentrate:36;Agnidus Agate Gemstone:6|Slime Condensate;Slime Secretions;Slime Concentrate|Dvalin's Claw
    Xianyun|Vayuda Turquoise Sliver:1;Clearwater Jade:168;Divining Scroll:18;Vayuda Turquoise Fragment:9;Cloudseam Scale:46;Sealed Scroll:30;Vayuda Turquoise Chunk:9;Forbidden Curse Scroll:36;Vayuda Turquoise Gemstone:6|Divining Scroll;Sealed Scroll;Forbidden Curse Scroll|Lightless Eye of the Maelstrom
    Xiao|Vayuda Turquoise Sliver:1;Qingxin:168;Slime Condensate:18;Vayuda Turquoise Fragment:9;Juvenile Jade:46;Slime Secretions:30;Vayuda Turquoise Chunk:9;Slime Concentrate:36;Vayuda Turquoise Gemstone:6|Slime Condensate;Slime Secretions;Slime Concentrate|Shadow of the Warrior
    Xilonen|Prithiva Topaz Sliver:1;Brilliant Chrysanthemum:168;Sentry's Wooden Whistle:18;Prithiva Topaz Fragment:9;Gold-Inscribed Secret Source Core:46;Warrior's Metal Whistle:30;Prithiva Topaz Chunk:9;Saurian-Crowned Warrior's Golden Whistle:36;Prithiva Topaz Gemstone:6|Sentry's Wooden Whistle;Warrior's Metal Whistle;Saurian-Crowned Warrior's Golden Whistle|Mirror of Mushin
    Xingqiu|Varunada Lazurite Sliver:1;Silk Flower:168;Damaged Mask:18;Varunada Lazurite Fragment:9;Cleansing Heart:46;Stained Mask:30;Varunada Lazurite Chunk:9;Ominous Mask:36;Varunada Lazurite Gemstone:6|Damaged Mask;Stained Mask;Ominous Mask|Tail of Boreas
    Xinyan|Agnidus Agate Sliver:1;Violetgrass:168;Treasure Hoarder Insignia:18;Agnidus Agate Fragment:9;Everflame Seed:46;Silver Raven Insignia:30;Agnidus Agate Chunk:9;Golden Raven Insignia:36;Agnidus Agate Gemstone:6|Treasure Hoarder Insignia;Silver Raven Insignia;Golden Raven Insignia|Tusk of Monoceros Caeli
    Yae Miko|Vajrada Amethyst Sliver:1;Sea Ganoderma:168;Old Handguard:18;Vajrada Amethyst Fragment:9;Dragonheir's False Fin:46;Kageuchi Handguard:30;Vajrada Amethyst Chunk:9;Famed Handguard:36;Vajrada Amethyst Gemstone:6|Old Handguard;Kageuchi Handguard;Famed Handguard|The Meaning of Aeons
    Yanfei|Agnidus Agate Sliver:1;Noctilucous Jade:168;Treasure Hoarder Insignia:18;Agnidus Agate Fragment:9;Juvenile Jade:46;Silver Raven Insignia:30;Agnidus Agate Chunk:9;Golden Raven Insignia:36;Agnidus Agate Gemstone:6|Treasure Hoarder Insignia;Silver Raven Insignia;Golden Raven Insignia|Bloodjade Branch
    Yaoyao|Nagadus Emerald Sliver:1;Jueyun Chili:168;Slime Condensate:18;Nagadus Emerald Fragment:9;Quelled Creeper:46;Slime Secretions:30;Nagadus Emerald Chunk:9;Slime Concentrate:36;Nagadus Emerald Gemstone:6|Slime Condensate;Slime Secretions;Slime Concentrate|Daka's Bell
    Yelan|Varunada Lazurite Sliver:1;Starconch:168;Recruit's Insignia:18;Varunada Lazurite Fragment:9;Runic Fang:46;Sergeant's Insignia:30;Varunada Lazurite Chunk:9;Lieutenant's Insignia:36;Varunada Lazurite Gemstone:6|Recruit's Insignia;Sergeant's Insignia;Lieutenant's Insignia|Gilded Scale
    Yoimiya|Agnidus Agate Sliver:1;Naku Weed:168;Divining Scroll:18;Agnidus Agate Fragment:9;Smoldering Pearl:46;Sealed Scroll:30;Agnidus Agate Chunk:9;Forbidden Curse Scroll:36;Agnidus Agate Gemstone:6|Divining Scroll;Sealed Scroll;Forbidden Curse Scroll|Dragon Lord's Crown
    Yumemizuki Mizuki|Vayuda Turquoise Sliver:1;Sea Ganoderma:168;Old Handguard:18;Vayuda Turquoise Fragment:9;Talisman of the Enigmatic Land:46;Kageuchi Handguard:30;Vayuda Turquoise Chunk:9;Famed Handguard:36;Vayuda Turquoise Gemstone:6|Old Handguard;Kageuchi Handguard;Famed Handguard|Fading Candle
    Yun Jin|Prithiva Topaz Sliver:1;Glaze Lily:168;Damaged Mask:18;Prithiva Topaz Fragment:9;Riftborn Regalia:46;Stained Mask:30;Prithiva Topaz Chunk:9;Ominous Mask:36;Prithiva Topaz Gemstone:6|Damaged Mask;Stained Mask;Ominous Mask|Ashen Heart
    Zhongli|Prithiva Topaz Sliver:1;Cor Lapis:168;Slime Condensate:18;Prithiva Topaz Fragment:9;Basalt Pillar:46;Slime Secretions:30;Prithiva Topaz Chunk:9;Slime Concentrate:36;Prithiva Topaz Gemstone:6|Slime Condensate;Slime Secretions;Slime Concentrate|Tusk of Monoceros Caeli
    Zibai|Prithiva Topaz Sliver:1;Glaze Lily:168;Tattered Warrant:18;Prithiva Topaz Fragment:9;Remnant of the Dreadwing:46;Immaculate Warrant:30;Prithiva Topaz Chunk:9;Frost-Etched Warrant:36;Prithiva Topaz Gemstone:6|Tattered Warrant;Immaculate Warrant;Frost-Etched Warrant|Ascended Sample: Queen
    Traveler|Brilliant Diamond Sliver:1;Windwheel Aster:168;Damaged Mask:18;Brilliant Diamond Fragment:9;Stained Mask:30;Brilliant Diamond Chunk:9;Ominous Mask:36;Brilliant Diamond Gemstone:6||
    """

    /// Display name|paimon.moe item id|numeric game id (fallback icon)
    static let itemsRaw = """
    Mystic Enhancement Ore|mystic_enhancement_ore|104013
    Fine Enhancement Ore|fine_enhancement_ore|104012
    Enhancement Ore|enhancement_ore|104011
    1 Star Weapon|any_weapon_1|
    2 Star Weapon|any_weapon_2|
    3 Star Weapon|any_weapon_3|
    Mora|mora|202
    Hero's Wit|heros_wit|104003
    Adventurer's Experience|adventurers_experience|104002
    Wanderer's Advice|wanderes_advice|104001
    Crown of Insight|crown_of_insight|104319
    Fetters of the Dandelion Gladiator|fetters_of_the_dandelion_gladiator|114009
    Chaos Device|chaos_device|112023
    Divining Scroll|divining_scroll|112008
    Chains of the Dandelion Gladiator|chains_of_the_dandelion_gladiator|114010
    Chaos Circuit|chaos_circuit|112024
    Sealed Scroll|sealed_scroll|112009
    Shackles of the Dandelion Gladiator|shackles_of_the_dandelion_gladiator|114011
    Chaos Core|chaos_core|112025
    Forbidden Curse Scroll|forbidden_curse_scroll|112010
    Dream of the Dandelion Gladiator|dream_of_the_dandelion_gladiator|114012
    Tile of Decarabian's Tower|tile_of_decarabians_tower|114001
    Heavy Horn|heavy_horn|112014
    Firm Arrowhead|firm_arrowhead|112011
    Debris of Decarabian's City|debris_of_decarabians_city|114002
    Black Bronze Horn|black_bronze_horn|112015
    Sharp Arrowhead|sharp_arrowhead|112012
    Fragment of Decarabian's Epic|fragment_of_decarabians_epic|114003
    Black Crystal Horn|black_crystal_horn|112016
    Weathered Arrowhead|weathered_arrowhead|112013
    Scattered Piece of Decarabian's Dream|scattered_piece_of_decarabians_dream|114004
    Slime Condensate|slime_condensate|112002
    Slime Secretions|slime_secretions|112003
    Slime Concentrate|slime_concentrate|112004
    Boreal Wolf's Milk Tooth|boreal_wolfs_milk_tooth|114005
    Dead Ley Line Branch|dead_ley_line_branch|112020
    Boreal Wolf's Cracked Tooth|boreal_wolfs_cracked_tooth|114006
    Dead Ley Line Leaves|dead_ley_line_leaves|112021
    Boreal Wolf's Broken Fang|boreal_wolfs_broken_fang|114007
    Ley Line Sprouts|ley_line_sprouts|
    Boreal Wolf's Nostalgia|boreal_wolfs_nostalgia|114008
    Grain of Aerosiderite|grain_of_aerosiderite|114021
    Fragile Bone Shard|fragile_bone_shard|112041
    Damaged Mask|damaged_mask|112005
    Piece of Aerosiderite|piece_of_aerosiderite|114022
    Sturdy Bone Shard|sturdy_bone_shard|112042
    Stained Mask|stained_mask|112006
    Bit of Aerosiderite|bit_of_aerosiderite|114023
    Fossilized Bone Shard|fossilized_bone_shard|112043
    Ominous Mask|ominous_mask|112007
    Chunk of Aerosiderite|chunk_of_aerosiderite|114024
    Mist Veiled Lead Elixir|mist_veiled_lead_elixir|114017
    Mist Grass Pollen|mist_grass_pollen|112026
    Treasure Hoarder Insignia|treasure_hoarder_insignia|112035
    Mist Veiled Mercury Elixir|mist_veiled_mercury_elixir|114018
    Mist Grass|mist_grass|112027
    Silver Raven Insignia|silver_raven_insignia|112036
    Mist Veiled Gold Elixir|mist_veiled_gold_elixir|114019
    Mist Grass Wick|mist_grass_wick|112028
    Golden Raven Insignia|golden_raven_insignia|112037
    Mist Veiled Primo Elixir|mist_veiled_primo_elixir|114020
    Luminous Sands from Guyun|luminous_sands_from_guyun|114013
    Hunter's Sacrificial Knife|hunters_sacrificial_knife|112029
    Recruit's Insignia|recruits_insignia|112032
    Lustrous Stone from Guyun|lustrous_stone_from_guyun|114014
    Agent's Sacrificial Knife|agents_sacrificial_knife|112030
    Sergeant's Insignia|sergeants_insignia|112033
    Relic from Guyun|relic_from_guyun|114015
    Inspector's Sacrificial Knife|inspectors_sacrificial_knife|112031
    Lieutenant's Insignia|lieutenants_insignia|112034
    Divine Body from Guyun|divine_body_from_guyun|114016
    Whopperflower Nectar|whopperflower_nectar|112038
    Shimmering Nectar|shimmering_nectar|112039
    Energy Nectar|energy_nectar|112040
    Prithiva Topaz Sliver|prithiva_topaz_sliver|104171
    Cecilia|cecilia|100023
    Prithiva Topaz Fragment|prithiva_topaz_fragment|104172
    Basalt Pillar|basalt_pillar|113009
    Prithiva Topaz Chunk|prithiva_topaz_chunk|104173
    Prithiva Topaz Gemstone|prithiva_topaz_gemstone|104174
    Teachings of Ballad|teachings_of_ballad|104307
    Guide to Ballad|guide_to_ballad|104308
    Philosophies of Ballad|philosophies_of_ballad|104309
    Tusk of Monoceros Caeli|tusk_of_monoceros_caeli|113013
    Agnidus Agate Sliver|agnidus_agate_sliver|104111
    Small Lamp Grass|small_lamp_grass|100055
    Agnidus Agate Fragment|agnidus_agate_fragment|104112
    Everflame Seed|everflame_seed|113011
    Agnidus Agate Chunk|agnidus_agate_chunk|104113
    Agnidus Agate Gemstone|agnidus_agate_gemstone|104114
    Teachings of Freedom|teachings_of_freedom|104301
    Guide to Freedom|guide_to_freedom|104302
    Philosophies of Freedom|philosophies_of_freedom|104303
    Dvalin's Sigh|dvalins_sigh|113005
    Varunada Lazurite Sliver|varunada_lazurite_sliver|104121
    Philanemo Mushroom|philanemo_mushroom|100025
    Varunada Lazurite Fragment|varunada_lazurite_fragment|104122
    Cleansing Heart|cleansing_heart|113012
    Varunada Lazurite Chunk|varunada_lazurite_chunk|104123
    Varunada Lazurite Gemstone|varunada_lazurite_gemstone|104124
    Ring of Boreas|ring_of_boreas|113007
    Vajrada Amethyst Sliver|vajrada_amethyst_sliver|104141
    Noctilucous Jade|noctilucous_jade|100028
    Vajrada Amethyst Fragment|vajrada_amethyst_fragment|104142
    Lightning Prism|lightning_prism|113002
    Vajrada Amethyst Chunk|vajrada_amethyst_chunk|104143
    Vajrada Amethyst Gemstone|vajrada_amethyst_gemstone|104144
    Teachings of Gold|teachings_of_gold|104316
    Guide to Gold|guide_to_gold|104317
    Philosophies of Gold|philosophies_of_gold|104318
    Windwheel Aster|windwheel_aster|100024
    Teachings of Resistance|teachings_of_resistance|104304
    Guide to Resistance|guide_to_resistance|104305
    Philosophies of Resistance|philosophies_of_resistance|104306
    Dvalin's Plume|dvalins_plume|113003
    Shivada Jade Sliver|shivada_jade_sliver|104161
    Cor Lapis|cor_lapis|100058
    Shivada Jade Fragment|shivada_jade_fragment|104162
    Hoarfrost Core|hoarfrost_core|113010
    Shivada Jade Chunk|shivada_jade_chunk|104163
    Shivada Jade Gemstone|shivada_jade_gemstone|104164
    Teachings of Diligence|teachings_of_diligence|104313
    Guide to Diligence|guide_to_diligence|104314
    Philosophies of Diligence|philosophies_of_diligence|104315
    Calla Lily|calla_lily|100056
    Shard of a Foul Legacy|shard_of_a_foul_legacy|113014
    Spirit Locket of Boreas|spirit_locket_of_boreas|113008
    Vayuda Turquoise Sliver|vayuda_turquoise_sliver|104151
    Dandelion Seed|dandelion_seed|100057
    Vayuda Turquoise Fragment|vayuda_turquoise_fragment|104152
    Hurricane Seed|hurricane_seed|113001
    Vayuda Turquoise Chunk|vayuda_turquoise_chunk|104153
    Vayuda Turquoise Gemstone|vayuda_turquoise_gemstone|104154
    Teachings of Prosperity|teachings_of_prosperity|104310
    Guide to Prosperity|guide_to_prosperity|104311
    Philosophies of Prosperity|philosophies_of_prosperity|104312
    Valberry|valberry|100022
    Dvalin's Claw|dvalins_claw|113004
    Glaze Lily|glaze_lily|100030
    Violetgrass|violetgrass|100034
    Tail of Boreas|tail_of_boreas|113006
    Wolfhook|wolfhook|100021
    Starconch|starconch|100033
    Brilliant Diamond Sliver|brilliant_diamond_sliver|104101
    Brilliant Diamond Fragment|brilliant_diamond_fragment|104102
    Brilliant Diamond Chunk|brilliant_diamond_chunk|104103
    Brilliant Diamond Gemstone|brilliant_diamond_gemstone|104104
    Jueyun Chili|jueyun_chili|100027
    Silk Flower|silk_flower|100029
    Qingxin|qingxin|100031
    Shadow of the Warrior|shadow_of_the_warrior|113015
    Juvenile Jade|juvenile_jade|113016
    Bloodjade Branch|bloodjade_branch|113018
    Crystalline Bloom|crystalline_bloom|113020
    Dragon Lord's Crown|dragon_lords_crown|113017
    Sea Ganoderma|sea_ganoderma|101206
    Marionette Core|marionette_core|113022
    Gilded Scale|gilded_scale|113019
    Coral Branch of a Distant Sea|coral_branch_of_a_distant_sea|114025
    Jeweled Branch of a Distant Sea|jeweled_branch_of_a_distant_sea|114026
    Jade Branch of a Distant Sea|jade_branch_of_a_distant_sea|114027
    Golden Branch of a Golden Sea|golden_branch_of_a_distant_sea|
    Narukami's Wisdom|narukamis_wisdom|114029
    Narukami's Joy|narukamis_joy|114030
    Narukami's Affection|narukamis_affection|114031
    Narukami's Valor|narukamis_valor|114032
    Mask of the Wicked Lieutenant|mask_of_the_wicked_lieutenant|114033
    Mask of the Tiger's Bite|mask_of_the_tigers_bite|114034
    Mask of the One-Horned|mask_of_the_one_horned|114035
    Mask of the Kijin|mask_of_the_kijin|114036
    Teachings of Transience|teachings_of_transience|104320
    Guide to Transience|guide_to_transience|104321
    Philosophies of Transience|philosophies_of_transience|104322
    Teachings of Elegance|teachings_of_elegance|104323
    Guide to Elegance|guide_to_elegance|104324
    Philosophies of Elegance|philosophies_of_elegance|104325
    Teachings of Light|teachings_of_light|104326
    Guide to Light|guide_to_light|104327
    Philosophies of Light|philosophies_of_light|104328
    Perpetual Heart|perpetual_heart|113023
    Smoldering Pearl|smoldering_pearl|113024
    Old Handguard|old_handguard|112044
    Kageuchi Handguard|kageuchi_handguard|112045
    Famed Handguard|famed_handguard|112046
    Chaos Gear|chaos_gear|112047
    Chaos Axis|chaos_axis|112048
    Chaos Oculus|chaos_oculus|112049
    Dismal Prism|dismal_prism|112050
    Crystal Prism|crystal_prism|112051
    Polarizing Prism|polarizing_prism|112052
    Sakura Bloom|sakura_bloom|101202
    Crystal Marrow|crystal_marrow|101203
    Dendrobium|dendrobium|101204
    Naku Weed|naku_weed|101205
    Okinabuto|okinabuto|
    Amakumo Fruit|amakumo_fruit|101208
    Storm Beads|storm_beads|113029
    Molten Moment|molten_moment|113025
    Ashen Heart|ashen_heart|113027
    Spectral Husk|spectral_husk|112053
    Spectral Heart|spectral_heart|112054
    Spectral Nucleus|spectral_nucleus|112055
    Sango Pearl|sango_pearl|101207
    Dew of Repudiation|dew_of_repudiation|113028
    Hellfire Butterfly|hellfire_butterfly|113026
    Concealed Claw|concealed_claw|112056
    Concealed Unguis|concealed_unguis|112057
    Concealed Talon|concealed_talon|112058
    Fluorescent Fungus|fluorescent_fungus|101209
    Onikabuto|onikabuto|101201
    Riftborn Regalia|riftborn_regalia|113030
    Dragonheir's False Fin|dragonheirs_false_fin|113031
    The Meaning of Aeons|the_meaning_of_aeons|113034
    Mudra of the Malefic General|mudra_of_the_malefic_general|113032
    Gloomy Statuette|gloomy_statuette|112017
    Dark Statuette|dark_statuette|112018
    Deathly Statuette|deathly_statuette|112019
    Tears of the Calamitous God|tears_of_the_calamitous_god|113033
    Runic Fang|runic_fang|113035
    Teachings of Admonition|teachings_of_admonition|104329
    Guide to Admonition|guide_to_admonition|104330
    Philosophies of Admonition|philosophies_of_admonition|104331
    Teachings of Ingenuity|teachings_of_ingenuity|104332
    Guide to Ingenuity|guide_to_ingenuity|104333
    Philosophies of Ingenuity|philosophies_of_ingenuity|104334
    Teachings of Praxis|teachings_of_praxis|104335
    Guide to Praxis|guide_to_praxis|104336
    Philosophies of Praxis|philosophies_of_praxis|104337
    Nagadus Emerald Sliver|nagadus_emerald_sliver|104131
    Nagadus Emerald Fragment|nagadus_emerald_fragment|104132
    Nagadus Emerald Chunk|nagadus_emerald_chunk|104133
    Nagadus Emerald Gemstone|nagadus_emerald_gemstone|104134
    Majestic Hooked Beak|majestic_hooked_beak|113036
    Nilotpala Lotus|nilotpala_lotus|101215
    Kalpalata Lotus|kalpalata_lotus|101217
    Fungal Spores|fungal_spores|112059
    Luminescent Pollen|luminescent_pollen|112060
    Crystalline Cyst Dust|crystalline_cyst_dust|112061
    Rukkhashava Mushrooms|rukkhashava_mushrooms|101213
    Echo of Scorching Might|echo_of_scorching_might|114045
    Remnant Glow of Scorching Might|remnant_glow_of_scorching_might|114046
    Dream of Scorching Might|dream_of_scorching_might|114047
    Olden Days of Scorching Might|olden_days_of_scorching_might|114048
    Inactivated Fungal Nucleus|inactivated_fungal_nucleus|112062
    Dormant Fungal Nucleus|dormant_fungal_nucleus|112063
    Robust Fungal Nucleus|robust_fungal_nucleus|112064
    Faded Red Satin|faded_red_satin|112065
    Trimmed Red Silk|trimmed_red_silk|112066
    Rich Red Brocade|rich_red_brocade|112067
    Copper Talisman of the Forest Dew|copper_talisman_of_the_forest_dew|114037
    Iron Talisman of the Forest Dew|iron_talisman_of_the_forest_dew|114038
    Silver Talisman of the Forest Dew|silver_talisman_of_the_forest_dew|114039
    Golden Talisman of the Forest Dew|golden_talisman_of_the_forest_dew|114040
    Chaos Storage|chaos_storage|112068
    Chaos Module|chaos_module|112069
    Chaos Bolt|chaos_bolt|112070
    Oasis Garden's Reminiscence|oasis_gardens_reminiscence|114041
    Oasis Garden's Kindness|oasis_gardens_kindness|114042
    Oasis Garden's Mourning|oasis_gardens_mourning|114043
    Oasis Garden's Truth|oasis_gardens_truth|114044
    Thunderclap Fruitcore|thunderclap_fruitcore|113037
    Scarab|scarab|101225
    Henna Berry|henna_berry|101220
    Light Guiding Tetrahedron|light_guiding_tetrahedron|113039
    Damaged Prism|damaged_prism|112071
    Turbid Prism|turbid_prism|112072
    Radiant Prism|radiant_prism|112073
    Perpetual Caliber|perpetual_caliber|113038
    Padisarah|padisarah|101214
    Quelled Creeper|quelled_creeper|113040
    Puppet Strings|puppet_strings|113041
    Mirror of Mushin|mirror_of_mushin|113042
    Daka's Bell|dakas_bell|113043
    Pseudo-Stamens|pseudo_stamens|113044
    Sand Grease Pupa|sand_grease_pupa|101222
    Desiccated Shell|desiccated_shell|112074
    Sturdy Shell|sturdy_shell|112075
    Marked Shell|marked_shell|112076
    Mourning Flower|mourning_flower|101223
    Evergloom Ring|evergloom_ring|113045
    Worldspan Fern|worldspan_fern|113046
    Primordial Greenbloom|primordial_greenbloom|113047
    A Flower Yet to Bloom|a_flower_yet_to_bloom|112077
    Treasured Flower|treasured_flower|112078
    Wanderer's Blooming Flower|wanderers_blooming_flower|112079
    Everamber|everamber|113048
    Artificed Spare Clockwork Component — Coppelius|artificed_spare_clockwork_component_coppelius|113050
    Lumidouce Bell|lumidouce_bell|101235
    Mechanical Spur Gear|mechanical_spur_gear|112084
    Artificed Dynamic Gear|artificed_dynamic_gear|112085
    Meshing Gear|meshing_gear|112083
    Rainbow Rose|rainbow_rose|101236
    Emperor's Resolution|emperors_resolution|113051
    Teachings of Order|teachings_of_order|104344
    Guide to Order|guide_to_order|104345
    Philosophies of Order|philosophies_of_order|104346
    Teachings of Equity|teachings_of_equity|104338
    Guide to Equity|guide_to_equity|104339
    Philosophies of Equity|philosophies_of_equity|104340
    Teachings of Justice|teachings_of_justice|104341
    Guide to Justice|guide_to_justice|104342
    Philosophies of Justice|philosophies_of_justice|104343
    Fragment of an Ancient Chord|fragment_of_an_ancient_chord|114049
    Chapter of an Ancient Chord|chapter_of_an_ancient_chord|114050
    Movement of an Ancient Chord|movement_of_an_ancient_chord|114051
    Echo of an Ancient Chord|echo_of_an_ancient_chord|114052
    Transoceanic Pearl|transoceanic_pearl|112080
    Transoceanic Chunk|transoceanic_chunk|112081
    Xenochromatic Crystal|xenochromatic_crystal|112082
    Drop of Tainted Water|drop_of_tainted_water|112086
    Scoop of Tainted Water|scoop_of_tainted_water|112087
    Newborn Tainted Hydro Phantasm|newborn_tainted_hydro_phantasm|112088
    Broken Goblet of the Pristine Sea|broken_goblet_of_the_pristine_sea|114057
    Wine Goblet of the Pristine Sea|wine_goblet_of_the_pristine_sea|114058
    Silver Goblet of the Pristine Sea|silver_goblet_of_the_pristine_sea|114059
    Golden Goblet of the Pristine Sea|golden_goblet_of_the_pristine_sea|114060
    Dross of Pure Sacred Dewdrop|dross_of_pure_sacred_dewdrop|114053
    Sublimation of Pure Sacred Dewdrop|sublimation_of_pure_sacred_dewdrop|114054
    Spring of Pure Sacred Dewdrop|spring_of_pure_sacred_dewdrop|114055
    Essence of Pure Sacred Dewdrop|essence_of_pure_sacred_dewdrop|114056
    Rift Core|rift_core|112089
    Foreign Synapse|foreign_synapse|112090
    Alien Life Core|alien_life_core|112091
    Romaritime Flower|romaritime_flower|101233
    Fontemer Unihorn|fontemer_unihorn|113053
    Lumitoile|lumitoile|101237
    Old Operative's Pocket Watch|old_operatives_pocket_watch|112092
    Operative's Standard Pocket Watch|operatives_standard_pocket_watch|112093
    Operative's Constancy|operatives_constancy|112094
    Subdetection Unit|subdetection_unit|101239
    "Tourbillon Device"|tourbillon_device|113052
    Beryl Conch|beryl_conch|101232
    Lakelight Lily|lakelight_lily|101238
    Water That Failed To Transcend|water_that_failed_to_transcend|113057
    Lightless Silk String|lightless_silk_string|113054
    Lightless Mass|lightless_mass|113056
    Spring of the First Dewdrop|spring_of_the_first_dewdrop|101240
    Lightless Eye of the Maelstrom|lightless_eye_of_the_maelstrom|113055
    Cloudseam Scale|cloudseam_scale|113058
    Clearwater Jade|clearwater_jade|101241
    Feathery Fin|feathery_fin|112095
    Lunar Fin|lunar_fin|112096
    Chasmlight Fin|chasmlight_fin|112097
    Fragment of a Golden Melody|fragment_of_a_golden_melody|113059
    Fading Candle|fading_candle|113060
    Ruined Hilt|ruined_hilt|112098
    Splintered Hilt|splintered_hilt|112099
    Still-Smoldering Hilt|still_smoldering_hilt|112100
    Trishiraite|trishiraite|101224
    Silken Feather|silken_feather|113061
    Sprayfeather Gill|sprayfeather_gill|101247
    Seasoned Fang|seasoned_fang|112102
    Tyrant's Fang|tyrants_fang|112103
    Juvenile Fang|juvenile_fang|112101
    Mark of the Binding Blessing|mark_of_the_binding_blessing|113064
    Warrior's Metal Whistle|warriors_metal_whistle|112105
    Saurian-Crowned Warrior's Golden Whistle|saurian_crowned_warriors_golden_whistle|112106
    Sentry's Wooden Whistle|sentrys_wooden_whistle|112104
    Overripe Flamegranate|overripe_flamegranate|113065
    Quenepa Berry|quenepa_berry|101249
    Teachings of Contention|teachings_of_contention|104347
    Guide to Contention|guide_to_contention|104348
    Philosophies of Contention|philosophies_of_contention|104349
    Teachings of Conflict|teachings_of_conflict|104353
    Guide to Conflict|guide_to_conflict|104354
    Philosophies of Conflict|philosophies_of_conflict|104355
    Blazing Sacrificial Heart's Terror|blazing_sacrificial_hearts_terror|114061
    Blazing Sacrificial Heart's Hesitance|blazing_sacrificial_hearts_hesitance|114062
    Blazing Sacrificial Heart's Resolve|blazing_sacrificial_hearts_resolve|114063
    Blazing Sacrificial Heart's Splendor|blazing_sacrificial_hearts_splendor|114064
    Shard of a Shattered Will|shard_of_a_shattered_will|112107
    Locus of a Clear Will|locus_of_a_clear_will|112108
    Sigil of a Striding Will|sigil_of_a_striding_will|112109
    Night-Wind's Mystic Consideration|night_winds_mystic_consideration|114069
    Night-Wind's Mystic Premonition|night_winds_mystic_premonition|114070
    Night-Wind's Mystic Augury|night_winds_mystic_augury|114071
    Night-Wind's Mystic Revelation|night_winds_mystic_revelation|114072
    Axis of the Secret Source|axis_of_the_secret_source|112113
    Sheath of the Secret Source|sheath_of_the_secret_source|112114
    Heart of the Secret Source|heart_of_the_secret_source|112115
    Ignited Stone|ignited_stone|112110
    Ignited Seed of Life|ignited_seed_of_life|112111
    Ignited Seeing Eye|ignited_seeing_eye|112112
    Delirious Decadence of the Sacred Lord|delirious_decadence_of_the_sacred_lord|114065
    Delirious Desolation of the Sacred Lord|delirious_desolation_of_the_sacred_lord|114066
    Delirious Demeanor of the Sacred Lord|delirious_demeanor_of_the_sacred_lord|114067
    Delirious Divinity of the Sacred Lord|delirious_divinity_of_the_sacred_lord|114068
    Saurian Claw Succulent|saurian_claw_succulent|101250
    Denial and Judgment|denial_and_judgment|113062
    Teachings of Kindling|teachings_of_kindling|104350
    Guide to Kindling|guide_to_kindling|104351
    Philosophies of Kindling|philosophies_of_kindling|104352
    Gold-Inscribed Secret Source Core|gold_inscribed_secret_source_core|113066
    Brilliant Chrysanthemum|brilliant_chrysanthemum|101248
    Ensnaring Gaze|ensnaring_gaze|113067
    Withering Purpurbloom|withering_purpurbloom|101253
    Glowing Hornshroom|glowing_hornshroom|101252
    Refractive Bud|refractive_bud|112116
    Bewildering Broadleaf|bewildering_broadleaf|112117
    Illusory Leafcoil|illusory_leafcoil|112118
    Eroded Horn|eroded_horn|113068
    Talisman of the Enigmatic Land|talisman_of_the_enigmatic_land|113071
    Eroded Sunfire|eroded_sunfire|113069
    Dracolite|dracolite|101255
    Sparkless Statue Core|sparkless_statue_core|113072
    Skysplit Gembloom|skysplit_gembloom|101254
    Eroded Scale-Feather|eroded_scale_feather|113070
    Cold-Cracked Shellshard|cold_cracked_shellshard|112119
    Warm Back-Shell|warm_back_shell|112120
    Blazing Prismshell|blazing_prismshell|112121
    Secret Source Airflow Accumulator|secret_source_airflow_accumulator|113076
    Ascended Sample: Rook|ascended_sample_rook|113074
    Ascended Sample: Knight|ascended_sample_knight|113073
    Tattered Warrant|tattered_warrant|112125
    Immaculate Warrant|immaculate_warrant|112126
    Frost-Etched Warrant|frost_etched_warrant|112127
    Moonfall Silver|moonfall_silver|101263
    Lightbearing Scale-Feather|lightbearing_scale_feather|113078
    Teachings of Moonlight|teachings_of_moonlight|104356
    Guide to Moonlight|guide_to_moonlight|104357
    Philosophies of Moonlight|philosophies_of_moonlight|104358
    Lightless Bone|lightless_bone|112131
    Glowing Remains|glowing_remains|112132
    Radiant Exoskeleton|radiant_exoskeleton|112133
    Artful Device Fragment|artful_device_fragment|114073
    Frostnight's Glimmer|frostnights_glimmer|112128
    Broken Drive Shaft|broken_drive_shaft|112122
    Artful Device Replica|artful_device_replica|114074
    Frostnight's Glow|frostnights_glow|112129
    Reinforced Drive Shaft|reinforced_drive_shaft|112123
    Artful Device Inheritance|artful_device_inheritance|114075
    Frostnight's Glory|frostnights_glory|112130
    Precision Drive Shaft|precision_drive_shaft|112124
    Artful Device Wish|artful_device_wish|114076
    Precision Kuuvahki Stamping Die|precision_kuuvahki_stamping_die|113077
    Frostlamp Flower|frostlamp_flower|101261
    Teachings of Elysium|teachings_of_elysium|104359
    Guide to Elysium|guide_to_elysium|104360
    Philosophies of Elysium|philosophies_of_elysium|104361
    Teachings of Vagrancy|teachings_of_vagrancy|104362
    Guide to Vagrancy|guide_to_vagrancy|104363
    Philosophies of Vagrancy|philosophies_of_vagrancy|104364
    Ascended Sample: Queen|ascended_sample_queen|113075
    Portable Bearing|portable_bearing|101257
    Ember of Long Night Flint|ember_of_long_night_flint|114077
    Mistshroud Manifestation|mistshroud_manifestation|112134
    Afterglow of Long Night Flint|afterglow_of_long_night_flint|114078
    Mistshroud Plate|mistshroud_plate|112135
    Flare of Long Night Flint|flare_of_long_night_flint|114079
    Mistshroud Helmet|mistshroud_helmet|112136
    Blaze of Long Night Flint|blaze_of_long_night_flint|114080
    Radiant Antler|radiant_antler|113079
    Cyclic Military Kuuvahki Core|cyclic_military_kuuvahki_core|113080
    Winter Icelea|winter_icelea|101268
    Mask of the Virtuous Doctor|mask_of_the_virtuous_doctor|113081
    Remnant of the Dreadwing|remnant_of_the_dreadwing|113084
    Pine Amber|pine_amber|101269
    Fractured Eye of the Deep Shadow|fractured_eye_of_the_deep_shadow|112137
    Aberrant Core of the Deep Shadow|aberrant_core_of_the_deep_shadow|112138
    Hooked Beak of the Deep Shadow|hooked_beak_of_the_deep_shadow|112139
    Prismatic Severed Tail|prismatic_severed_tail|113085
    Elixir of the Heretic|elixir_of_the_heretic|113083
    Etherwing Moth|etherwing_moth|101272
    Plume of the Fallen Watcher|plume_of_the_fallen_watcher|113086
    Faded Flaming Hilt|faded_flaming_hilt|112140
    Fractured Flaming Hilt|fractured_flaming_hilt|112141
    Jeweled Flaming Hilt|jeweled_flaming_hilt|112142
    Counterfeit Resin|counterfeit_resin|113087
    The Cornerstone of Stars and Flames|the_cornerstone_of_stars_and_flames|113063
    Madman's Restraint|madmans_restraint|113082
    Sundered Glory of the Far-North Scions|sundered_glory_of_the_far_north_scions|114081
    Unyielding Delusion of the Far-North Scions|unyielding_delusion_of_the_far_north_scions|114082
    Oblation of the Far-North Scions|oblation_of_the_far_north_scions|114083
    Aureate Radiance of the Far-North Scions|aureate_radiance_of_the_far_north_scions|114084
    Fractured Lunar Iron|fractured_lunar_iron|112143
    Depleted Lunar Iron|depleted_lunar_iron|112144
    Unblemished Lunar Iron|unblemished_lunar_iron|112145
    Flockingweed|flockingweed|101276
    Symbiotic Chimeric Nucleus|symbiotic_chimeric_nucleus|112150
    Prime Chimeric Nexus|prime_chimeric_nexus|112151
    Chimeric Core|chimeric_core|112149
    Frostfairy Flower|frostfairy_flower|101275
    Severed Tail of the Sky-Roamer|severed_tail_of_the_sky_roamer|113091
    Unscorched Blossom Branch|unscorched_blossom_branch|113090
    Ethereal Crystal|ethereal_crystal|112147
    Ethereal Crystalscale Stone|ethereal_crystalscale_stone|112148
    Ethereal Glimmershard|ethereal_glimmershard|112146
    Twisted Withered Branch|twisted_withered_branch|113088
    Teachings of Charity|teachings_of_charity|104365
    Guide to Charity|guide_to_charity|104366
    Philosophies of Charity|philosophies_of_charity|104367
    Teachings of Fortitude|teachings_of_fortitude|104368
    Guide to Fortitude|guide_to_fortitude|104369
    Philosophies of Fortitude|philosophies_of_fortitude|104370
    Rise of the Pale Star Army|rise_of_the_pale_star_army|114085
    Muster of the Pale Star Army|muster_of_the_pale_star_army|114086
    Clarion of the Pale Star Army|clarion_of_the_pale_star_army|114087
    Triumph of the Pale Star Army|triumph_of_the_pale_star_army|114088
    Hollow Root of Life|hollow_root_of_life|112155
    Sprout Node of Life|sprout_node_of_life|112156
    Coiled Core of Life|coiled_core_of_life|112157
    Accreted Fragment|accreted_fragment|112152
    Accreted Mass|accreted_mass|112153
    Accreted Growth|accreted_growth|112154
    The Frost Emperor's Revival|the_frost_emperors_revival|114093
    The Frost Emperor's Ceremony|the_frost_emperors_ceremony|114094
    The Frost Emperor's Lament|the_frost_emperors_lament|114095
    The Frost Emperor's Farewell|the_frost_emperors_farewell|114096
    Measured Pour of the Cellared Spiritual Nectar|measured_pour_of_the_cellared_spiritual_nectar|114089
    Intoxication of the Cellared Spiritual Nectar|intoxication_of_the_cellared_spiritual_nectar|114090
    Exhilaration of the Cellared Spiritual Nectar|exhilaration_of_the_cellared_spiritual_nectar|114091
    Revelry of the Cellared Spiritual Nectar|revelry_of_the_cellared_spiritual_nectar|114092
    Teachings of Glory|teachings_of_glory|104371
    Guide to Glory|guide_to_glory|104372
    Philosophies of Glory|philosophies_of_glory|104373
    Profaned Sprout|profaned_sprout|113089
    Golden Fern|golden_fern|101277
    Vagabond's Cracked Armor|vagabonds_cracked_armor|113092
    Kristallfold|kristallfold|101274
    Shattered Stability Anchor|shattered_stability_anchor|113093
    Fairy Wormwood|fairy_wormwood|101273
    Snowborn Heartshard|snowborn_heartshard|112158
    Snowborn Mirrorheart|snowborn_mirrorheart|112159
    Snowborn Heart of Ignorance|snowborn_heart_of_ignorance|112160
    """
}
