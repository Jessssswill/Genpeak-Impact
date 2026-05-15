<<<<<<< HEAD
import { PrismaClient } from "../generated/prisma/client";
import { PrismaMariaDb } from "@prisma/adapter-mariadb";
import bcrypt from "bcryptjs";
import "dotenv/config";

const adapter = new PrismaMariaDb({
    host: process.env.DATABASE_HOST,
    user: process.env.DATABASE_USER,
    password: process.env.DATABASE_PASSWORD,
    database: process.env.DATABASE_NAME,
    connectionLimit: 5,
});

const prisma = new PrismaClient({ adapter });

async function main() {
    const adminEmail = "Admin@gmail.com";

    const existingAdmin = await prisma.msUser.findUnique({
        where: { email: adminEmail }
    });

    if (existingAdmin) {
        console.log(`Admin account already exists (${adminEmail}), skipping seed.`);
        return;
    }

    const hashedPassword = await bcrypt.hash("Admin", 10);

    const admin = await prisma.msUser.create({
        data: {
            email: adminEmail,
            name: "Admin",
            password: hashedPassword,
            role: "ADMIN",
            createdAt: new Date(),
            createdBy: "SYSTEM",
            updatedAt: new Date(),
            updatedBy: "SYSTEM"
        }
    });
}

main()
    .catch((e) => {
        console.error("Seed failed:", e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });
=======
import "dotenv/config";
import { PrismaMariaDb } from "@prisma/adapter-mariadb";
import { PrismaClient } from "../generated/prisma/client.js";
import * as fs from "fs";
import * as path from "path";
import {
  assignFilesToPieceTypes,
  PIECE_TYPES,
  type PieceType,
} from "./seed-artifact-scoring.js";

const adapter = new PrismaMariaDb({
  host: process.env.DATABASE_HOST,
  user: process.env.DATABASE_USER,
  password: process.env.DATABASE_PASSWORD,
  database: process.env.DATABASE_NAME,
  connectionLimit: 5,
});
const prisma = new PrismaClient({ adapter });

const BASE_URL = "http://localhost:5000/images";
const now = new Date();
const ARTIFACTS_DIR = path.resolve(process.cwd(), "public/images/artifacts");

const PIECE_STATS: Record<string, { primary: number; secondary: number; priceAdd: number }> = {
  Flower:  { primary: 20000, secondary: 15, priceAdd: 0 },    // HP flat   → base 10k + flower = 30k HP
  Feather: { primary: 3000,  secondary: 14, priceAdd: 200 },  // ATK flat
  Sands:   { primary: 110,   secondary: 13, priceAdd: 400 },  // ATK%      → 110% of base 1500 = +1650
  Goblet:  { primary: 200,   secondary: 16, priceAdd: 600 },  // CD%       → base 100% + 200% = 300%
  Circlet: { primary: 75,    secondary: 18, priceAdd: 800 },  // CR%       → base 5% + 75% = 80%
};

type ArtifactSetSeed = {
  folder: string;
  name: string;
  element: string;
  basePrice: number;
  description: string;
  pieces?: ({ file: string; name: string; description: string } | null)[];
};

// All 42 sets are fully hardcoded. Order: [Flower, Feather, Sands, Goblet, Circlet]
const ARTIFACT_SETS: ArtifactSetSeed[] = [
  {
    folder: "A Day Carved From Rising Winds",
    name: "A Day Carved From Rising Winds",
    element: "Anemo",
    basePrice: 8000,
    description: "A poetic anthology of dawn winds and wandering songs.",
    pieces: [
      { file: "Item_Windborne_Flower's_Spruchdichtung.webp", name: "Windborne Flower's Spruchdichtung", description: "An azure crystal bloom that never withers, said to have once belonged, in ages past, to a wandering girl who invoked the thousand winds and countless flowers." },
      { file: "Item_Dawn's_Brilliant_Oath.webp", name: "Dawn's Brilliant Oath", description: "A feather accessory of azure, clear as the dawn, said to have once belonged to a guard who cast aside his name in ages past." },
      { file: "Item_A_Note_in_Spring's_Leich.webp", name: "A Note in Spring's Leich", description: "An hourglass filled with azure sand. For reasons unknown, no matter how it is turned, the grains within it refuse to stir." },
      { file: "Item_Heldenepos's_Unspoken_Tale.webp", name: "Heldenepos's Unspoken Tale", description: "An ancient goblet, its azure surface weathered by time. It is rumored to have belonged to an unnamed bard in ages past." },
      { file: "Item_Minnesang_of_Love_and_Lament.webp", name: "Minnesang of Love and Lament", description: "A luxurious hair accessory adorned with jade and azure crystals, said to have once been a token bestowed by the Lord of Storm upon a favored recipient in ages past." },
    ]
  },
  {
    folder: "Archaic Petra",
    name: "Archaic Petra",
    element: "Geo",
    basePrice: 7000,
    description: "Stone-wrought heirlooms carved from timeless mountain jade.",
    pieces: [
      { file: "Item_Flower_of_Creviced_Cliff.webp", name: "Flower of Creviced Cliff", description: "A flower born of the minerals and rocks of cliffside cracks. The way its petals blow in the wind makes it seem alive." },
      { file: "Item_Feather_of_Jagged_Peaks.webp", name: "Feather of Jagged Peaks", description: "A hard feather from a large seacliff hawk. The basalt tip of the feather sometimes glistens with a cool dew." },
      { file: "Item_Sundial_of_Enduring_Jade.webp", name: "Sundial of Enduring Jade", description: "A sundial carved from a single, large piece of jade. Its lined with a pattern that silently records the passage of time." },
      { file: "Item_Goblet_of_Chiseled_Crag.webp", name: "Goblet of Chiseled Crag", description: "A resplendent yet dignified wine goblet, once filled to the brim in an era long gone." },
      { file: "Item_Mask_of_Solitude_Basalt.webp", name: "Mask of Solitude Basalt", description: "A solemn mask exquisitely carved from basalt. Its hollow eyes stare ahead expressionless and cold." },
    ]
  },
  {
    folder: "Aubade of Morningstar and Moon",
    name: "Aubade of Morningstar and Moon",
    element: "Electro",
    basePrice: 8000,
    description: "A moonlit offering set dedicated to stars and vow.",
    pieces: [
      { file: "Item_Moonlit_Offering's_Opulent_Dream.webp", name: "Moonlit Offering's Opulent Dream", description: "A meticulously carved floral ornament meant to highlight the resplendent beauty of the goddesses of the heavenly moons, crafted in ancient times by artisans who sculpted statues of them." },
      { file: "Item_Moonlit_Offering's_Parting_Light.webp", name: "Moonlit Offering's Parting Light", description: "A quill that, in ancient times, granted boundless inspiration to priests who penned prayers to the heavenly moons." },
      { file: "Item_Moonlit_Offering's_Final_Hour.webp", name: "Moonlit Offering's Final Hour", description: "An hourglass meant to commemorate the final hour, prepared by sages who, in ancient times, sought truth from the heavenly moons." },
      { file: "Item_Moonlit_Offering's_Libation.webp", name: "Moonlit Offering's Libation", description: "A wine cup lost in the final revelry of an ancient rite, in which believers once offered sacrifices to the heavenly moons." },
      { file: "Item_Moonlit_Offering's_Silver_Crown.webp", name: "Moonlit Offering's Silver Crown", description: "A silver circlet set aside at the final syllable of a hymn, worn by poets who, in ancient times, sang in praise of the heavenly moons." },
    ]
  },
  {
    folder: "Blizzard Strayer",
    name: "Blizzard Strayer",
    element: "Cryo",
    basePrice: 7800,
    description: "A frozen legacy of hunters from a ruthless winter age.",
    pieces: [
      { file: "Item_Snowswept_Memory.webp", name: "Snowswept Memory", description: "A long-extinct flower, covered in beads of frost, that once grew on the glaciers. There was a time when even the proudest and most arrogant warriors bowed before it." },
      { file: "Item_Icebreaker's_Resolve.webp", name: "Icebreaker's Resolve", description: "A feather that exudes a chilly aura. One can almost feel the turbulent winds that brought it here, wailing over snow-covered plains and between frosty peaks." },
      { file: "Item_Frozen_Homeland's_Demise.webp", name: "Frozen Homeland's Demise", description: "A timepiece from a nation of old that waited for their warriors' return. What flows inside is not sand, but bits of ice that never melt." },
      { file: "Item_Frost-Weaved_Dignity.webp", name: "Frost-Weaved Dignity", description: "A cup carved out of ice that is as chilly and biting as winter. Its former master would drink an unfreezable liquor from it." },
      { file: "Item_Broken_Rime's_Echo.webp", name: "Broken Rime's Echo", description: "The crown of an ancient hero who dreamt of conquering the cold. It is proof of its former master's bravery in facing the bone-chilling cold of winter." },
    ]
  },
  {
    folder: "Bloodstained Chivalry",
    name: "Bloodstained Chivalry",
    element: "Cryo",
    basePrice: 6800,
    description: "Battle-worn pieces stained by the oath of a knight.",
    pieces: [
      { file: "Item_Bloodstained_Flower_of_Iron.webp", name: "Bloodstained Flower of Iron", description: "A dried flower stained black with blood and now as hard as steel. Probably some sort of a memento for its former master." },
      { file: "Item_Bloodstained_Black_Plume.webp", name: "Bloodstained Black Plume", description: "A raven feather pinned to a knight's cape. Countless bloodstains have dyed it pitch black." },
      { file: "Item_Bloodstained_Final_Hour.webp", name: "Bloodstained Final Hour", description: "A timepiece once used by a knight. The liquid inside has dried up, rendering it useless." },
      { file: "Item_Bloodstained_Chevalier's_Goblet.webp", name: "Bloodstained Chevalier's Goblet", description: "The dark metallic vessel owned by the Bloodstained Knight. Its exterior has been stained as black as the night by smoke and coagulated blood." },
      { file: "Item_Bloodstained_Iron_Mask.webp", name: "Bloodstained Iron Mask", description: "The iron mask the knight used to conceal their identity. Many have speculated about the face behind the mask." },
    ]
  },
  {
    folder: "Crimson Witch of Flames",
    name: "Crimson Witch of Flames",
    element: "Pyro",
    basePrice: 8000,
    description: "A relic from the witch who vowed to burn away all evil.",
    pieces: [
      { file: "Item_Witch's_Flower_of_Blaze.webp", name: "Witch's Flower of Blaze", description: "A flower touched by the witch who once dreamt of burning away all the demons in the world. The anonymous flames affectionately caress the hands of those who touch it." },
      { file: "Item_Witch's_Ever-Burning_Plume.webp", name: "Witch's Ever-Burning Plume", description: "A bird feather touched by the witch who once dreamt of burning away all the demons in the world. Its eternal flame burns hot." },
      { file: "Item_Witch's_End_Time.webp", name: "Witch's End Time", description: "A timepiece worn by the witch who dreamt of burning away all the demons in the world. The years the witch dedicated to the flames flow within." },
      { file: "Item_Witch's_Heart_Flames.webp", name: "Witch's Heart Flames", description: "A flame-spitting urn left behind by the Crimson Witch of Flames, who once dreamt of burning away all the demons in the world. The fire in the urn burns eternally, as did its former master." },
      { file: "Item_Witch's_Scorching_Hat.webp", name: "Witch's Scorching Hat", description: "A hat once worn by the witch who dreamt of burning away all of the demons in the world. The large brim blocked her sight." },
    ]
  },
  {
    folder: "Deepwood Memories",
    name: "Deepwood Memories",
    element: "Dendro",
    basePrice: 7200,
    description: "Forestbound ornaments preserving knowledge of old groves.",
    pieces: [
      { file: "Item_Labyrinth_Wayfarer.webp", name: "Labyrinth Wayfarer", description: "This lovely gold-plated flower was plucked from the crown of the ruler of the forest." },
      { file: "Item_Scholar_of_Vines.webp", name: "Scholar of Vines", description: "An emerald leaf as fluffy as a feather. Plucked from the raiment of a forest scholar." },
      { file: "Item_A_Time_of_Insight.webp", name: "A Time of Insight", description: "Such timepieces are used by those who dedicate themselves to the way of the wise. These timepieces do not contain lifeless sand, but instead play host to tiny mustard seeds." },
      { file: "Item_Lamp_of_the_Lost.webp", name: "Lamp of the Lost", description: "This was originally an oil lamp in the style of the desert realm, but has since sprouted fluorescent green leaves." },
      { file: "Item_Laurel_Coronet.webp", name: "Laurel Coronet", description: "This crown was bestowed by the deity with dominion over plants and trees. It was an heirloom of the royal house of the labyrinth. It was, at last, made the inheritance of the king's attendant." },
    ]
  },
  {
    folder: "Desert Pavilion Chronicle",
    name: "Desert Pavilion Chronicle",
    element: "Anemo",
    basePrice: 7600,
    description: "Chronicles of kings etched into wind-swept regalia.",
    pieces: [
      { file: "Item_The_First_Days_of_the_City_of_Kings.webp", name: "The First Days of the City of Kings", description: "An artificial flower that shimmers with a strange light. If you incline your ear to it, you can vaguely hear charming laughter issuing from within." },
      { file: "Item_End_of_the_Golden_Realm.webp", name: "End of the Golden Realm", description: "A crystal-clear artificial feather that is one of the legacies of an ancient human realm. The cries of soaring eagles are also sealed within." },
      { file: "Item_Timepiece_of_the_Lost_Path.webp", name: "Timepiece of the Lost Path", description: "An ancient mechanical clock. The Jinni fragments continue to emit light at its center and vibrate ever so slightly, as if to say something..." },
      { file: "Item_Defender_of_the_Enchanting_Dream.webp", name: "Defender of the Enchanting Dream", description: "An ancient golden cup that is both marvelously and luxuriously wrought. Murmurings can be heard within its empty innards." },
      { file: "Item_Legacy_of_the_Desert_High-Born.webp", name: "Legacy of the Desert High-Born", description: "Earrings made from amber gold that shines with a strange light." },
    ]
  },
  {
    folder: "Echoes of an Offering",
    name: "Echoes of an Offering",
    element: "Dendro",
    basePrice: 7500,
    description: "Ancient offerings that still resonate with sacred echoes.",
    pieces: [
      { file: "Item_Soulscent_Bloom.webp", name: "Soulscent Bloom", description: "A jade carved into the shape of a flower. A phantom scent, here one instant and gone the next, swirls around it." },
      { file: "Item_Jade_Leaf.webp", name: "Jade Leaf", description: "A jade ornament shaped like a leaf. It seems to have once had deep meaning between specific friends." },
      { file: "Item_Symbol_of_Felicitation.webp", name: "Symbol of Felicitation", description: "A circular jade ornament. Legend has it that it was once used somewhere as a symbol for rituals to begin." },
      { file: "Item_Chalice_of_the_Font.webp", name: "Chalice of the Font", description: "This teacup forever overflows with fresh water. Perhaps it was a gift from an adeptus, one of their relics, or just something they left behind." },
      { file: "Item_Flowing_Rings.webp", name: "Flowing Rings", description: "A pair of earrings made from a single piece of jade. It has a most gentle texture." },
    ]
  },
  {
    folder: "Emblem of Severed Fate",
    name: "Emblem of Severed Fate",
    element: "Electro",
    basePrice: 7500,
    description: "Symbols of loyalty forged in turbulent times.",
    pieces: [
      { file: "Item_Magnificent_Tsuba.webp", name: "Magnificent Tsuba", description: "Legends hold that this ornate hand guard was once fitted upon a sword gifted to the oni who betrayed the Shogun." },
      { file: "Item_Sundered_Feather.webp", name: "Sundered Feather", description: "This was once the black feather of a certain tengu warrior, and was the treasured souvenir of an ancient swordsman." },
      { file: "Item_Storm_Cage.webp", name: "Storm Cage", description: "An exquisite seal cage patterned with pansies painted upon a black backdrop, decorated with shining inlaid seashells and intricate gold-work." },
      { file: "Item_Scarlet_Vessel.webp", name: "Scarlet Vessel", description: "An intricately-designed wine vessel that a world-famous martial artist once drank from." },
      { file: "Item_Ornate_Kabuto.webp", name: "Ornate Kabuto", description: "A sturdy and hard helmet worn as armor by a noble samurai." },
    ]
  },
  {
    folder: "Finale of the Deep Galleries",
    name: "Finale of the Deep Galleries",
    element: "Hydro",
    basePrice: 8000,
    description: "A dramatic coda from galleries hidden beneath the sea.",
    pieces: [
      { file: "Item_Deep_Gallery's_Echoing_Song.webp", name: "Deep Gallery's Echoing Song", description: "An icy flower fashioned from northland jade. Over the course of its long life, its petals have crumbled to dust." },
      { file: "Item_Deep_Gallery's_Distant_Pact.webp", name: "Deep Gallery's Distant Pact", description: "A feathered accessory fashioned from northland jade that shimmers with an otherworldly glow." },
      { file: "Item_Deep_Gallery's_Moment_of_Oblivion.webp", name: "Deep Gallery's Moment of Oblivion", description: "A pocket watch fashioned from northland jade. Its hands are forever frozen in the moment of its destruction." },
      { file: "Item_Deep_Gallery's_Bestowed_Banquet.webp", name: "Deep Gallery's Bestowed Banquet", description: "A cup fashioned from northland jade. They say that the people of an ancient civilization once used it as a ceremonial vessel to make offerings to the heavens." },
      { file: "Item_Deep_Gallery's_Lost_Crown.webp", name: "Deep Gallery's Lost Crown", description: "A helmet steeped in obsession, just like the mind of its previous owner. Its jade ornamentation seems to come from an age more ancient still." },
    ]
  },
  {
    folder: "Flower of Paradiese lost",
    name: "Flower of Paradiese lost",
    element: "Dendro",
    basePrice: 7600,
    description: "Fragments of a paradise buried beneath dunes and time.",
    pieces: [
      { file: "Item_Ay-Khanoum's_Myriad.webp", name: "Ay-Khanoum's Myriad", description: "An amethyst bloom that has been beautifully sculpted in the image of an ancient, extinct flower." },
      { file: "Item_Wilting_Feast.webp", name: "Wilting Feast", description: "A feather left behind by a long-extinct bird species. It was inlaid with gold and gems by the ancient adherents of the Goddess of Flowers." },
      { file: "Item_A_Moment_Congealed.webp", name: "A Moment Congealed", description: "These sands no longer move no matter how you tilt the hourglass, now and forever defying the drift of time itself." },
      { file: "Item_Secret-Keeper's_Magic_Bottle.webp", name: "Secret-Keeper's Magic Bottle", description: "A small bottle made of purple crystal. An emerald cap keeps it tightly sealed." },
      { file: "Item_Amethyst_Crown.webp", name: "Amethyst Crown", description: "A crown inlaid with amethyst and emerald. It seems to have been the headgear worn by ancient priests of the Goddess of Flowers." },
    ]
  },
  {
    folder: "Fragment of Harmonic Whimsy",
    name: "Fragment of Harmonic Whimsy",
    element: "Electro",
    basePrice: 7600,
    description: "Playful fragments of melody spun into curious relics.",
    pieces: [
      { file: "Item_Harmonious_Symphony_Prelude.webp", name: "Harmonious Symphony Prelude", description: "An honorary medal in the shape of a blooming flower. Adorned with blue stone and gold, it was once bestowed upon immortals." },
      { file: "Item_Ancient_Sea's_Nocturnal_Musing.webp", name: "Ancient Sea's Nocturnal Musing", description: "A feather accessory carved in the shape of the wings of the golden bees of legend. They seem to flutter with the slightest breeze." },
      { file: "Item_The_Grand_Jape_of_the_Turning_of_Fate.webp", name: "The Grand Jape of the Turning of Fate", description: "A timepiece made in imitation of the wheel of fate. It ceased turning long ago." },
      { file: "Item_Ichor_Shower_Rhapsody.webp", name: "Ichor Shower Rhapsody", description: "A rhyton fired with copper as the base, that was once filled with fine wine from paradise." },
      { file: "Item_Whimsical_Dance_of_the_Withered.webp", name: "Whimsical Dance of the Withered", description: "A mask once covered in gold leaf. Perhaps it is a relic from some ancient officer of the legions." },
    ]
  },
  {
    folder: "Gilded Dreams",
    name: "Gilded Dreams",
    element: "Dendro",
    basePrice: 7600,
    description: "Golden ornaments from scholarly cities and desert myths.",
    pieces: [
      { file: "Item_Dreaming_Steelbloom.webp", name: "Dreaming Steelbloom", description: "A flower bud made of hammered dark gold. Its crimson core is wrapped by petals that shall never open." },
      { file: "Item_Feather_of_Judgment.webp", name: "Feather of Judgment", description: "This special feather was once used to weigh the hearts of the guilty, but it has since lost its original function." },
      { file: "Item_The_Sunken_Years.webp", name: "The Sunken Years", description: "This dark-golden sundial seems to tell the ancient tale of the desert." },
      { file: "Item_Honeyed_Final_Feast.webp", name: "Honeyed Final Feast", description: "A wine cup that was once used at a grand and ancient feast. It has now lost much of that luster." },
      { file: "Item_Shadow_of_the_Sand_King.webp", name: "Shadow of the Sand King", description: "This gold-inlaid headband was once used by desert priests in the days of old. They were made in imitation of one worn by a legendary ruler of the desert peoples." },
    ]
  },
  {
    folder: "Gladiator",
    name: "Gladiator",
    element: "Pyro",
    basePrice: 6500,
    description: "Trophies of an undefeated fighter in a forgotten arena.",
    pieces: [
      { file: "Item_Gladiator's_Nostalgia.webp", name: "Gladiator's Nostalgia", description: "No one knows why the legendary gladiator wore this flower on his chest. It was the brutal warrior's only weakness." },
      { file: "Item_Gladiator's_Destiny.webp", name: "Gladiator's Destiny", description: "A feather of dreams that soars free like an eagle. At the end of the gladiator's legendary life, this parting gift was left upon his chest by a bird that knew true freedom." },
      { file: "Item_Gladiator's_Longing.webp", name: "Gladiator's Longing", description: "A timepiece that recorded the gladiator's days in the bloodstained Colosseum. To him, it counted down the days on his long road to freedom." },
      { file: "Item_Gladiator's_Intoxication.webp", name: "Gladiator's Intoxication", description: "The golden cup a champion gladiator drank from in ancient times. It brimmed with his glory for years until the fateful day of his fall." },
      { file: "Item_Gladiator's_Triumphus.webp", name: "Gladiator's Triumphus", description: "The helmet of a legendary gladiator from ancient times, who would proudly stretch out his bloodied arms to welcome the thunderous applause of his audience." },
    ]
  },
  {
    folder: "Golden Troupe",
    name: "Golden Troupe",
    element: "Dendro",
    basePrice: 7600,
    description: "A theatrical set born from applause and stagecraft.",
    pieces: [
      { file: "Item_Golden_Song's_Variation.webp", name: "Golden Song's Variation", description: "A flower constructed out of clam, mother-of-pearl, and gold leaf. It blooms proudly." },
      { file: "Item_Golden_Bird's_Shedding.webp", name: "Golden Bird's Shedding", description: "A gold feather made using silver and gold filigree. A crystal-clear sapphire is mounted atop it." },
      { file: "Item_Golden_Era's_Prelude.webp", name: "Golden Era's Prelude", description: "This lovely sundial is inlaid with silver and gold. It seems that time has stopped flowing atop its dial plate." },
      { file: "Item_Golden_Night's_Bustle.webp", name: "Golden Night's Bustle", description: "An ancient silver urn that was once filled with fine wine as red as rubies. Now, it contains nothing but bitter seawater." },
      { file: "Item_Golden_Troupe's_Reward.webp", name: "Golden Troupe's Reward", description: "An ancient crown that resembles a stage prop more than it does some suzerain's headgear." },
    ]
  },
  {
    folder: "Hearth of Depth",
    name: "Hearth of Depth",
    element: "Hydro",
    basePrice: 7500,
    description: "Ceremonial pieces that carry the memory of ancient seas.",
    pieces: [
      { file: "Item_Gilded_Corsage.webp", name: "Gilded Corsage", description: "A mantle brooch that has lost its luster. The gold plating that once adorned it was ground away by the wind and the waves long ago." },
      { file: "Item_Gust_of_Nostalgia.webp", name: "Gust of Nostalgia", description: "A feather carried over by whimpering sea winds and crimson waves. The passage of time has changed its shape and color." },
      { file: "Item_Copper_Compass.webp", name: "Copper Compass", description: "An ancient bronze compass. Its needle points towards some ever-distant shore, to a non-existent harbor." },
      { file: "Item_Goblet_of_Thundering_Deep.webp", name: "Goblet of Thundering Deep", description: "A faded wine cup that was unintentionally dredged up from the sea. Its dull exterior tells of the days it has spent beneath the waves." },
      { file: "Item_Wine-Stained_Tricorne.webp", name: "Wine-Stained Tricorne", description: "An ancient, wine-stained sea hat that still reeks of alcohol even now." },
    ]
  },
  {
    folder: "Husk of Opulent Dreams",
    name: "Husk of Opulent Dreams",
    element: "Geo",
    basePrice: 7500,
    description: "Luxurious pieces from a dreamlike and gilded past.",
    pieces: [
      { file: "Item_Bloom_Times.webp", name: "Bloom Times", description: "A small golden ornament with six petals that shall never wilt. It symbolizes the transience of mortal glories." },
      { file: "Item_Plume_of_Luxury.webp", name: "Plume of Luxury", description: "A feather-shaped token that was brought forth from a secluded hall. The compassion of its creator led to it being left within that mansion along with a certain slumbering form." },
      { file: "Item_Song_of_Life.webp", name: "Song of Life", description: "As far as Inazuma is concerned, this is some small object from overseas. The heart of this mechanism has been removed, and its hands no longer turn." },
      { file: "Item_Calabash_of_Awakening.webp", name: "Calabash of Awakening", description: "A gourd that has been adorned with powdered gold and black paint. Its original color can no longer be discerned, but its main use seems to be as a performance prop." },
      { file: "Item_Skeletal_Hat.webp", name: "Skeletal Hat", description: "A hat that once shielded a wanderer from sun and rain. It eventually became a convenient tool with which faces might be hidden and expressions obscured." },
    ]
  },
  {
    folder: "Lavawalker",
    name: "Lavawalker",
    element: "Pyro",
    basePrice: 6200,
    description: "Fireproof remnants from travelers across molten lands.",
    pieces: [
      { file: "Item_Lavawalker's_Resolution.webp", name: "Lavawalker's Resolution", description: "A flower that blooms amidst burning flames. It is said that long ago, a sage once wore it as he walked into a sea of fire." },
      { file: "Item_Lavawalker's_Salvation.webp", name: "Lavawalker's Salvation", description: "The feather of a proud phoenix. You can almost hear the sound of its wings flapping in the scorching flames." },
      { file: "Item_Lavawalker's_Torment.webp", name: "Lavawalker's Torment", description: "Burning sand flows within this hourglass. Despite the intense heat, the sand leave no mark upon the vessel that houses it." },
      { file: "Item_Lavawalker's_Epiphany.webp", name: "Lavawalker's Epiphany", description: "A legendary goblet that can withstand extremely high temperatures. It still retains a degree of warmth even though it is now empty." },
      { file: "Item_Lavawalker's_Wisdom.webp", name: "Lavawalker's Wisdom", description: "The circlet of a sage who traversed a sea of fire. It once shone brightly from their ancient silhouette as they stood strong amidst the flames." },
    ]
  },
  {
    folder: "Long Night's Oath",
    name: "Long Night's Oath",
    element: "Cryo",
    basePrice: 8000,
    description: "Relics sworn beneath endless night and solemn bells.",
    pieces: [
      { file: "Item_Lightkeeper's_Pledge.webp", name: "Lightkeeper's Pledge", description: "A metal flower that was worn by the Ratniki. It symbolizes the oath of eternal vigilance taken by its original owner." },
      { file: "Item_Nightingale's_Tail_Feather.webp", name: "Nightingale's Tail Feather", description: "A hat ornament intricately crafted from the feathers of a nightingale. They say that its form was first conceived by the original Torchforger." },
      { file: "Item_Undying_One's_Mourning_Bell.webp", name: "Undying One's Mourning Bell", description: "A bronze bell that was carried by a warrior who walked through the dark abyss. Its peal can be heard on pitch-black nights." },
      { file: "Item_A_Horn_Unwinded.webp", name: "A Horn Unwinded", description: "A horn that was once used to summon those who had sworn oaths. It has long since lost its purpose." },
      { file: "Item_Dyed_Tassel.webp", name: "Dyed Tassel", description: "An ancient heavy helmet. It is an heirloom that bears the mark of a venerable lineage of northern warriors." },
    ]
  },
  {
    folder: "Maiden",
    name: "Maiden",
    element: "Hydro",
    basePrice: 5500,
    description: "A gentle set linked to prayers, healing, and devotion.",
    pieces: [
      { file: "Item_Maiden's_Distant_Love.webp", name: "Maiden's Distant Love", description: "A fragrant flower that will bloom for all eternity and never wither." },
      { file: "Item_Maiden's_Heart-Stricken_Infatuation.webp", name: "Maiden's Heart-stricken Infatuation", description: "A feathered accessory that carries the longing for a certain someone, like a migratory bird on the wind." },
      { file: "Item_Maiden's_Passing_Youth.webp", name: "Maiden's Passing Youth", description: "The hands of time will never come to an end, but the same cannot not be said for those cherished years of the young maiden's life when she was doted upon." },
      { file: "Item_Maiden's_Fleeting_Leisure.webp", name: "Maiden's Fleeting Leisure", description: "A vessel made with sweet black tea in mind rather than bitter liquor." },
      { file: "Item_Maiden's_Fading_Beauty.webp", name: "Maiden's Fading Beauty", description: "A meticulously well-maintained woman's hat that keeps wrinkles safely out of sight." },
    ]
  },
  {
    folder: "Marechaussee Hunter",
    name: "Marechaussee Hunter",
    element: "Cryo",
    basePrice: 7600,
    description: "A hunter's attire from stern courts and hidden trials.",
    pieces: [
      { file: "Item_Hunter's_Brooch.webp", name: "Hunter's Brooch", description: "An ancient emblem that was once awarded to those who had made exceptional contributions in battle." },
      { file: "Item_Masterpiece's_Overture.webp", name: "Masterpiece's Overture", description: "A portable tool used to adjust the torque on some old-school clockwork machine. It has since lost its practical value." },
      { file: "Item_Moment_of_Judgment.webp", name: "Moment of Judgment", description: "A standard pocket watch. Its accuracy is not particularly high." },
      { file: "Item_Forgotten_Vessel.webp", name: "Forgotten Vessel", description: "A portable metal vessel containing strong wine. Can be stuffed into the pocket of an outer coat for ease of access and use." },
      { file: "Item_Veteran's_Visage.webp", name: "Veteran's Visage", description: "An old mask that can, to some extent, stand in for a face marred by wounds. Its design can vary based on the wounded areas and the user's gender." },
    ]
  },
  {
    folder: "Night of the Sky's Unveiling",
    name: "Night of the Sky's Unveiling",
    element: "Pyro",
    basePrice: 8000,
    description: "A set commemorating revelations written across the sky.",
    pieces: [
      { file: "Item_Bloom_of_the_Mind's_Desire.webp", name: "Bloom of the Mind's Desire", description: "A sacred relic carved in the shape of a flower. It seems to represent a terrifying presence that unfurls like a bloom." },
      { file: "Item_Feather_of_Indelible_Sin.webp", name: "Feather of Indelible Sin", description: "A feathered accessory once worn on a felt hat. It feels out of place among the nobles of Snezhnaya and their taste for splendor." },
      { file: "Item_Revelation's_Toll.webp", name: "Revelation's Toll", description: "An exquisite chiming clock driven by a mysterious power. It does not seem that timekeeping is its purpose." },
      { file: "Item_Vessel_of_Plenty.webp", name: "Vessel of Plenty", description: "A specially crafted goblet used for palace banquets. It was once employed to perform some kind of magic." },
      { file: "Item_Crown_of_the_Befallen.webp", name: "Crown of the Befallen", description: "A crown modeled on the circlet worn by a sinner. Perhaps in someone's heart, love and sin flow from the same source." },
    ]
  },
  {
    folder: "Nighttime Whispers in the Echoing Woods",
    name: "Nighttime Whispers in the Echoing Woods",
    element: "Geo",
    basePrice: 7500,
    description: "Forest whispers preserved in ink, quills, and moonlight.",
    pieces: [
      { file: "Item_Selfless_Floral_Accessory.webp", name: "Selfless Floral Accessory", description: "A brooch that the witch in the tale wore. As with the other ornaments she loved, this was characterized by butterfly-like shapes." },
      { file: "Item_Honest_Quill.webp", name: "Honest Quill", description: "The witch in the tale used this dip pen. Among its various advantages, its silky-smooth writing is the least worthy of mention." },
      { file: "Item_Faithful_Hourglass.webp", name: "Faithful Hourglass", description: "A sand timepiece that the witch relied on in the story. Legend has it that if you recite the wrong incantation over it, time will suddenly flow exceptionally quickly." },
      { file: "Item_Magnanimous_Ink_Bottle.webp", name: "Magnanimous Ink Bottle", description: "An ink bottle utilized by the witch in the story. It possesses a strange enchantment no less powerful than the one cast upon the dip pen." },
      { file: "Item_Compassionate_Ladies'_Hat.webp", name: "Compassionate Ladies' Hat", description: "The lady's hat favored by the witch in the story. She loved this piece of headwear for how it weaves together solemnity and playfulness." },
    ]
  },
  {
    folder: "Noblesse Oblige",
    name: "Noblesse Oblige",
    element: "Hydro",
    basePrice: 7000,
    description: "Regal attire inherited from an age of courtly honor.",
    pieces: [
      { file: "Item_Royal_Flora.webp", name: "Royal Flora", description: "A satin flower with a glossy finish, fit for an elegant gathering. It still looks as distinguished as it did on the day it was cast aside." },
      { file: "Item_Royal_Plume.webp", name: "Royal Plume", description: "A feathered hat accessory worn by the old aristocrats of Mondstadt on hunts. It still stands proudly as if no time has passed." },
      { file: "Item_Royal_Pocket_Watch.webp", name: "Royal Pocket Watch", description: "A pocket watch that once belonged to the old aristocrats of Mondstadt. Passed down from generation to generation, it has witnessed many years of history." },
      { file: "Item_Royal_Silver_Urn.webp", name: "Royal Silver Urn", description: "An ornamental urn that once belonged to the old aristocrats of Mondstadt. Mournful winds seem to echo within its empty interior." },
      { file: "Item_Royal_Masque.webp", name: "Royal Masque", description: "A masquerade mask worn by the old aristocrats of Mondstadt. Its hollow eyes are fixated on the golden days of the past." },
    ]
  },
  {
    folder: "Nymph's Dream",
    name: "Nymph's Dream",
    element: "Hydro",
    basePrice: 7600,
    description: "Waterside heirlooms devoted to heroes and ocean myths.",
    pieces: [
      { file: "Item_Odyssean_Flower.webp", name: "Odyssean Flower", description: "The story must end, and even fresh flowers will wither. But the flower within one's dreams will always remain in full and fragrant bloom." },
      { file: "Item_Wicked_Mage's_Plumule.webp", name: "Wicked Mage's Plumule", description: "This was once a decorative feather in someone's hat. Being dark green, it is quite eye-catching indeed." },
      { file: "Item_Nymph's_Constancy.webp", name: "Nymph's Constancy", description: "A pocket watch that has long stopped working. It seems to have borne witness to many a passing year as its hands spun in vain." },
      { file: "Item_Heroes'_Tea_Party.webp", name: "Heroes' Tea Party", description: "A lovely teacup. Perhaps it was once used by people enjoying a leisurely afternoon together." },
      { file: "Item_Fell_Dragon's_Monocle.webp", name: "Fell Dragon's Monocle", description: "An exquisitely-made monocle. Ancient anecdotes say that one might be able to see the future through it." },
    ]
  },
  {
    folder: "Obsidian Codex",
    name: "Obsidian Codex",
    element: "Geo",
    basePrice: 7600,
    description: "Dark records of champions, rites, and ancient contests.",
    pieces: [
      { file: "Item_Reckoning_of_the_Xenogenic.webp", name: "Reckoning of the Xenogenic", description: "A flower meticulously carved from black crystal. It emits a mysterious light at night." },
      { file: "Item_Root_of_the_Spirit-Marrow.webp", name: "Root of the Spirit-Marrow", description: "A feathered accessory made in imitation of an ancient dragon's wing. Perhaps it was once a memento of some forgotten history." },
      { file: "Item_Myths_of_the_Night_Realm.webp", name: "Myths of the Night Realm", description: "A mysterious ritual element that is neither a timepiece nor a compass. Nowadays, no one has any idea what it is used for." },
      { file: "Item_Pre-Banquet_of_the_Contenders.webp", name: "Pre-Banquet of the Contenders", description: "A vessel that seems to have been made by twisting and forming stone in a seemingly whimsical fashion. But it is an open question as to who possesses such strength..." },
      { file: "Item_Crown_of_the_Saints.webp", name: "Crown of the Saints", description: "A crown made of obsidian that in ancient times was used in coronation ceremonies by noble tribal kings." },
    ]
  },
  {
    folder: "Ocean-Hued Clam",
    name: "Ocean-Hued Clam",
    element: "Hydro",
    basePrice: 7000,
    description: "Shell-bound relics carrying the tides of distant isles.",
    pieces: [
      { file: "Item_Sea-Dyed_Blossom.webp", name: "Sea-Dyed Blossom", description: "A soft flower that has taken on the many shades of the capricious ocean. It shines with wondrous colors under the moon's silver light." },
      { file: "Item_Deep_Palace's_Plume.webp", name: "Deep Palace's Plume", description: "A down feather with the same hue as coral, said to come from a shrine maiden's ceremonial garment." },
      { file: "Item_Cowry_of_Parting.webp", name: "Cowry of Parting", description: "A clean, flawless seashell that comes from the bottomless ocean." },
      { file: "Item_Pearl_Cage.webp", name: "Pearl Cage", description: "The shining pearls that the shrine maidens of Watatsumi Island offer up shine eternally and never dim." },
      { file: "Item_Crown_of_Watatsumi.webp", name: "Crown of Watatsumi", description: "An ancient, intricate crown that was once used by a forgotten clergy member. Today, this relic has been enshrined with great ceremony by the people of Watatsumi." },
    ]
  },
  {
    folder: "Pale Flame",
    name: "Pale Flame",
    element: "Cryo",
    basePrice: 7500,
    description: "Faded insignia tied to secretive organizations and resolve.",
    pieces: [
      { file: "Item_Stainless_Bloom.webp", name: "Stainless Bloom", description: "A hard, blue artificial flower. Its petals shall never wither, nor shall its colors fade." },
      { file: "Item_Wise_Doctor's_Pinion.webp", name: "Wise Doctor's Pinion", description: "An ominous pinion with edges of unsurpassed keenness. Perhaps it represents an unnaturally uninhibited nature." },
      { file: "Item_Moment_of_Cessation.webp", name: "Moment of Cessation", description: "A pocket watch with a cover that cannot be opened. Yet it ticks and tocks away, following the inexorable flow of time." },
      { file: "Item_Surpassing_Cup.webp", name: "Surpassing Cup", description: "An intricately-made cup. Its appearance betrays nothing of its age to an observer." },
      { file: "Item_Mocking_Mask.webp", name: "Mocking Mask", description: "A mask that covers the face, hiding one's expression from others." },
    ]
  },
  {
    folder: "Retracing Bolide",
    name: "Retracing Bolide",
    element: "Geo",
    basePrice: 7000,
    description: "Protective festival pieces inspired by summer fireworks.",
    pieces: [
      { file: "Item_Summer_Night's_Bloom.webp", name: "Summer Night's Bloom", description: "A man-made flower in eternal bloom. Who knows if there truly is life in there?" },
      { file: "Item_Summer_Night's_Finale.webp", name: "Summer Night's Finale", description: "A well-crafted wooden dart. It will only stop once it has reached its destination." },
      { file: "Item_Summer_Night's_Moment.webp", name: "Summer Night's Moment", description: "A pocketwatch that has stopped at a certain point in time." },
      { file: "Item_Summer_Night's_Waterballoon.webp", name: "Summer Night's Waterballoon", description: "Water balloons can be seen everywhere during the summer festival, but none are as finely-wrought as this one." },
      { file: "Item_Summer_Night's_Mask.webp", name: "Summer Night's Mask", description: "A popular mask cast in the image of a deity, as described in the legends." },
    ]
  },
  {
    folder: "Scroll of the Hero of Cinder City",
    name: "Scroll of the Hero of Cinder City",
    element: "Pyro",
    basePrice: 7600,
    description: "Heroic writings and talismans from a city of cinders.",
    pieces: [
      { file: "Item_Beast_Tamer's_Talisman.webp", name: "Beast Tamer's Talisman", description: "A flower carved from flint and Drakite, signifying that its bearer is qualified to become a beast tamer." },
      { file: "Item_Mountain_Ranger's_Marker.webp", name: "Mountain Ranger's Marker", description: "A signal used by mountain rangers to mark out paths. Their bird-feather shapes make them very eye-catching indeed." },
      { file: "Item_Mystic's_Gold_Dial.webp", name: "Mystic's Gold Dial", description: "A golden disc shaped like a sun. The draconic patterns on it seem to symbolize the cycle of life and death." },
      { file: "Item_Wandering_Scholar's_Claw_Cup.webp", name: "Wandering Scholar's Claw Cup", description: "A strange goblet strikingly similar in shape to a dragon's claw. Its maker must have made it with something special in mind." },
      { file: "Item_Demon-Warrior's_Feather_Mask.webp", name: "Demon-Warrior's Feather Mask", description: "A feather mask with falcon-esque plumage. Many legends surround this object." },
    ]
  },
  {
    folder: "Shimenawa's Reminiscence",
    name: "Shimenawa's Reminiscence",
    element: "Pyro",
    basePrice: 7500,
    description: "Ceremonial keepsakes from old summer traditions.",
    pieces: [
      { file: "Item_Entangling_Bloom.webp", name: "Entangling Bloom", description: "A lovely amulet made from twisted paper cord. It is said to hold the power to make wishes come true." },
      { file: "Item_Shaft_of_Remembrance.webp", name: "Shaft of Remembrance", description: "A demon-slaying arrow of a rather ancient make. It seems to have been preserved with great care by someone, even until the present day." },
      { file: "Item_Morning_Dew's_Moment.webp", name: "Morning Dew's Moment", description: "A bronze pocket watch adorned with twisted paper cord and a bell. Its hands are forever frozen at the dawn of a certain autumn day." },
      { file: "Item_Hopeful_Heart.webp", name: "Hopeful Heart", description: "A special fortune-telling cylindrical object. The mechanism at the bottom allows one to easily remove all unwanted wish sticks." },
      { file: "Item_Capricious_Visage.webp", name: "Capricious Visage", description: "A well-preserved ceremonial fox mask. A small, enigmatic smile ever graces its lips." },
    ]
  },
  {
    folder: "Silken Moon's Serenade",
    name: "Silken Moon's Serenade",
    element: "Dendro",
    basePrice: 7500,
    description: "Silken ornaments from a serene and fragrant moonlit rite.",
    pieces: [
      { file: "Item_Crystal_Tear_of_the_Wanderer.webp", name: "Crystal Tear of the Wanderer", description: "An immaculate flower whose beauty is said to have been preserved for eternity by the icy wind." },
      { file: "Item_Pristine_Plume_of_the_Blessed.webp", name: "Pristine Plume of the Blessed", description: "An immaculate feathered accessory said to have been forged by the first Moonchanter herself." },
      { file: "Item_Frost_Devotee's_Delirium.webp", name: "Frost Devotee's Delirium", description: "An immaculate timepiece that long ago ceased turning, along with the delusions of its former owner." },
      { file: "Item_Joyous_Glory_of_the_Pure.webp", name: "Joyous Glory of the Pure", description: "An immaculate silver cup said to have been used in the bygone rituals of the Frostmoon Scions. Their modern rites have no need for such a vessel." },
      { file: "Item_Holy_Crown_of_the_Believer.webp", name: "Holy Crown of the Believer", description: "An immaculate adornment created in imitation of the envoy of the grove's antlers." },
    ]
  },
  {
    folder: "Song of Days Past",
    name: "Song of Days Past",
    element: "Anemo",
    basePrice: 7600,
    description: "A nostalgic composition of keepsakes from bygone days.",
    pieces: [
      { file: "Item_Forgotten_Oath_of_Days_Past.webp", name: "Forgotten Oath of Days Past", description: "An ever-blooming flower shaped from larimar and shimmering silver. They say that this is still viewed as a symbol of resistance." },
      { file: "Item_Recollection_of_Days_Past.webp", name: "Recollection of Days Past", description: "A butterfly-shaped feather accessory made from silver and azure crystals. It is said to, in the distant past, have symbolized an oath to never be parted." },
      { file: "Item_Echoing_Sound_From_Days_Past.webp", name: "Echoing Sound From Days Past", description: "An oddly shaped hourglass made from lazurite and aqua jade. It was reportedly inspired by the bell tower in Petrichor." },
      { file: "Item_Promised_Dream_of_Days_Past.webp", name: "Promised Dream of Days Past", description: "An opulent vessel made based on the form of the legendary \"Pure Grail.\" It is said to be able to fulfill the wishes of the purest of people." },
      { file: "Item_Poetry_of_Days_Past.webp", name: "Poetry of Days Past", description: "A formal hat that was once in vogue amongst creators of opera in Fontaine. Word has it that its feathered adornment was based on the legendary helms of the Lochknights." },
    ]
  },
  {
    folder: "Tenacity of the Millelith",
    name: "Tenacity of the Millelith",
    element: "Geo",
    basePrice: 7500,
    description: "Martial relics honoring steadfast guardians of the realm.",
    pieces: [
      { file: "Item_Flower_of_Accolades.webp", name: "Flower of Accolades", description: "A flower made from gold leaf. It represents the glories and honors attained by its wearer." },
      { file: "Item_Ceremonial_War-Plume.webp", name: "Ceremonial War-Plume", description: "A falcon feather worn on ceremonial occasions. It displays the dignity and resolve of Liyue Harbor to the outside world." },
      { file: "Item_Orichalceous_Time-Dial.webp", name: "Orichalceous Time-Dial", description: "A simple device for telling time. This was once standard-issue for the Millelith during times of war." },
      { file: "Item_Noble's_Pledging_Vessel.webp", name: "Noble's Pledging Vessel", description: "A golden cup used by the Millelith to take their oaths. Still bears the lovely scent of wine." },
      { file: "Item_General's_Ancient_Helm.webp", name: "General's Ancient Helm", description: "A splendorous helmet from ages past. Clean the dust away and it will look brand-new once more." },
    ]
  },
  {
    folder: "Thunder Soother",
    name: "Thunder Soother",
    element: "Electro",
    basePrice: 6200,
    description: "Insulated charms crafted to withstand electric wrath.",
    pieces: [
      { file: "Item_Thundersoother's_Heart.webp", name: "Thundersoother's Heart", description: "A flower that blooms even amidst ferocious thunder and lightning. To this day, it still grants courage to travelers in thunderstorms." },
      { file: "Item_Thundersoother's_Plume.webp", name: "Thundersoother's Plume", description: "The feather of a predatory bird that soars through lightning storms. It was said to have been adopted as an insignia by the legendary hero who pacified thunder and lightning." },
      { file: "Item_Hour_of_Soothing_Thunder.webp", name: "Hour of Soothing Thunder", description: "A timepiece kept by the hero who conquered thunder and lightning. The tiny shards of Electro crystal within flow back and forth with the passing of time." },
      { file: "Item_Thundersoother's_Goblet.webp", name: "Thundersoother's Goblet", description: "The wine goblet from which the Thundersoother, who defeated the Beast of Thunder, once drank violet lightning." },
      { file: "Item_Thundersoother's_Diadem.webp", name: "Thundersoother's Diadem", description: "The crown given to the Thundersoother for defeating the Beast of Thunder that had been wreaking havoc upon the land." },
    ]
  },
  {
    folder: "Thundering Fury",
    name: "Thundering Fury",
    element: "Electro",
    basePrice: 8000,
    description: "Artifacts tempered by storms and lingering violet thunder.",
    pieces: [
      { file: "Item_Thunderbird's_Mercy.webp", name: "Thunderbird's Mercy", description: "A lightning-infused flower, somehow spared the fate of being trodden underfoot or reduced to ash by the furious purple fire, making it the sole survivor on the day of disaster." },
      { file: "Item_Survivor_of_Catastrophe.webp", name: "Survivor of Catastrophe", description: "A lightning-charged feather that still flickers with the wrath of the Thunderbird's cruel retribution." },
      { file: "Item_Hourglass_of_Thunder.webp", name: "Hourglass of Thunder", description: "The hourglass used to foretell the coming of the Thunderbird by the tribe that worshiped it. It has fallen into eternal silence now that the tribe is no more." },
      { file: "Item_Omen_of_Thunderstorm.webp", name: "Omen of Thunderstorm", description: "A ceremonial cup that holds the blood of the innocent. It is brimming with the thundering fury of the prayers that echo within." },
      { file: "Item_Thunder_Summoner's_Crown.webp", name: "Thunder Summoner's Crown", description: "A crown once worn by an ancient shaman who worshiped the Thunderbird. The capricious beast remained unmoved by the shaman's devotion." },
    ]
  },
  {
    folder: "Unfinished Reverie",
    name: "Unfinished Reverie",
    element: "Dendro",
    basePrice: 7600,
    description: "An incomplete dream recorded through delicate ornaments.",
    pieces: [
      { file: "Item_Dark_Fruit_of_Bright_Flowers.webp", name: "Dark Fruit of Bright Flowers", description: "A flower carved from grey stone covered with gold foil. Legends say that during a war, it was used to differentiate friend from foe." },
      { file: "Item_Faded_Emerald_Tail.webp", name: "Faded Emerald Tail", description: "A tail feather ornament whose luster has long faded. The patterns on it are said to have been etched by the hand of a skilled artisan from long ago." },
      { file: "Item_Moment_of_Attainment.webp", name: "Moment of Attainment", description: "A sundial used by an ancient kingdom to tell time. Tiny marks have been left at a certain scale that can only be seen through careful observation." },
      { file: "Item_The_Wine-Flask_Over_Which_the_Plan_Was_Hatched.webp", name: "The Wine-Flask Over Which the Plan Was Hatched", description: "A three-legged cup. Once, many heroes were gathered around the bonfire, raising their cups high in toast and drinking their fill while discussing their wishes and ambitions." },
      { file: "Item_Crownless_Crown.webp", name: "Crownless Crown", description: "A golden crown decorated with turquoise and emerald feathers, it has never been used in a coronation, living alone atop a velvet cushion." },
    ]
  },
  {
    folder: "Vermellion Hereafter",
    name: "Vermellion Hereafter",
    element: "Pyro",
    basePrice: 7800,
    description: "A solemn set steeped in remembrance and sacrifice.",
    pieces: [
      { file: "Item_Flowering_Life.webp", name: "Flowering Life", description: "An ancient memento. It still looks as alive as the being that preserved it several centuries ago." },
      { file: "Item_Feather_of_Nascent_Light.webp", name: "Feather of Nascent Light", description: "A dimly lustrous pinion steeped in strong memories." },
      { file: "Item_Solar_Relic.webp", name: "Solar Relic", description: "An ancient timepiece with a mighty solid look. Its luster is produced by sand crystal." },
      { file: "Item_Moment_of_the_Pact.webp", name: "Moment of the Pact", description: "An old cup made of sand crystal. Its luster is somehow undimmed by age." },
      { file: "Item_Thundering_Poise.webp", name: "Thundering Poise", description: "This mask is said to have been made by the mountain people for a Yaksha. It is of simple make, but its surface still shines brightly nonetheless." },
    ]
  },
  {
    folder: "Viridescent Venerer",
    name: "Viridescent Venerer",
    element: "Anemo",
    basePrice: 8000,
    description: "Windblessed regalia once worn by wandering heroes.",
    pieces: [
      { file: "Item_In_Remembrance_of_Viridescent_Fields.webp", name: "In Remembrance of Viridescent Fields", description: "A wild flower that was once a ubiquitous sight in its homeland. It was picked by a hunter who wore it on their chest." },
      { file: "Item_Viridescent_Arrow_Feather.webp", name: "Viridescent Arrow Feather", description: "The fletching of an arrow that once pierced right through its prey, but somehow still remains spotless." },
      { file: "Item_Viridescent_Venerer's_Determination.webp", name: "Viridescent Venerer's Determination", description: "A wondrous instrument that a hunter once wore. It forever points towards their prey." },
      { file: "Item_Viridescent_Venerer's_Vessel.webp", name: "Viridescent Venerer's Vessel", description: "A water pouch used by the Viridescent Venerer. Its capacity is much greater than one would expect." },
      { file: "Item_Viridescent_Venerer's_Diadem.webp", name: "Viridescent Venerer's Diadem", description: "A proud crown that once belonged to the Viridescent Venerer. It is as lush and green as the breezes of the wild." },
    ]
  },
  {
    folder: "Vourukasha's Glow",
    name: "Vourukasha's Glow",
    element: "Hydro",
    basePrice: 7600,
    description: "Sanctified pieces touched by ancient flowers and dew.",
    pieces: [
      { file: "Item_Stamen_of_Khvarena's_Origin.webp", name: "Stamen of Khvarena's Origin", description: "An insignia in the shape of a lovely little flower that was once worn by pilgrims in times long bygone." },
      { file: "Item_Vibrant_Pinion.webp", name: "Vibrant Pinion", description: "An exquisite feather-shaped decoration on which the vivid hues of verdant leaves and fragrant flowers shimmer." },
      { file: "Item_Ancient_Abscission.webp", name: "Ancient Abscission", description: "An ancient timepiece upon which the light of Khvarena gleams. It is filled with a pure liquid that appears alive." },
      { file: "Item_Feast_of_Boundless_Joy.webp", name: "Feast of Boundless Joy", description: "An opulent wine goblet that was once filled with nectar and honeydew, but is empty today." },
      { file: "Item_Heart_of_Khvarena's_Brilliance.webp", name: "Heart of Khvarena's Brilliance", description: "Intricate and vibrant earrings upon which the luster of a hundred flowers seems to flow." },
    ]
  },
  {
    folder: "Wanderer's Troupe",
    name: "Wanderer's Troupe",
    element: "Anemo",
    basePrice: 6500,
    description: "Mementos of traveling musicians and fading melodies.",
    pieces: [
      { file: "Item_Troupe's_Dawnlight.webp", name: "Troupe's Dawnlight", description: "A small flower-shaped insignia. If you listen carefully, you can almost hear a flute playing and voices singing." },
      { file: "Item_Bard's_Arrow_Feather.webp", name: "Bard's Arrow Feather", description: "An azure arrow fletching that has neither faded nor splintered with the passage of time. The sound of running water seems to linger around it." },
      { file: "Item_Concert's_Final_Hour.webp", name: "Concert's Final Hour", description: "An hourglass used to keep time during a band performance. It once made a crisp sound, but their performance has since ended." },
      { file: "Item_Wanderer's_String-Kettle.webp", name: "Wanderer's String-Kettle", description: "An ancient, strangely-shaped canteen. The interior is fitted with harp strings, which play a wondrous tune as the water flows out." },
      { file: "Item_Conductor's_Top_Hat.webp", name: "Conductor's Top Hat", description: "A top hat that has managed to retain its radiance despite braving the elements for time untold. An ancient tune still resonates within." },
    ]
  },
];

async function main() {
  console.log("ðŸŒ± Seeding database...\n");

  // Make seed rerunnable by clearing item-related data first.
  // Keep user/auth tables intact.
  console.log("Resetting existing seeded data...");
  // TrInventory references artifact/weapon IDs — clear it first to avoid FK issues
  // and to prevent stale itemId references when IDs are reassigned after re-seed.
  await prisma.trInventory.deleteMany({});
  await prisma.trBattle.deleteMany({});
  await prisma.msArtifact.deleteMany({});
  await prisma.msWeapon.deleteMany({});
  await prisma.msEnemy.deleteMany({});
  await prisma.msElement.deleteMany({});
  // Reset auto-increment so IDs always start from 1 after re-seed.
  // deleteMany() uses DELETE FROM (not TRUNCATE), so MariaDB does NOT
  // reset the sequence counter automatically — we must do it explicitly.
  await prisma.$executeRaw`ALTER TABLE MsArtifact AUTO_INCREMENT = 1`;
  await prisma.$executeRaw`ALTER TABLE MsWeapon AUTO_INCREMENT = 1`;
  await prisma.$executeRaw`ALTER TABLE MsEnemy AUTO_INCREMENT = 1`;
  await prisma.$executeRaw`ALTER TABLE MsElement AUTO_INCREMENT = 1`;
  console.log("  ✅ Existing item data cleared");

  // â”€â”€â”€ 1. Elements â”€â”€â”€
  console.log("Creating elements...");
  const elements = [
    { name: "Pyro", type: "Pyro", imageUrl: `${BASE_URL}/elements/pyro.webp` },
    { name: "Hydro", type: "Hydro", imageUrl: `${BASE_URL}/elements/hydro.webp` },
    { name: "Electro", type: "Electro", imageUrl: `${BASE_URL}/elements/electro.webp` },
    { name: "Cryo", type: "Cryo", imageUrl: `${BASE_URL}/elements/cryo.webp` },
    { name: "Dendro", type: "Dendro", imageUrl: `${BASE_URL}/elements/dendro.webp` },
    { name: "Anemo", type: "Anemo", imageUrl: `${BASE_URL}/elements/anemo.webp` },
    { name: "Geo", type: "Geo", imageUrl: `${BASE_URL}/elements/geo.webp` },
  ];
  const allElements = [];
  for (const el of elements) {
    const created = await prisma.msElement.create({ data: { ...el, createdAt: now, updatedAt: now, createdBy: "SEED" } });
    allElements.push(created);
  }
  const elMap: Record<string, number> = {};
  for (const el of allElements) elMap[el.type] = el.elementId;
  console.log(`  âœ… ${allElements.length} elements created`);

  // â”€â”€â”€ 2. Weapons â”€â”€â”€
  console.log("Creating weapons...");
  const weapons = [
    { elementId: elMap["Pyro"],    name: "A Thousand Blazing Suns",    type: "Claymore", description: "A blazing claymore forged from the essence of a thousand suns, wielded by the Flame-Touched hero of Natlan.",                                   stock: 3, price: 22000, damage: 2500, imageUrl: `${BASE_URL}/weapons/Weapon_A_Thousand_Blazing_Suns.webp` },
    { elementId: elMap["Dendro"],  name: "A Thousand Floating Dreams",  type: "Catalyst", description: "A catalyst born of a thousand dreaming flowers, enhancing elemental mastery and the power of elemental reactions.",                              stock: 4, price: 18000, damage: 1500, imageUrl: `${BASE_URL}/weapons/Weapon_A_Thousand_Floating_Dreams.webp` },
    { elementId: elMap["Hydro"],   name: "Absolution",                  type: "Sword",    description: "A sword of divine absolution wielded by the sovereign of the seas, granting tremendous critical damage to its bearer.",                           stock: 3, price: 19000, damage: 1500, imageUrl: `${BASE_URL}/weapons/Weapon_Absolution.webp` },
    { elementId: elMap["Electro"], name: "Azurelight",                  type: "Sword",    description: "A sword shimmering with azure radiance, cutting through darkness with electrifying precision and grace.",                                         stock: 3, price: 18000, damage: 2000, imageUrl: `${BASE_URL}/weapons/Weapon_Azurelight.webp` },
    { elementId: elMap["Anemo"],   name: "Crane's Echoing Call",        type: "Catalyst", description: "A catalyst resonant with the call of cranes riding wind currents, greatly empowering plunging attacks and aerial combat.",                        stock: 2, price: 20000, damage: 2500, imageUrl: `${BASE_URL}/weapons/Weapon_Crane's_Echoing_Call.webp` },
    { elementId: elMap["Pyro"],    name: "Crimson Moon's Semblance",    type: "Polearm",  description: "A crimson polearm that embodies the semblance of an eternal blood moon, amplifying the power of its wielder's bonds.",                           stock: 2, price: 22000, damage: 2500, imageUrl: `${BASE_URL}/weapons/Weapon_Crimson_Moon's_Semblance.webp` },
    { elementId: elMap["Cryo"],    name: "Golden Frostbound Oath",      type: "Sword",    description: "A golden sword bound by a sacred oath of eternal frost, granting immense power to those who uphold their solemn vows.",                          stock: 3, price: 19000, damage: 2000, imageUrl: `${BASE_URL}/weapons/Weapon_Golden_Frostbound_Oath.webp` },
    { elementId: elMap["Dendro"],  name: "Hunter's Path",               type: "Bow",      description: "A bow that lights the hunter's path through verdant forests, dramatically enhancing the wielder's elemental reaction damage.",                    stock: 4, price: 17000, damage: 1500, imageUrl: `${BASE_URL}/weapons/Weapon_Hunter's_Path.webp` },
    { elementId: elMap["Dendro"],  name: "Light of Foliar Incision",    type: "Sword",    description: "A sword gleaming with the precise light of nature's judgment, delivering devastating critical strikes with surgical precision.",                  stock: 3, price: 21000, damage: 2500, imageUrl: `${BASE_URL}/weapons/Weapon_Light_of_Foliar_Incision.webp` },
    { elementId: elMap["Hydro"],   name: "Lumidouce Elegy",             type: "Bow",      description: "A graceful bow that sings a tender elegy in flight, amplifying elemental power with each arrow loosed toward the enemy.",                        stock: 4, price: 17000, damage: 1500, imageUrl: `${BASE_URL}/weapons/Weapon_Lumidouce_Elegy.webp` },
    { elementId: elMap["Cryo"],    name: "Mistsplitter Reforged",       type: "Sword",    description: "A legendary sword reforged from eternal mist and ice, granting its wielder increasing elemental damage the more they wield their element.",      stock: 3, price: 21000, damage: 2500, imageUrl: `${BASE_URL}/weapons/Weapon_Mistsplitter_Reforged.webp` },
    { elementId: elMap["Cryo"],    name: "Polar Star",                  type: "Bow",      description: "A bow blessed by the light of the polar star, stacking ATK bonuses through sustained combat and rewarding aggressive engagement.",               stock: 3, price: 19000, damage: 2000, imageUrl: `${BASE_URL}/weapons/Weapon_Polar_Star.webp` },
    { elementId: elMap["Pyro"],    name: "Staff of Homa",               type: "Polearm",  description: "A polearm crafted from the ancient immortal flame of Homa, empowering its wielder greatly based on their remaining HP.",                        stock: 4, price: 20000, damage: 2000, imageUrl: `${BASE_URL}/weapons/Weapon_Staff_of_Homa.webp` },
  ];
  for (const w of weapons) {
    await prisma.msWeapon.create({ data: { ...w, createdAt: now, updatedAt: now, createdBy: "SEED" } });
  }
  console.log(`  âœ… ${weapons.length} weapons created`);

  // â”€â”€â”€ 3. Artifacts (scan filesystem, 5 pieces per set) â”€â”€â”€
  console.log("Creating artifacts...");
  const folders = fs.readdirSync(ARTIFACTS_DIR).filter(f => fs.statSync(path.join(ARTIFACTS_DIR, f)).isDirectory());
  const setConfigByFolder = Object.fromEntries(ARTIFACT_SETS.map((set) => [set.folder, set]));
  let artifactCount = 0;

  for (const folder of folders) {
    const cfg = setConfigByFolder[folder];
    const element = cfg?.element ?? "Geo";
    const basePrice = cfg?.basePrice ?? 8000;
    const setName = cfg?.name ?? folder;
    const setDescription = cfg?.description ?? folder;
    const stock = Math.floor(5 + Math.random() * 10);
    const files = fs.readdirSync(path.join(ARTIFACTS_DIR, folder)).filter(f => f.endsWith(".webp")).sort();
    for (let i = 0; i < PIECE_TYPES.length; i++) {
      const pieceType = PIECE_TYPES[i];
      const pieceData = cfg?.pieces?.[i];
      if (!pieceData || !pieceData.file) continue;

      const stats = PIECE_STATS[pieceType];
      const imageUrl = `${BASE_URL}/artifacts/${encodeURI(folder)}/${encodeURI(pieceData.file)}`;

      await prisma.msArtifact.create({
        data: {
          elementId: elMap[element],
          setName: setName,
          name: pieceData.name,
          type: pieceType,
          description: pieceData.description,
          stock,
          imageUrl,
          price: basePrice + stats.priceAdd,
          primaryStat: stats.primary,
          secondaryStat: stats.secondary,
          createdAt: now,
          updatedAt: now,
          createdBy: "SEED",
        },
      });
      artifactCount++;
    }  }
  console.log(`  ✅ ${artifactCount} artifacts created (${folders.length} sets × 5 pieces)`);

  // ─── 4. Enemies ───
  console.log("Creating enemies...");
  const enemies = [
    { elementId: elMap["Pyro"],    name: "Pyro Regisvine",        type: "Boss",  hp: 15000, damage: 800,  imageUrl: `${BASE_URL}/enemies/Enemy_Pyro_Regisvine.webp` },
    { elementId: elMap["Hydro"],   name: "Rhodeia of Loch",        type: "Boss",  hp: 25000, damage: 1200, imageUrl: `${BASE_URL}/enemies/Enemy_Rhodeia_of_Loch.webp` },
    { elementId: elMap["Electro"], name: "Thunder Manifestation",  type: "Boss",  hp: 30000, damage: 1500, imageUrl: `${BASE_URL}/enemies/Enemy_Thundering_Wayob_Manifestation.webp` },
    { elementId: elMap["Cryo"],    name: "Cryo Hypostasis",        type: "Boss",  hp: 20000, damage: 900,  imageUrl: `${BASE_URL}/enemies/Cryo_Hypostasis_Icon.webp` },
    { elementId: elMap["Anemo"],   name: "Maguu Kenki",            type: "Boss",  hp: 35000, damage: 1800, imageUrl: `${BASE_URL}/enemies/Enemy_Maguu_Kenki.webp` },
    { elementId: elMap["Geo"],     name: "Geo Hypostasis",         type: "Boss",  hp: 18000, damage: 750,  imageUrl: `${BASE_URL}/enemies/Enemy_Geo_Hypostasis.webp` },
    { elementId: elMap["Dendro"],  name: "Jadeplume Terrorshroom", type: "Boss",  hp: 45000, damage: 1100, imageUrl: `${BASE_URL}/enemies/Enemy_Jadeplume_Terrorshroom.webp` },
    { elementId: elMap["Electro"], name: "Aeonblight Drake",       type: "Elite", hp: 72000, damage: 2200, imageUrl: `${BASE_URL}/enemies/Enemy_Aeonblight_Drake.webp` },
  ];
  for (const e of enemies) {
    await prisma.msEnemy.create({ data: { ...e, createdAt: now, updatedAt: now, createdBy: "SEED" } });
  }
  console.log(`  ✅ ${enemies.length} enemies created`);

  console.log(`\n🎉 Seed complete! ${allElements.length} elements, ${weapons.length} weapons, ${artifactCount} artifacts, ${enemies.length} enemies`);
}

main()
  .catch((e) => { console.error("❌ Seed error:", e); process.exit(1); })
  .finally(() => prisma.$disconnect());
>>>>>>> 6b12a73 (update)
