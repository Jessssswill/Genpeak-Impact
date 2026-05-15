/** Maps artifact image filenames → Flower / Feather / Sands / Goblet / Circlet via weighted regex + best permutation. */

export const PIECE_TYPES = ["Flower", "Feather", "Sands", "Goblet", "Circlet"] as const;
export type PieceType = (typeof PIECE_TYPES)[number];

const PIECE_HINTS: Record<PieceType, { re: RegExp; w: number }[]> = {
  Flower: [
    { re: /opulent_dream/i, w: 100 },
    { re: /flower/i, w: 60 },
    { re: /(^|_)bloom(?!_times)/i, w: 55 },
    { re: /blossom|corsage|flora/i, w: 55 },
    { re: /lamp_of_the_lost/i, w: 70 },
    { re: /sea-dyed/i, w: 50 },
    { re: /entangling_bloom|soulscent_bloom|stainless_bloom/i, w: 60 },
    { re: /snowswept_memory/i, w: 65 },
    { re: /summer_night's_bloom/i, w: 60 },
    { re: /troupe's_dawnlight/i, w: 55 },
    { re: /dreaming_steelbloom/i, w: 55 },
    { re: /flowering_life/i, w: 50 },
    { re: /odyssean_flower|bloodstained_flower|witch's_flower|windborne_flower/i, w: 60 },
    { re: /bloom_of_the_mind/i, w: 55 },
    { re: /stamen_of/i, w: 50 },
    { re: /dark_fruit_of_bright_flowers/i, w: 55 },
    { re: /flower_of_acc/i, w: 55 },
    { re: /selfless_floral/i, w: 55 },
    { re: /golden_troupe's_reward/i, w: 65 },
    { re: /recollection_of_days_past/i, w: 55 },
    { re: /wilting_feast/i, w: 45 },
    { re: /the_first_days_of_the_city/i, w: 55 },
    { re: /magnificent_tsuba/i, w: 55 },
    { re: /thunderbird's_mercy/i, w: 58 },
    { re: /in_remembrance_of_viridescent/i, w: 55 },
    { re: /harmonious_symphony_prelude/i, w: 52 },
    { re: /lavawalker's_resolution/i, w: 58 },
    { re: /maiden's_fading_beauty/i, w: 58 },
  ],
  Feather: [
    { re: /parting_light/i, w: 100 },
    { re: /plume_of_luxury/i, w: 62 },
    { re: /plume(?!_of_luxury)/i, w: 58 },
    { re: /feather/i, w: 60 },
    { re: /pinion/i, w: 55 },
    { re: /sundered_feather/i, w: 60 },
    { re: /arrow_feather/i, w: 55 },
    { re: /war-plume|ceremonial_war-plume/i, w: 60 },
    { re: /bird's_shedding/i, w: 60 },
    { re: /scholar_of_vines/i, w: 55 },
    { re: /gladiator's_destiny/i, w: 60 },
    { re: /icebreaker's_resolve/i, w: 60 },
    { re: /deep_palace's_plume/i, w: 60 },
    { re: /vibrant_pinion|pristine_plume/i, w: 60 },
    { re: /nightingale's_tail_feather/i, w: 60 },
    { re: /feather_of_nascent|feather_of_judgment/i, w: 60 },
    { re: /viridescent_arrow_feather|bard's_arrow_feather/i, w: 60 },
    { re: /faded_emerald_tail/i, w: 50 },
    { re: /gust_of_nostalgia/i, w: 50 },
    { re: /heldenepos/i, w: 55 },
    { re: /unspoken_tale/i, w: 50 },
    { re: /end_of_the_golden_realm/i, w: 55 },
    { re: /forgotten_oath_of_days_past/i, w: 58 },
    { re: /demon-warrior's_feather/i, w: 58 },
    { re: /royal_plume/i, w: 58 },
    { re: /wicked_mage's_plumule/i, w: 58 },
    { re: /survivor_of_catastrophe/i, w: 58 },
    { re: /lavawalker's_torment/i, w: 58 },
    { re: /maiden's_heart-stricken/i, w: 58 },
  ],
  Sands: [
    { re: /sundial|hourglass|time-dial/i, w: 60 },
    { re: /pocket_watch|timepiece/i, w: 60 },
    { re: /copper_compass/i, w: 55 },
    { re: /compass/i, w: 35 },
    { re: /end_time/i, w: 55 },
    { re: /final_hour/i, w: 50 },
    { re: /moonlit_offering's_final_hour/i, w: 100 },
    { re: /storm_cage/i, w: 55 },
    { re: /frozen_homeland/i, w: 55 },
    { re: /a_time_of_insight/i, w: 55 },
    { re: /mystic's_gold_dial/i, w: 55 },
    { re: /morning_dew's_moment/i, w: 50 },
    { re: /shaft_of_remembrance/i, w: 55 },
    { re: /gladiator's_longing/i, w: 60 },
    { re: /minnesang/i, w: 55 },
    { re: /golden_song's_variation/i, w: 55 },
    { re: /echoing_sound_from_days_past/i, w: 55 },
    { re: /moment_of_(the_pact|cessation|judgment|attainment|oblivion)/i, w: 45 },
    { re: /hour_of_soothing/i, w: 55 },
    { re: /hourglass_of_thunder/i, w: 55 },
    { re: /faithful_hourglass/i, w: 55 },
    { re: /symbol_of_felicitation/i, w: 55 },
    { re: /moonlit_offering's_final_hour/i, w: 0 },
    { re: /concert's_final_hour|bloodstained_final_hour/i, w: 52 },
    { re: /timepiece_of_the_lost_path/i, w: 58 },
    { re: /flowing_rings/i, w: 45 },
    { re: /ichor_shower_rhapsody/i, w: 45 },
    { re: /viridescent_venerer's_determination/i, w: 55 },
    { re: /lavawalker's_epiphany/i, w: 58 },
    { re: /maiden's_passing_youth/i, w: 58 },
  ],
  Goblet: [
    { re: /goblet|chalice/i, w: 60 },
    { re: /claw_cup|wine-flask|string-kettle/i, w: 55 },
    { re: /calabash/i, w: 55 },
    { re: /pearl_cage/i, w: 55 },
    { re: /silver_urn/i, w: 50 },
    { re: /forgotten_vessel|scarlet_vessel/i, w: 55 },
    { re: /surpassing_cup/i, w: 60 },
    { re: /witch's_heart_flames/i, w: 55 },
    { re: /hopeful_heart/i, w: 50 },
    { re: /heart_of_khvarena/i, w: 50 },
    { re: /dawn's_brilliant_oath/i, w: 55 },
    { re: /noble's_pledging_vessel/i, w: 55 },
    { re: /labyrinth_wayfarer/i, w: 55 },
    { re: /gladiator's_intoxication/i, w: 60 },
    { re: /golden_era's_prelude/i, w: 55 },
    { re: /moonlit_offering's_libation/i, w: 55 },
    { re: /goblet_of_thundering_deep/i, w: 60 },
    { re: /thundersoother's_goblet/i, w: 60 },
    { re: /bloodstained_chevalier's_goblet/i, w: 60 },
    { re: /viridescent_venerer's_vessel/i, w: 55 },
    { re: /secret-keeper's_magic_bottle/i, w: 50 },
    { re: /defender_of_the_enchanting_dream/i, w: 52 },
    { re: /promised_dream_of_days_past/i, w: 52 },
    { re: /pre-banquet_of_the_contenders/i, w: 48 },
    { re: /grand_jape/i, w: 45 },
    { re: /heroes'_tea_party/i, w: 48 },
    { re: /revelation's_toll/i, w: 48 },
    { re: /omen_of_thunderstorm/i, w: 58 },
    { re: /lavawalker's_salvation/i, w: 58 },
    { re: /maiden's_distant_love/i, w: 58 },
  ],
  Circlet: [
    { re: /circlet/i, w: 60 },
    { re: /crown(?!less)|crownless_crown/i, w: 55 },
    { re: /mask/i, w: 48 },
    { re: /hat/i, w: 50 },
    { re: /helm/i, w: 55 },
    { re: /kabuto/i, w: 60 },
    { re: /diadem/i, w: 55 },
    { re: /tricorne/i, w: 60 },
    { re: /monocle/i, w: 55 },
    { re: /visage/i, w: 48 },
    { re: /scorching_hat/i, w: 60 },
    { re: /iron_mask/i, w: 60 },
    { re: /ornate_kabuto/i, w: 60 },
    { re: /broken_rime's_echo/i, w: 65 },
    { re: /laurel_coronet/i, w: 60 },
    { re: /capricious_visage/i, w: 60 },
    { re: /moonlit_offering's_silver_crown/i, w: 60 },
    { re: /a_note_in_spring/i, w: 55 },
    { re: /gladiator's_triumphus/i, w: 60 },
    { re: /golden_night's_bustle/i, w: 55 },
    { re: /amethyst_crown/i, w: 55 },
    { re: /veteran's_visage/i, w: 55 },
    { re: /mocking_mask/i, w: 60 },
    { re: /skeletal_hat/i, w: 55 },
    { re: /conductor's_top_hat/i, w: 55 },
    { re: /general's_ancient_helm/i, w: 60 },
    { re: /thundersoother's_diadem/i, w: 60 },
    { re: /mask_of_solitude/i, w: 60 },
    { re: /legacy_of_the_desert_high-born/i, w: 52 },
    { re: /poetry_of_days_past/i, w: 52 },
    { re: /whimsical_dance_of_the_withered/i, w: 48 },
    { re: /crown_of_watatsumi|crown_of_the_befallen|crown_of_the_saints/i, w: 55 },
    { re: /deep_gallery's_lost_crown/i, w: 52 },
    { re: /lavawalker's_wisdom/i, w: 58 },
    { re: /maiden's_fleeting_leisure/i, w: 58 },
    { re: /thunder_summoner's_crown/i, w: 62 },
  ],
};

function scoreFileForPieceType(filename: string, pieceType: PieceType): number {
  let score = 0;
  for (const { re, w } of PIECE_HINTS[pieceType]) {
    if (w === 0) continue;
    if (re.test(filename)) score += w;
  }
  return score;
}

/** All 5! permutations of indices 0..4 */
const PIECE_PERMUTATIONS: number[][] = (() => {
  const result: number[][] = [];
  const arr = [0, 1, 2, 3, 4];
  const used = [false, false, false, false, false];
  const path: number[] = [];
  function dfs() {
    if (path.length === 5) {
      result.push([...path]);
      return;
    }
    for (let i = 0; i < 5; i++) {
      if (used[i]) continue;
      used[i] = true;
      path.push(arr[i]);
      dfs();
      path.pop();
      used[i] = false;
    }
  }
  dfs();
  return result;
})();

export function assignFilesToPieceTypes(files: string[]): Record<PieceType, string> {
  if (files.length !== 5) {
    throw new Error(`Expected 5 .webp files per artifact set, got ${files.length}`);
  }
  let bestPerm = PIECE_PERMUTATIONS[0];
  let bestScore = -1;
  for (const perm of PIECE_PERMUTATIONS) {
    let total = 0;
    for (let i = 0; i < 5; i++) {
      total += scoreFileForPieceType(files[perm[i]], PIECE_TYPES[i]);
    }
    if (total > bestScore) {
      bestScore = total;
      bestPerm = perm;
    }
  }
  const out = {} as Record<PieceType, string>;
  for (let i = 0; i < 5; i++) {
    out[PIECE_TYPES[i]] = files[bestPerm[i]];
  }
  return out;
}
