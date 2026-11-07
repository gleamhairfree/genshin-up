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
    """

    /// Display name|paimon.moe item id
    static let itemsRaw = """
    Mystic Enhancement Ore|mystic_enhancement_ore
    Fine Enhancement Ore|fine_enhancement_ore
    Enhancement Ore|enhancement_ore
    1 Star Weapon|any_weapon_1
    2 Star Weapon|any_weapon_2
    3 Star Weapon|any_weapon_3
    Mora|mora
    Hero's Wit|heros_wit
    Adventurer's Experience|adventurers_experience
    Wanderer's Advice|wanderes_advice
    Crown of Insight|crown_of_insight
    Fetters of the Dandelion Gladiator|fetters_of_the_dandelion_gladiator
    Chaos Device|chaos_device
    Divining Scroll|divining_scroll
    Chains of the Dandelion Gladiator|chains_of_the_dandelion_gladiator
    Chaos Circuit|chaos_circuit
    Sealed Scroll|sealed_scroll
    Shackles of the Dandelion Gladiator|shackles_of_the_dandelion_gladiator
    Chaos Core|chaos_core
    Forbidden Curse Scroll|forbidden_curse_scroll
    Dream of the Dandelion Gladiator|dream_of_the_dandelion_gladiator
    Tile of Decarabian's Tower|tile_of_decarabians_tower
    Heavy Horn|heavy_horn
    Firm Arrowhead|firm_arrowhead
    Debris of Decarabian's City|debris_of_decarabians_city
    Black Bronze Horn|black_bronze_horn
    Sharp Arrowhead|sharp_arrowhead
    Fragment of Decarabian's Epic|fragment_of_decarabians_epic
    Black Crystal Horn|black_crystal_horn
    Weathered Arrowhead|weathered_arrowhead
    Scattered Piece of Decarabian's Dream|scattered_piece_of_decarabians_dream
    Slime Condensate|slime_condensate
    Slime Secretions|slime_secretions
    Slime Concentrate|slime_concentrate
    Boreal Wolf's Milk Tooth|boreal_wolfs_milk_tooth
    Dead Ley Line Branch|dead_ley_line_branch
    Boreal Wolf's Cracked Tooth|boreal_wolfs_cracked_tooth
    Dead Ley Line Leaves|dead_ley_line_leaves
    Boreal Wolf's Broken Fang|boreal_wolfs_broken_fang
    Ley Line Sprouts|ley_line_sprouts
    Boreal Wolf's Nostalgia|boreal_wolfs_nostalgia
    Grain of Aerosiderite|grain_of_aerosiderite
    Fragile Bone Shard|fragile_bone_shard
    Damaged Mask|damaged_mask
    Piece of Aerosiderite|piece_of_aerosiderite
    Sturdy Bone Shard|sturdy_bone_shard
    Stained Mask|stained_mask
    Bit of Aerosiderite|bit_of_aerosiderite
    Fossilized Bone Shard|fossilized_bone_shard
    Ominous Mask|ominous_mask
    Chunk of Aerosiderite|chunk_of_aerosiderite
    Mist Veiled Lead Elixir|mist_veiled_lead_elixir
    Mist Grass Pollen|mist_grass_pollen
    Treasure Hoarder Insignia|treasure_hoarder_insignia
    Mist Veiled Mercury Elixir|mist_veiled_mercury_elixir
    Mist Grass|mist_grass
    Silver Raven Insignia|silver_raven_insignia
    Mist Veiled Gold Elixir|mist_veiled_gold_elixir
    Mist Grass Wick|mist_grass_wick
    Golden Raven Insignia|golden_raven_insignia
    Mist Veiled Primo Elixir|mist_veiled_primo_elixir
    Luminous Sands from Guyun|luminous_sands_from_guyun
    Hunter's Sacrificial Knife|hunters_sacrificial_knife
    Recruit's Insignia|recruits_insignia
    Lustrous Stone from Guyun|lustrous_stone_from_guyun
    Agent's Sacrificial Knife|agents_sacrificial_knife
    Sergeant's Insignia|sergeants_insignia
    Relic from Guyun|relic_from_guyun
    Inspector's Sacrificial Knife|inspectors_sacrificial_knife
    Lieutenant's Insignia|lieutenants_insignia
    Divine Body from Guyun|divine_body_from_guyun
    Whopperflower Nectar|whopperflower_nectar
    Shimmering Nectar|shimmering_nectar
    Energy Nectar|energy_nectar
    Prithiva Topaz Sliver|prithiva_topaz_sliver
    Cecilia|cecilia
    Prithiva Topaz Fragment|prithiva_topaz_fragment
    Basalt Pillar|basalt_pillar
    Prithiva Topaz Chunk|prithiva_topaz_chunk
    Prithiva Topaz Gemstone|prithiva_topaz_gemstone
    Teachings of Ballad|teachings_of_ballad
    Guide to Ballad|guide_to_ballad
    Philosophies of Ballad|philosophies_of_ballad
    Tusk of Monoceros Caeli|tusk_of_monoceros_caeli
    Agnidus Agate Sliver|agnidus_agate_sliver
    Small Lamp Grass|small_lamp_grass
    Agnidus Agate Fragment|agnidus_agate_fragment
    Everflame Seed|everflame_seed
    Agnidus Agate Chunk|agnidus_agate_chunk
    Agnidus Agate Gemstone|agnidus_agate_gemstone
    Teachings of Freedom|teachings_of_freedom
    Guide to Freedom|guide_to_freedom
    Philosophies of Freedom|philosophies_of_freedom
    Dvalin's Sigh|dvalins_sigh
    Varunada Lazurite Sliver|varunada_lazurite_sliver
    Philanemo Mushroom|philanemo_mushroom
    Varunada Lazurite Fragment|varunada_lazurite_fragment
    Cleansing Heart|cleansing_heart
    Varunada Lazurite Chunk|varunada_lazurite_chunk
    Varunada Lazurite Gemstone|varunada_lazurite_gemstone
    Ring of Boreas|ring_of_boreas
    Vajrada Amethyst Sliver|vajrada_amethyst_sliver
    Noctilucous Jade|noctilucous_jade
    Vajrada Amethyst Fragment|vajrada_amethyst_fragment
    Lightning Prism|lightning_prism
    Vajrada Amethyst Chunk|vajrada_amethyst_chunk
    Vajrada Amethyst Gemstone|vajrada_amethyst_gemstone
    Teachings of Gold|teachings_of_gold
    Guide to Gold|guide_to_gold
    Philosophies of Gold|philosophies_of_gold
    Windwheel Aster|windwheel_aster
    Teachings of Resistance|teachings_of_resistance
    Guide to Resistance|guide_to_resistance
    Philosophies of Resistance|philosophies_of_resistance
    Dvalin's Plume|dvalins_plume
    Shivada Jade Sliver|shivada_jade_sliver
    Cor Lapis|cor_lapis
    Shivada Jade Fragment|shivada_jade_fragment
    Hoarfrost Core|hoarfrost_core
    Shivada Jade Chunk|shivada_jade_chunk
    Shivada Jade Gemstone|shivada_jade_gemstone
    Teachings of Diligence|teachings_of_diligence
    Guide to Diligence|guide_to_diligence
    Philosophies of Diligence|philosophies_of_diligence
    Calla Lily|calla_lily
    Shard of a Foul Legacy|shard_of_a_foul_legacy
    Spirit Locket of Boreas|spirit_locket_of_boreas
    Vayuda Turquoise Sliver|vayuda_turquoise_sliver
    Dandelion Seed|dandelion_seed
    Vayuda Turquoise Fragment|vayuda_turquoise_fragment
    Hurricane Seed|hurricane_seed
    Vayuda Turquoise Chunk|vayuda_turquoise_chunk
    Vayuda Turquoise Gemstone|vayuda_turquoise_gemstone
    Teachings of Prosperity|teachings_of_prosperity
    Guide to Prosperity|guide_to_prosperity
    Philosophies of Prosperity|philosophies_of_prosperity
    Valberry|valberry
    Dvalin's Claw|dvalins_claw
    Glaze Lily|glaze_lily
    Violetgrass|violetgrass
    Tail of Boreas|tail_of_boreas
    Wolfhook|wolfhook
    Starconch|starconch
    Brilliant Diamond Sliver|brilliant_diamond_sliver
    Brilliant Diamond Fragment|brilliant_diamond_fragment
    Brilliant Diamond Chunk|brilliant_diamond_chunk
    Brilliant Diamond Gemstone|brilliant_diamond_gemstone
    Jueyun Chili|jueyun_chili
    Silk Flower|silk_flower
    Qingxin|qingxin
    Shadow of the Warrior|shadow_of_the_warrior
    Juvenile Jade|juvenile_jade
    Bloodjade Branch|bloodjade_branch
    Crystalline Bloom|crystalline_bloom
    Dragon Lord's Crown|dragon_lords_crown
    Sea Ganoderma|sea_ganoderma
    Marionette Core|marionette_core
    Gilded Scale|gilded_scale
    Coral Branch of a Distant Sea|coral_branch_of_a_distant_sea
    Jeweled Branch of a Distant Sea|jeweled_branch_of_a_distant_sea
    Jade Branch of a Distant Sea|jade_branch_of_a_distant_sea
    Golden Branch of a Golden Sea|golden_branch_of_a_distant_sea
    Narukami's Wisdom|narukamis_wisdom
    Narukami's Joy|narukamis_joy
    Narukami's Affection|narukamis_affection
    Narukami's Valor|narukamis_valor
    Mask of the Wicked Lieutenant|mask_of_the_wicked_lieutenant
    Mask of the Tiger's Bite|mask_of_the_tigers_bite
    Mask of the One-Horned|mask_of_the_one_horned
    Mask of the Kijin|mask_of_the_kijin
    Teachings of Transience|teachings_of_transience
    Guide to Transience|guide_to_transience
    Philosophies of Transience|philosophies_of_transience
    Teachings of Elegance|teachings_of_elegance
    Guide to Elegance|guide_to_elegance
    Philosophies of Elegance|philosophies_of_elegance
    Teachings of Light|teachings_of_light
    Guide to Light|guide_to_light
    Philosophies of Light|philosophies_of_light
    Perpetual Heart|perpetual_heart
    Smoldering Pearl|smoldering_pearl
    Old Handguard|old_handguard
    Kageuchi Handguard|kageuchi_handguard
    Famed Handguard|famed_handguard
    Chaos Gear|chaos_gear
    Chaos Axis|chaos_axis
    Chaos Oculus|chaos_oculus
    Dismal Prism|dismal_prism
    Crystal Prism|crystal_prism
    Polarizing Prism|polarizing_prism
    Sakura Bloom|sakura_bloom
    Crystal Marrow|crystal_marrow
    Dendrobium|dendrobium
    Naku Weed|naku_weed
    Okinabuto|okinabuto
    Amakumo Fruit|amakumo_fruit
    Storm Beads|storm_beads
    Molten Moment|molten_moment
    Ashen Heart|ashen_heart
    Spectral Husk|spectral_husk
    Spectral Heart|spectral_heart
    Spectral Nucleus|spectral_nucleus
    Sango Pearl|sango_pearl
    Dew of Repudiation|dew_of_repudiation
    Hellfire Butterfly|hellfire_butterfly
    Concealed Claw|concealed_claw
    Concealed Unguis|concealed_unguis
    Concealed Talon|concealed_talon
    Fluorescent Fungus|fluorescent_fungus
    Onikabuto|onikabuto
    Riftborn Regalia|riftborn_regalia
    Dragonheir's False Fin|dragonheirs_false_fin
    The Meaning of Aeons|the_meaning_of_aeons
    Mudra of the Malefic General|mudra_of_the_malefic_general
    Gloomy Statuette|gloomy_statuette
    Dark Statuette|dark_statuette
    Deathly Statuette|deathly_statuette
    Tears of the Calamitous God|tears_of_the_calamitous_god
    Runic Fang|runic_fang
    Teachings of Admonition|teachings_of_admonition
    Guide to Admonition|guide_to_admonition
    Philosophies of Admonition|philosophies_of_admonition
    Teachings of Ingenuity|teachings_of_ingenuity
    Guide to Ingenuity|guide_to_ingenuity
    Philosophies of Ingenuity|philosophies_of_ingenuity
    Teachings of Praxis|teachings_of_praxis
    Guide to Praxis|guide_to_praxis
    Philosophies of Praxis|philosophies_of_praxis
    Nagadus Emerald Sliver|nagadus_emerald_sliver
    Nagadus Emerald Fragment|nagadus_emerald_fragment
    Nagadus Emerald Chunk|nagadus_emerald_chunk
    Nagadus Emerald Gemstone|nagadus_emerald_gemstone
    Majestic Hooked Beak|majestic_hooked_beak
    Nilotpala Lotus|nilotpala_lotus
    Kalpalata Lotus|kalpalata_lotus
    Fungal Spores|fungal_spores
    Luminescent Pollen|luminescent_pollen
    Crystalline Cyst Dust|crystalline_cyst_dust
    Rukkhashava Mushrooms|rukkhashava_mushrooms
    Echo of Scorching Might|echo_of_scorching_might
    Remnant Glow of Scorching Might|remnant_glow_of_scorching_might
    Dream of Scorching Might|dream_of_scorching_might
    Olden Days of Scorching Might|olden_days_of_scorching_might
    Inactivated Fungal Nucleus|inactivated_fungal_nucleus
    Dormant Fungal Nucleus|dormant_fungal_nucleus
    Robust Fungal Nucleus|robust_fungal_nucleus
    Faded Red Satin|faded_red_satin
    Trimmed Red Silk|trimmed_red_silk
    Rich Red Brocade|rich_red_brocade
    Copper Talisman of the Forest Dew|copper_talisman_of_the_forest_dew
    Iron Talisman of the Forest Dew|iron_talisman_of_the_forest_dew
    Silver Talisman of the Forest Dew|silver_talisman_of_the_forest_dew
    Golden Talisman of the Forest Dew|golden_talisman_of_the_forest_dew
    Chaos Storage|chaos_storage
    Chaos Module|chaos_module
    Chaos Bolt|chaos_bolt
    Oasis Garden's Reminiscence|oasis_gardens_reminiscence
    Oasis Garden's Kindness|oasis_gardens_kindness
    Oasis Garden's Mourning|oasis_gardens_mourning
    Oasis Garden's Truth|oasis_gardens_truth
    Thunderclap Fruitcore|thunderclap_fruitcore
    Scarab|scarab
    Henna Berry|henna_berry
    Light Guiding Tetrahedron|light_guiding_tetrahedron
    Damaged Prism|damaged_prism
    Turbid Prism|turbid_prism
    Radiant Prism|radiant_prism
    Perpetual Caliber|perpetual_caliber
    Padisarah|padisarah
    Quelled Creeper|quelled_creeper
    Puppet Strings|puppet_strings
    Mirror of Mushin|mirror_of_mushin
    Daka's Bell|dakas_bell
    Pseudo-Stamens|pseudo_stamens
    Sand Grease Pupa|sand_grease_pupa
    Desiccated Shell|desiccated_shell
    Sturdy Shell|sturdy_shell
    Marked Shell|marked_shell
    Mourning Flower|mourning_flower
    Evergloom Ring|evergloom_ring
    Worldspan Fern|worldspan_fern
    Primordial Greenbloom|primordial_greenbloom
    A Flower Yet to Bloom|a_flower_yet_to_bloom
    Treasured Flower|treasured_flower
    Wanderer's Blooming Flower|wanderers_blooming_flower
    Everamber|everamber
    Artificed Spare Clockwork Component — Coppelius|artificed_spare_clockwork_component_coppelius
    Lumidouce Bell|lumidouce_bell
    Mechanical Spur Gear|mechanical_spur_gear
    Artificed Dynamic Gear|artificed_dynamic_gear
    Meshing Gear|meshing_gear
    Rainbow Rose|rainbow_rose
    Emperor's Resolution|emperors_resolution
    Teachings of Order|teachings_of_order
    Guide to Order|guide_to_order
    Philosophies of Order|philosophies_of_order
    Teachings of Equity|teachings_of_equity
    Guide to Equity|guide_to_equity
    Philosophies of Equity|philosophies_of_equity
    Teachings of Justice|teachings_of_justice
    Guide to Justice|guide_to_justice
    Philosophies of Justice|philosophies_of_justice
    Fragment of an Ancient Chord|fragment_of_an_ancient_chord
    Chapter of an Ancient Chord|chapter_of_an_ancient_chord
    Movement of an Ancient Chord|movement_of_an_ancient_chord
    Echo of an Ancient Chord|echo_of_an_ancient_chord
    Transoceanic Pearl|transoceanic_pearl
    Transoceanic Chunk|transoceanic_chunk
    Xenochromatic Crystal|xenochromatic_crystal
    Drop of Tainted Water|drop_of_tainted_water
    Scoop of Tainted Water|scoop_of_tainted_water
    Newborn Tainted Hydro Phantasm|newborn_tainted_hydro_phantasm
    Broken Goblet of the Pristine Sea|broken_goblet_of_the_pristine_sea
    Wine Goblet of the Pristine Sea|wine_goblet_of_the_pristine_sea
    Silver Goblet of the Pristine Sea|silver_goblet_of_the_pristine_sea
    Golden Goblet of the Pristine Sea|golden_goblet_of_the_pristine_sea
    Dross of Pure Sacred Dewdrop|dross_of_pure_sacred_dewdrop
    Sublimation of Pure Sacred Dewdrop|sublimation_of_pure_sacred_dewdrop
    Spring of Pure Sacred Dewdrop|spring_of_pure_sacred_dewdrop
    Essence of Pure Sacred Dewdrop|essence_of_pure_sacred_dewdrop
    Rift Core|rift_core
    Foreign Synapse|foreign_synapse
    Alien Life Core|alien_life_core
    Romaritime Flower|romaritime_flower
    Fontemer Unihorn|fontemer_unihorn
    Lumitoile|lumitoile
    Old Operative's Pocket Watch|old_operatives_pocket_watch
    Operative's Standard Pocket Watch|operatives_standard_pocket_watch
    Operative's Constancy|operatives_constancy
    Subdetection Unit|subdetection_unit
    "Tourbillon Device"|tourbillon_device
    Beryl Conch|beryl_conch
    Lakelight Lily|lakelight_lily
    Water That Failed To Transcend|water_that_failed_to_transcend
    Lightless Silk String|lightless_silk_string
    Lightless Mass|lightless_mass
    Spring of the First Dewdrop|spring_of_the_first_dewdrop
    Lightless Eye of the Maelstrom|lightless_eye_of_the_maelstrom
    Cloudseam Scale|cloudseam_scale
    Clearwater Jade|clearwater_jade
    Feathery Fin|feathery_fin
    Lunar Fin|lunar_fin
    Chasmlight Fin|chasmlight_fin
    Fragment of a Golden Melody|fragment_of_a_golden_melody
    Fading Candle|fading_candle
    Ruined Hilt|ruined_hilt
    Splintered Hilt|splintered_hilt
    Still-Smoldering Hilt|still_smoldering_hilt
    Trishiraite|trishiraite
    Silken Feather|silken_feather
    Sprayfeather Gill|sprayfeather_gill
    Seasoned Fang|seasoned_fang
    Tyrant's Fang|tyrants_fang
    Juvenile Fang|juvenile_fang
    Mark of the Binding Blessing|mark_of_the_binding_blessing
    Warrior's Metal Whistle|warriors_metal_whistle
    Saurian-Crowned Warrior's Golden Whistle|saurian_crowned_warriors_golden_whistle
    Sentry's Wooden Whistle|sentrys_wooden_whistle
    Overripe Flamegranate|overripe_flamegranate
    Quenepa Berry|quenepa_berry
    Teachings of Contention|teachings_of_contention
    Guide to Contention|guide_to_contention
    Philosophies of Contention|philosophies_of_contention
    Teachings of Conflict|teachings_of_conflict
    Guide to Conflict|guide_to_conflict
    Philosophies of Conflict|philosophies_of_conflict
    Blazing Sacrificial Heart's Terror|blazing_sacrificial_hearts_terror
    Blazing Sacrificial Heart's Hesitance|blazing_sacrificial_hearts_hesitance
    Blazing Sacrificial Heart's Resolve|blazing_sacrificial_hearts_resolve
    Blazing Sacrificial Heart's Splendor|blazing_sacrificial_hearts_splendor
    Shard of a Shattered Will|shard_of_a_shattered_will
    Locus of a Clear Will|locus_of_a_clear_will
    Sigil of a Striding Will|sigil_of_a_striding_will
    Night-Wind's Mystic Consideration|night_winds_mystic_consideration
    Night-Wind's Mystic Premonition|night_winds_mystic_premonition
    Night-Wind's Mystic Augury|night_winds_mystic_augury
    Night-Wind's Mystic Revelation|night_winds_mystic_revelation
    Axis of the Secret Source|axis_of_the_secret_source
    Sheath of the Secret Source|sheath_of_the_secret_source
    Heart of the Secret Source|heart_of_the_secret_source
    Ignited Stone|ignited_stone
    Ignited Seed of Life|ignited_seed_of_life
    Ignited Seeing Eye|ignited_seeing_eye
    Delirious Decadence of the Sacred Lord|delirious_decadence_of_the_sacred_lord
    Delirious Desolation of the Sacred Lord|delirious_desolation_of_the_sacred_lord
    Delirious Demeanor of the Sacred Lord|delirious_demeanor_of_the_sacred_lord
    Delirious Divinity of the Sacred Lord|delirious_divinity_of_the_sacred_lord
    Saurian Claw Succulent|saurian_claw_succulent
    Denial and Judgment|denial_and_judgment
    Teachings of Kindling|teachings_of_kindling
    Guide to Kindling|guide_to_kindling
    Philosophies of Kindling|philosophies_of_kindling
    Gold-Inscribed Secret Source Core|gold_inscribed_secret_source_core
    Brilliant Chrysanthemum|brilliant_chrysanthemum
    Ensnaring Gaze|ensnaring_gaze
    Withering Purpurbloom|withering_purpurbloom
    Glowing Hornshroom|glowing_hornshroom
    Refractive Bud|refractive_bud
    Bewildering Broadleaf|bewildering_broadleaf
    Illusory Leafcoil|illusory_leafcoil
    Eroded Horn|eroded_horn
    Talisman of the Enigmatic Land|talisman_of_the_enigmatic_land
    Eroded Sunfire|eroded_sunfire
    Dracolite|dracolite
    Sparkless Statue Core|sparkless_statue_core
    Skysplit Gembloom|skysplit_gembloom
    Eroded Scale-Feather|eroded_scale_feather
    Cold-Cracked Shellshard|cold_cracked_shellshard
    Warm Back-Shell|warm_back_shell
    Blazing Prismshell|blazing_prismshell
    Secret Source Airflow Accumulator|secret_source_airflow_accumulator
    Ascended Sample: Rook|ascended_sample_rook
    Ascended Sample: Knight|ascended_sample_knight
    Tattered Warrant|tattered_warrant
    Immaculate Warrant|immaculate_warrant
    Frost-Etched Warrant|frost_etched_warrant
    Moonfall Silver|moonfall_silver
    Lightbearing Scale-Feather|lightbearing_scale_feather
    Teachings of Moonlight|teachings_of_moonlight
    Guide to Moonlight|guide_to_moonlight
    Philosophies of Moonlight|philosophies_of_moonlight
    Lightless Bone|lightless_bone
    Glowing Remains|glowing_remains
    Radiant Exoskeleton|radiant_exoskeleton
    Artful Device Fragment|artful_device_fragment
    Frostnight's Glimmer|frostnights_glimmer
    Broken Drive Shaft|broken_drive_shaft
    Artful Device Replica|artful_device_replica
    Frostnight's Glow|frostnights_glow
    Reinforced Drive Shaft|reinforced_drive_shaft
    Artful Device Inheritance|artful_device_inheritance
    Frostnight's Glory|frostnights_glory
    Precision Drive Shaft|precision_drive_shaft
    Artful Device Wish|artful_device_wish
    Precision Kuuvahki Stamping Die|precision_kuuvahki_stamping_die
    Frostlamp Flower|frostlamp_flower
    Teachings of Elysium|teachings_of_elysium
    Guide to Elysium|guide_to_elysium
    Philosophies of Elysium|philosophies_of_elysium
    Teachings of Vagrancy|teachings_of_vagrancy
    Guide to Vagrancy|guide_to_vagrancy
    Philosophies of Vagrancy|philosophies_of_vagrancy
    Ascended Sample: Queen|ascended_sample_queen
    Portable Bearing|portable_bearing
    Ember of Long Night Flint|ember_of_long_night_flint
    Mistshroud Manifestation|mistshroud_manifestation
    Afterglow of Long Night Flint|afterglow_of_long_night_flint
    Mistshroud Plate|mistshroud_plate
    Flare of Long Night Flint|flare_of_long_night_flint
    Mistshroud Helmet|mistshroud_helmet
    Blaze of Long Night Flint|blaze_of_long_night_flint
    Radiant Antler|radiant_antler
    Cyclic Military Kuuvahki Core|cyclic_military_kuuvahki_core
    Winter Icelea|winter_icelea
    Mask of the Virtuous Doctor|mask_of_the_virtuous_doctor
    Remnant of the Dreadwing|remnant_of_the_dreadwing
    Pine Amber|pine_amber
    Fractured Eye of the Deep Shadow|fractured_eye_of_the_deep_shadow
    Aberrant Core of the Deep Shadow|aberrant_core_of_the_deep_shadow
    Hooked Beak of the Deep Shadow|hooked_beak_of_the_deep_shadow
    Prismatic Severed Tail|prismatic_severed_tail
    Elixir of the Heretic|elixir_of_the_heretic
    Etherwing Moth|etherwing_moth
    Plume of the Fallen Watcher|plume_of_the_fallen_watcher
    Faded Flaming Hilt|faded_flaming_hilt
    Fractured Flaming Hilt|fractured_flaming_hilt
    Jeweled Flaming Hilt|jeweled_flaming_hilt
    Counterfeit Resin|counterfeit_resin
    The Cornerstone of Stars and Flames|the_cornerstone_of_stars_and_flames
    Madman's Restraint|madmans_restraint
    Sundered Glory of the Far-North Scions|sundered_glory_of_the_far_north_scions
    Unyielding Delusion of the Far-North Scions|unyielding_delusion_of_the_far_north_scions
    Oblation of the Far-North Scions|oblation_of_the_far_north_scions
    Aureate Radiance of the Far-North Scions|aureate_radiance_of_the_far_north_scions
    Fractured Lunar Iron|fractured_lunar_iron
    Depleted Lunar Iron|depleted_lunar_iron
    Unblemished Lunar Iron|unblemished_lunar_iron
    Flockingweed|flockingweed
    Symbiotic Chimeric Nucleus|symbiotic_chimeric_nucleus
    Prime Chimeric Nexus|prime_chimeric_nexus
    Chimeric Core|chimeric_core
    Frostfairy Flower|frostfairy_flower
    Severed Tail of the Sky-Roamer|severed_tail_of_the_sky_roamer
    Unscorched Blossom Branch|unscorched_blossom_branch
    Ethereal Crystal|ethereal_crystal
    Ethereal Crystalscale Stone|ethereal_crystalscale_stone
    Ethereal Glimmershard|ethereal_glimmershard
    Twisted Withered Branch|twisted_withered_branch
    Teachings of Charity|teachings_of_charity
    Guide to Charity|guide_to_charity
    Philosophies of Charity|philosophies_of_charity
    Teachings of Fortitude|teachings_of_fortitude
    Guide to Fortitude|guide_to_fortitude
    Philosophies of Fortitude|philosophies_of_fortitude
    Rise of the Pale Star Army|rise_of_the_pale_star_army
    Muster of the Pale Star Army|muster_of_the_pale_star_army
    Clarion of the Pale Star Army|clarion_of_the_pale_star_army
    Triumph of the Pale Star Army|triumph_of_the_pale_star_army
    Hollow Root of Life|hollow_root_of_life
    Sprout Node of Life|sprout_node_of_life
    Coiled Core of Life|coiled_core_of_life
    Accreted Fragment|accreted_fragment
    Accreted Mass|accreted_mass
    Accreted Growth|accreted_growth
    The Frost Emperor's Revival|the_frost_emperors_revival
    The Frost Emperor's Ceremony|the_frost_emperors_ceremony
    The Frost Emperor's Lament|the_frost_emperors_lament
    The Frost Emperor's Farewell|the_frost_emperors_farewell
    Measured Pour of the Cellared Spiritual Nectar|measured_pour_of_the_cellared_spiritual_nectar
    Intoxication of the Cellared Spiritual Nectar|intoxication_of_the_cellared_spiritual_nectar
    Exhilaration of the Cellared Spiritual Nectar|exhilaration_of_the_cellared_spiritual_nectar
    Revelry of the Cellared Spiritual Nectar|revelry_of_the_cellared_spiritual_nectar
    Teachings of Glory|teachings_of_glory
    Guide to Glory|guide_to_glory
    Philosophies of Glory|philosophies_of_glory
    Profaned Sprout|profaned_sprout
    Golden Fern|golden_fern
    Vagabond's Cracked Armor|vagabonds_cracked_armor
    Kristallfold|kristallfold
    Shattered Stability Anchor|shattered_stability_anchor
    Fairy Wormwood|fairy_wormwood
    Snowborn Heartshard|snowborn_heartshard
    Snowborn Mirrorheart|snowborn_mirrorheart
    Snowborn Heart of Ignorance|snowborn_heart_of_ignorance
    """
}
