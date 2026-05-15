const SUBSTAT_POOLS = {
    'CRIT Rate': [2.7, 3.1, 3.5, 3.9],
    'CRIT DMG': [5.4, 6.2, 7.0, 7.8],
    'ATK%': [4.1, 4.7, 5.3, 5.8],
    'HP%': [4.1, 4.7, 5.3, 5.8],
    'DEF%': [5.1, 5.8, 6.6, 7.3],
    'Elemental Mastery': [16, 19, 21, 23],
    'Energy Recharge': [4.5, 5.2, 5.8, 6.5],
    'ATK': [14, 16, 18, 19],
    'HP': [209, 239, 269, 299],
    'DEF': [16, 19, 21, 23]
};

const MAIN_STAT_NAMES = {
    'Flower': 'HP',
    'Feather': 'ATK',
    'Sands': 'ATK%',
    'Goblet': 'Elemental DMG Bonus',
    'Circlet': 'CRIT DMG'
};

export const generateInitialSubstats = (type: string): { stat: string; value: number }[] => {
    // Artifacts start with 1 substat at purchase.
    // Each enhancement unlock adds a new substat (up to 4), then upgrades existing ones.
    const mainStatName = MAIN_STAT_NAMES[type as keyof typeof MAIN_STAT_NAMES] || 'ATK';
    const availableStats = Object.keys(SUBSTAT_POOLS).filter(s => s !== mainStatName);
    const shuffled = availableStats.sort(() => 0.5 - Math.random());
    const stat = shuffled[0];
    const pool = SUBSTAT_POOLS[stat as keyof typeof SUBSTAT_POOLS];
    const value = pool[Math.floor(Math.random() * pool.length)];
    return [{ stat, value }];
};

export const upgradeSubstats = (currentSubstats: { stat: string; value: number }[]): { stat: string; value: number }[] => {
    const newSubstats = [...currentSubstats];
    
    if (newSubstats.length < 4) {
        // Add a 4th random substat
        const existingNames = newSubstats.map(s => s.stat);
        // Exclude existing ones
        const availableStats = Object.keys(SUBSTAT_POOLS).filter(s => !existingNames.includes(s));
        const stat = availableStats[Math.floor(Math.random() * availableStats.length)];
        const pool = SUBSTAT_POOLS[stat as keyof typeof SUBSTAT_POOLS];
        const value = pool[Math.floor(Math.random() * pool.length)];
        newSubstats.push({ stat, value });
    } else {
        // Upgrade a random existing substat
        const targetIndex = Math.floor(Math.random() * newSubstats.length);
        const stat = newSubstats[targetIndex].stat;
        const pool = SUBSTAT_POOLS[stat as keyof typeof SUBSTAT_POOLS];
        const addedValue = pool[Math.floor(Math.random() * pool.length)];
        
        // Use string to fix precision issues in JS floats
        newSubstats[targetIndex].value = Number((newSubstats[targetIndex].value + addedValue).toFixed(1));
    }
    
    return newSubstats;
};
