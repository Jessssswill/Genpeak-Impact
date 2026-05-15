const fs = require('fs');

const seedPath = 'prisma/seed.ts';
let content = fs.readFileSync(seedPath, 'utf8');

const appendText = `  }
  console.log(\`  ✅ \${artifactCount} artifacts created (\${folders.length} sets × 5 pieces)\`);

  // ─── 4. Enemies ───
  console.log("Creating enemies...");
  const enemies = [
    { elementId: elMap["Pyro"], name: "Pyro Regisvine", type: "Boss", hp: 15000, damage: 800, imageUrl: \`\${BASE_URL}/enemies/pyro_regisvine.webp\` },
    { elementId: elMap["Hydro"], name: "Oceanid", type: "Boss", hp: 25000, damage: 1200, imageUrl: \`\${BASE_URL}/enemies/oceanid.webp\` },
    { elementId: elMap["Electro"], name: "Thunder Manifestation", type: "Boss", hp: 30000, damage: 1500, imageUrl: \`\${BASE_URL}/enemies/thunder_manifestation.webp\` },
    { elementId: elMap["Cryo"], name: "Cryo Hypostasis", type: "Boss", hp: 20000, damage: 900, imageUrl: \`\${BASE_URL}/enemies/cryo_hypostasis.webp\` },
    { elementId: elMap["Anemo"], name: "Maguu Kenki", type: "Boss", hp: 35000, damage: 1800, imageUrl: \`\${BASE_URL}/enemies/maguu_kenki.webp\` },
    { elementId: elMap["Geo"], name: "Geo Hypostasis", type: "Boss", hp: 18000, damage: 750, imageUrl: \`\${BASE_URL}/enemies/geo_hypostasis.webp\` },
    { elementId: elMap["Dendro"], name: "Jadeplume Terrorshroom", type: "Boss", hp: 28000, damage: 1300, imageUrl: \`\${BASE_URL}/enemies/jadeplume_terrorshroom.webp\` },
    { elementId: elMap["Electro"], name: "Aeonblight Drake", type: "Elite", hp: 40000, damage: 2000, imageUrl: \`\${BASE_URL}/enemies/aeonblight_drake.webp\` },
  ];
  for (const e of enemies) {
    await prisma.msEnemy.create({ data: { ...e, createdAt: now, updatedAt: now, createdBy: "SEED" } });
  }
  console.log(\`  ✅ \${enemies.length} enemies created\`);

  console.log(\`\\n🎉 Seed complete! \${allElements.length} elements, \${weapons.length} weapons, \${artifactCount} artifacts, \${enemies.length} enemies\`);
}

main()
  .catch((e) => { console.error("❌ Seed error:", e); process.exit(1); })
  .finally(() => prisma.$disconnect());
`;

content += appendText;

fs.writeFileSync(seedPath, content);
console.log('Appended missing text.');
