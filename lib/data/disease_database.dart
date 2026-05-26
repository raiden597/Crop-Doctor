import '../models/crop_result.dart';

class LocalDisease {
  final String crop;
  final String diseaseName;
  final String severity;
  final String symptoms;
  final List<String> treatment;
  final List<String> prevention;
  final String pesticide;

  const LocalDisease({
    required this.crop,
    required this.diseaseName,
    required this.severity,
    required this.symptoms,
    required this.treatment,
    required this.prevention,
    required this.pesticide,
  });

  CropAnalysisResult toResult() => CropAnalysisResult(
        cropName: crop,
        diseaseName: diseaseName,
        isHealthy: false,
        severity: severity,
        confidence: 'Reference',
        symptoms: symptoms,
        treatment: treatment,
        prevention: prevention,
        pesticide: pesticide,
      );
}

class DiseaseDatabase {
  static const List<(String, String)> crops = [
    ('🌾', 'Rice'),
    ('🌿', 'Wheat'),
    ('🍅', 'Tomato'),
    ('🪴', 'Cotton'),
    ('🎋', 'Sugarcane'),
    ('🌽', 'Maize'),
    ('🥔', 'Potato'),
    ('🧅', 'Onion'),
    ('🌶️', 'Chilli'),
    ('🥜', 'Groundnut'),
  ];

  static List<LocalDisease> forCrop(String crop) =>
      _diseases.where((d) => d.crop == crop).toList();

  static const List<LocalDisease> _diseases = [
    // ── RICE ──────────────────────────────────────────────────────────────
    LocalDisease(
      crop: 'Rice',
      diseaseName: 'Rice Blast',
      severity: 'High',
      symptoms:
          'Diamond-shaped grey lesions with brown borders on leaves; neck rot causing white/empty heads',
      treatment: [
        'Remove and destroy infected plant material immediately',
        'Spray Tricyclazole 75% WP at 0.6g/L water',
        'Drain field water to reduce humidity',
      ],
      prevention: [
        'Use blast-resistant varieties (IR-64, Pusa Basmati)',
        'Avoid excess nitrogen fertilizer',
        'Maintain field sanitation — remove stubble after harvest',
      ],
      pesticide: 'Tricyclazole 75% WP (BEAM) — 0.6g/L water, 2 sprays 10 days apart',
    ),
    LocalDisease(
      crop: 'Rice',
      diseaseName: 'Bacterial Leaf Blight',
      severity: 'Medium',
      symptoms:
          'Water-soaked lesions at leaf margins turning yellow then white; milky bacterial ooze when stem is cut',
      treatment: [
        'Drain standing water from field',
        'Spray Copper Oxychloride 3g/L + Streptocycline 0.5g/L',
        'Reduce nitrogen application immediately',
      ],
      prevention: [
        'Use disease-free certified seed',
        'Avoid flood irrigation during tillering',
        'Plant resistant varieties (Pusa 44, Swarna Sub-1)',
      ],
      pesticide: 'Copper Oxychloride 50% WP — 3g/L + Streptocycline 0.5g/L water',
    ),
    LocalDisease(
      crop: 'Rice',
      diseaseName: 'Brown Plant Hopper',
      severity: 'High',
      symptoms:
          'Plants turn yellow then brown from base (hopper burn); small brown insects visible at stem base',
      treatment: [
        'Drain field for 3–5 days to expose insects',
        'Spray Buprofezin 25% SC at 1mL/L water',
        'Avoid excess nitrogen which attracts hoppers',
      ],
      prevention: [
        'Use resistant varieties (IR-36, Samba Mahsuri)',
        'Set up light traps for monitoring',
        'Avoid dense planting — maintain proper spacing',
      ],
      pesticide: 'Buprofezin 25% SC (Applaud) — 1mL/L water; or Imidacloprid 17.8% SL — 0.5mL/L',
    ),
    LocalDisease(
      crop: 'Rice',
      diseaseName: 'Sheath Blight',
      severity: 'Medium',
      symptoms:
          'Oval lesions with grey centers and brown borders on leaf sheath; lesions merge causing blight',
      treatment: [
        'Spray Hexaconazole 5% EC at 2mL/L water',
        'Reduce plant density if too dense',
        'Drain excess field water',
      ],
      prevention: [
        'Avoid very dense planting',
        'Balanced NPK fertilization — avoid excess nitrogen',
        'Remove crop debris after harvest',
      ],
      pesticide: 'Hexaconazole 5% EC (Contaf) — 2mL/L water, 2 sprays',
    ),

    // ── WHEAT ─────────────────────────────────────────────────────────────
    LocalDisease(
      crop: 'Wheat',
      diseaseName: 'Yellow Rust (Stripe Rust)',
      severity: 'High',
      symptoms:
          'Bright yellow/orange pustules arranged in stripes along leaf veins; heavy yellowing of leaves',
      treatment: [
        'Spray Propiconazole 25% EC at 1mL/L water at first sign',
        'Apply Tebuconazole 25.9% EC at 1mL/L as alternative',
        'Remove severely infected plants from edges',
      ],
      prevention: [
        'Use resistant varieties (HD-2967, PBW-550)',
        'Early sowing (October–November)',
        'Monitor during cool wet weather (10–15°C)',
      ],
      pesticide: 'Propiconazole 25% EC (Tilt) — 1mL/L water; 2 sprays 15 days apart',
    ),
    LocalDisease(
      crop: 'Wheat',
      diseaseName: 'Powdery Mildew',
      severity: 'Medium',
      symptoms:
          'White powdery fungal growth on leaves, stem and spikes; yellowing and drying of affected parts',
      treatment: [
        'Spray Wettable Sulfur 80% WP at 3g/L water',
        'Apply Carbendazim 50% WP at 1g/L as alternative',
        'Remove heavily infected plant parts',
      ],
      prevention: [
        'Avoid overly dense planting',
        'Use resistant varieties',
        'Ensure good air circulation through proper spacing',
      ],
      pesticide: 'Wettable Sulfur 80% WP — 3g/L water; or Carbendazim 50% WP — 1g/L',
    ),
    LocalDisease(
      crop: 'Wheat',
      diseaseName: 'Loose Smut',
      severity: 'Medium',
      symptoms:
          'Entire ear head replaced by black powdery mass (spores); infected heads appear before healthy ones',
      treatment: [
        'Remove and burn infected heads before spores spread',
        'No in-season cure — plan seed treatment for next crop',
        'Use only certified seed next season',
      ],
      prevention: [
        'Hot water seed treatment: soak at 52°C for 10 minutes, then dry',
        'Treat seed with Carboxin + Thiram (Vitavax) at 2g/kg seed',
        'Use smut-resistant varieties',
      ],
      pesticide: 'Carboxin 37.5% + Thiram 37.5% DS (Vitavax Power) — 2g/kg seed treatment',
    ),

    // ── TOMATO ────────────────────────────────────────────────────────────
    LocalDisease(
      crop: 'Tomato',
      diseaseName: 'Early Blight',
      severity: 'Medium',
      symptoms:
          'Brown spots with concentric rings (target-board pattern) on lower/older leaves; yellow halo around spots',
      treatment: [
        'Remove and destroy infected leaves immediately',
        'Spray Mancozeb 75% WP at 2g/L water',
        'Avoid overhead/sprinkler irrigation',
      ],
      prevention: [
        'Crop rotation — avoid tomato family crops in same plot',
        'Stake or cage plants to improve air circulation',
        'Mulch soil to reduce soil splash',
      ],
      pesticide: 'Mancozeb 75% WP (Indofil M-45) — 2g/L water, spray every 7–10 days',
    ),
    LocalDisease(
      crop: 'Tomato',
      diseaseName: 'Late Blight',
      severity: 'High',
      symptoms:
          'Large irregular dark brown water-soaked patches on leaves; white mold on leaf underside in humid conditions; fruit turns brown and rots',
      treatment: [
        'Spray Metalaxyl 8% + Mancozeb 64% WP at 2.5g/L immediately',
        'Remove and destroy infected plant parts',
        'Avoid working in field when wet to prevent spread',
      ],
      prevention: [
        'Use resistant varieties (Abhilash, Naveen)',
        'Avoid overhead irrigation',
        'Apply preventive fungicide sprays during cool wet spells',
      ],
      pesticide: 'Metalaxyl 8% + Mancozeb 64% WP (Ridomil Gold MZ) — 2.5g/L water',
    ),
    LocalDisease(
      crop: 'Tomato',
      diseaseName: 'Leaf Curl Virus',
      severity: 'High',
      symptoms:
          'Upward curling and yellowing of leaves; stunted growth; thick brittle leaves; flower and fruit drop',
      treatment: [
        'Uproot and destroy infected plants — no chemical cure for virus',
        'Control whitefly vector: spray Imidacloprid 0.5mL/L',
        'Remove nearby weed hosts',
      ],
      prevention: [
        'Use virus-resistant tomato varieties',
        'Install yellow sticky traps to monitor and catch whiteflies',
        'Use insect-proof nursery nets for raising seedlings',
      ],
      pesticide: 'Imidacloprid 17.8% SL (Confidor) — 0.5mL/L for whitefly vector control',
    ),
    LocalDisease(
      crop: 'Tomato',
      diseaseName: 'Fusarium Wilt',
      severity: 'High',
      symptoms:
          'Yellowing of lower leaves; wilting despite adequate watering; brown ring visible in cross-section of stem',
      treatment: [
        'Uproot and destroy infected plants — do not compost',
        'Drench soil with Carbendazim 1g/L around nearby plants',
        'Improve soil drainage',
      ],
      prevention: [
        'Crop rotation — at least 3 years before tomato again',
        'Soil solarization during summer (cover with plastic for 4–6 weeks)',
        'Use grafted seedlings on wilt-resistant rootstock',
      ],
      pesticide: 'Carbendazim 50% WP — 1g/L soil drench around plant base',
    ),

    // ── COTTON ────────────────────────────────────────────────────────────
    LocalDisease(
      crop: 'Cotton',
      diseaseName: 'Leaf Curl Virus',
      severity: 'High',
      symptoms:
          'Upward or downward curling of leaves; thickened veins; leaf-like outgrowths (enations) on underside',
      treatment: [
        'Remove and destroy infected plants promptly',
        'Spray Thiamethoxam 0.4g/L to control whitefly vector',
        'No direct chemical cure for the virus',
      ],
      prevention: [
        'Use CLCuV-tolerant Bt cotton varieties',
        'Avoid late planting (sow before June 15)',
        'Install yellow sticky traps; remove weed hosts',
      ],
      pesticide: 'Thiamethoxam 25% WG (Actara) — 0.4g/L water for whitefly control',
    ),
    LocalDisease(
      crop: 'Cotton',
      diseaseName: 'Pink Bollworm',
      severity: 'High',
      symptoms:
          'Pink larvae inside bolls; "rosette" (failed) flowers; small holes in bolls; premature boll shedding',
      treatment: [
        'Spray Emamectin Benzoate 5% SG at 0.5g/L water',
        'Set up pheromone traps (8 traps/acre)',
        'Collect and destroy fallen bolls and squares',
      ],
      prevention: [
        'Early sowing before June 15',
        'Use Bt cotton varieties',
        'Destroy crop residue — do not leave standing stalks after harvest',
      ],
      pesticide: 'Emamectin Benzoate 5% SG (Proclaim) — 0.5g/L water; or Spinosad 45% SC — 0.3mL/L',
    ),
    LocalDisease(
      crop: 'Cotton',
      diseaseName: 'Root Rot',
      severity: 'High',
      symptoms:
          'Sudden wilting; reddish-brown discoloration of roots and stem base; plant collapses',
      treatment: [
        'Uproot and remove infected plants',
        'Drench soil with Copper Oxychloride 3g/L around nearby plants',
        'Improve field drainage urgently',
      ],
      prevention: [
        'Crop rotation with non-host crops (cereals)',
        'Avoid waterlogged conditions',
        'Seed treatment with Trichoderma viride 4g/kg seed',
      ],
      pesticide: 'Copper Oxychloride 50% WP — 3g/L soil drench; Trichoderma-based biocontrol',
    ),

    // ── SUGARCANE ─────────────────────────────────────────────────────────
    LocalDisease(
      crop: 'Sugarcane',
      diseaseName: 'Red Rot',
      severity: 'High',
      symptoms:
          'Red discoloration with white patches inside stalk; sour/alcoholic smell; withering of top leaves',
      treatment: [
        'Uproot and burn all infected stools immediately',
        'Do not use infected setts for planting',
        'Treat planting setts with Carbendazim 1g/L water soak',
      ],
      prevention: [
        'Use disease-free healthy setts from certified sources',
        'Hot water treatment of setts at 50°C for 2 hours',
        'Plant resistant varieties (Co-0238, CoJ-88)',
      ],
      pesticide: 'Carbendazim 50% WP — 1g/L water, soak setts for 30 minutes before planting',
    ),
    LocalDisease(
      crop: 'Sugarcane',
      diseaseName: 'Smut',
      severity: 'Medium',
      symptoms:
          'Black whip-like structure (sorus) emerging from the growing tip; plant is stunted with many thin tillers',
      treatment: [
        'Uproot and destroy infected clumps entirely',
        'Do not allow whip to release spores — bag it before removal',
        'Disinfect tools used near infected plants',
      ],
      prevention: [
        'Hot water treatment of setts at 52°C for 30 minutes',
        'Use smut-resistant varieties (Co-0238)',
        'Use certified disease-free planting material',
      ],
      pesticide: 'Carbendazim 50% WP + hot water (50°C) sett treatment before planting',
    ),
    LocalDisease(
      crop: 'Sugarcane',
      diseaseName: 'Wilt (Fusarium)',
      severity: 'Medium',
      symptoms:
          'Yellowing and drying of leaves from top; purple discoloration at nodes; hollow stalk with foul smell',
      treatment: [
        'Remove and destroy infected plants',
        'Improve field drainage',
        'Drench soil with Carbendazim 2g/L around affected area',
      ],
      prevention: [
        'Crop rotation — avoid continuous sugarcane',
        'Good field drainage to prevent waterlogging',
        'Use healthy certified setts; avoid mechanical injury',
      ],
      pesticide: 'Carbendazim 50% WP — 2g/L sett treatment soak for 30 minutes',
    ),

    // ── MAIZE ─────────────────────────────────────────────────────────────
    LocalDisease(
      crop: 'Maize',
      diseaseName: 'Downy Mildew',
      severity: 'High',
      symptoms:
          'Pale green/yellow stripes on leaves; white downy fungal growth on leaf underside; excessive sterile tillering',
      treatment: [
        'Remove and destroy infected plants immediately',
        'Spray Metalaxyl 8% + Mancozeb 64% WP at 2.5g/L water',
        'Do not use infected fields for next maize crop',
      ],
      prevention: [
        'Treat seed with Metalaxyl 35% WS at 6g/kg seed',
        'Use resistant hybrids (HQPM-1, Pioneer varieties)',
        'Crop rotation with non-host crops',
      ],
      pesticide: 'Metalaxyl 8% + Mancozeb 64% WP — 2.5g/L water foliar spray',
    ),
    LocalDisease(
      crop: 'Maize',
      diseaseName: 'Northern Leaf Blight',
      severity: 'Medium',
      symptoms:
          'Long cigar-shaped grey-green to tan lesions (5–15cm) running with leaf veins; severe lesions merge',
      treatment: [
        'Spray Propiconazole 25% EC at 1mL/L water',
        'Remove lower infected leaves to reduce inoculum',
        'Apply at early tasseling stage for best results',
      ],
      prevention: [
        'Use resistant hybrids',
        'Crop rotation with non-grass crops',
        'Balanced NPK — avoid excess nitrogen',
      ],
      pesticide: 'Propiconazole 25% EC (Tilt) — 1mL/L water; or Mancozeb 75% WP — 2g/L',
    ),
    LocalDisease(
      crop: 'Maize',
      diseaseName: 'Stalk Rot',
      severity: 'High',
      symptoms:
          'Lower stalk becomes soft and spongy; plant lodges; pith turns grey-pink inside; premature ripening',
      treatment: [
        'Harvest early if stalk rot detected — do not wait for full maturity',
        'Remove and destroy infected plant material',
        'No effective in-season chemical treatment',
      ],
      prevention: [
        'Balanced NPK fertilization — potassium reduces stalk rot',
        'Avoid waterlogging; ensure good drainage',
        'Use tolerant hybrids; proper plant population',
      ],
      pesticide: 'Carbendazim 50% WP — 1g/L preventive soil drench at base; Trichoderma as biocontrol',
    ),

    // ── POTATO ────────────────────────────────────────────────────────────
    LocalDisease(
      crop: 'Potato',
      diseaseName: 'Late Blight',
      severity: 'High',
      symptoms:
          'Brown/black water-soaked patches on leaves with pale green border; white mold on underside in humid weather; tubers turn brown and rot',
      treatment: [
        'Spray Metalaxyl 8% + Mancozeb 64% WP at 2.5g/L immediately',
        'Remove and destroy infected haulm (tops)',
        'Avoid overhead irrigation; improve air circulation',
      ],
      prevention: [
        'Use certified disease-free seed tubers',
        'Apply preventive fungicide sprays every 7 days in cool wet weather',
        'Ensure good drainage; avoid dense planting',
      ],
      pesticide: 'Metalaxyl 8% + Mancozeb 64% WP (Ridomil Gold) — 2.5g/L water',
    ),
    LocalDisease(
      crop: 'Potato',
      diseaseName: 'Early Blight',
      severity: 'Medium',
      symptoms:
          'Dark brown spots with concentric rings on older lower leaves; yellow halo; severe defoliation',
      treatment: [
        'Remove infected lower leaves',
        'Spray Mancozeb 75% WP at 2g/L water',
        'Avoid overhead irrigation',
      ],
      prevention: [
        'Crop rotation with non-solanaceous crops',
        'Balanced fertilization — adequate potassium',
        'Remove crop debris after harvest',
      ],
      pesticide: 'Mancozeb 75% WP (Indofil M-45) — 2g/L water; or Chlorothalonil 75% WP — 2g/L',
    ),
    LocalDisease(
      crop: 'Potato',
      diseaseName: 'Black Scurf (Rhizoctonia)',
      severity: 'Low',
      symptoms:
          'Black crusty patches (sclerotia) on tuber surface; stem canker at base; aerial tubers; stunted plants',
      treatment: [
        'Treat seed tubers with Carbendazim 2g/L soak before planting',
        'Avoid planting in cold wet soils',
        'Hill up soil around plants to reduce stem exposure',
      ],
      prevention: [
        'Use certified disease-free seed tubers',
        'Crop rotation — 3 years before potato again in same plot',
        'Plant at correct depth in well-drained soil',
      ],
      pesticide: 'Carbendazim 50% WP — 2g/L water, soak seed pieces for 30 minutes',
    ),

    // ── ONION ─────────────────────────────────────────────────────────────
    LocalDisease(
      crop: 'Onion',
      diseaseName: 'Purple Blotch',
      severity: 'Medium',
      symptoms:
          'Small white sunken spots on leaves turning purple with yellow margin; severe tip dieback and leaf collapse',
      treatment: [
        'Spray Iprodione 50% WP at 2g/L water',
        'Apply Mancozeb 75% WP at 2g/L as alternative',
        'Remove severely infected leaves and destroy',
      ],
      prevention: [
        'Avoid overhead irrigation — use drip if possible',
        'Crop rotation with non-allium crops',
        'Balanced nutrition — avoid potassium deficiency',
      ],
      pesticide: 'Iprodione 50% WP (Rovral) — 2g/L water; or Mancozeb 75% WP — 2g/L',
    ),
    LocalDisease(
      crop: 'Onion',
      diseaseName: 'Thrips',
      severity: 'Medium',
      symptoms:
          'Silver-white streaks and distorted/curled leaves; tiny yellowish insects visible in leaf folds; stunted bulbs',
      treatment: [
        'Spray Imidacloprid 17.8% SL at 0.5mL/L water',
        'Install blue sticky traps (4–5 per acre)',
        'Apply Spinosad 45% SC at 0.3mL/L as alternative',
      ],
      prevention: [
        'Overhead irrigation helps wash thrips off plants',
        'Intercrop with coriander to attract natural predators',
        'Remove weed hosts around field boundaries',
      ],
      pesticide: 'Imidacloprid 17.8% SL (Confidor) — 0.5mL/L water; or Spinosad 45% SC — 0.3mL/L',
    ),
    LocalDisease(
      crop: 'Onion',
      diseaseName: 'Basal Rot',
      severity: 'High',
      symptoms:
          'Yellowing and dieback of outer leaves; pink/red discoloration at bulb base; roots rot; plant easily pulled out',
      treatment: [
        'Remove and destroy infected plants immediately',
        'Drench soil with Carbendazim 1g/L around nearby plants',
        'Improve field drainage',
      ],
      prevention: [
        'Crop rotation — avoid onion/garlic/leek family for 3 years',
        'Avoid waterlogging; raised bed planting',
        'Treat transplants with Carbendazim 1g/L dip before planting',
      ],
      pesticide: 'Carbendazim 50% WP — 1g/L soil drench or transplant dip',
    ),

    // ── CHILLI ────────────────────────────────────────────────────────────
    LocalDisease(
      crop: 'Chilli',
      diseaseName: 'Anthracnose (Fruit Rot)',
      severity: 'High',
      symptoms:
          'Circular sunken tan-brown spots on ripe fruits; orange/salmon-coloured spore masses in centre; fruit rots and shrivels',
      treatment: [
        'Remove and destroy infected fruits immediately — do not leave on plant',
        'Spray Carbendazim 12% + Mancozeb 63% WP at 2g/L water',
        'Avoid wetting fruits during irrigation',
      ],
      prevention: [
        'Use disease-free certified seed',
        'Crop rotation — avoid chilli after tomato or potato',
        'Handle fruits carefully — avoid physical injury during harvest',
      ],
      pesticide: 'Carbendazim 12% + Mancozeb 63% WP (Companion) — 2g/L water, spray every 10 days',
    ),
    LocalDisease(
      crop: 'Chilli',
      diseaseName: 'Leaf Curl Virus',
      severity: 'High',
      symptoms:
          'Upward curling and yellowing of leaves; stunted plant; thick brittle leaves; severe flower and fruit drop',
      treatment: [
        'Uproot and destroy severely infected plants',
        'Spray Thiamethoxam 0.4g/L to control whitefly vector',
        'No chemical cure for the virus itself',
      ],
      prevention: [
        'Raise seedlings under insect-proof net',
        'Install yellow sticky traps (4–5/acre)',
        'Use virus-tolerant varieties if available',
      ],
      pesticide: 'Thiamethoxam 25% WG (Actara) — 0.4g/L for whitefly control; rotate with Imidacloprid',
    ),
    LocalDisease(
      crop: 'Chilli',
      diseaseName: 'Powdery Mildew',
      severity: 'Low',
      symptoms:
          'White powdery fungal patches on upper leaf surface; yellowing; premature leaf drop in severe cases',
      treatment: [
        'Spray Wettable Sulfur 80% WP at 3g/L water',
        'Apply Hexaconazole 5% EC at 2mL/L as alternative',
        'Improve air circulation by pruning dense growth',
      ],
      prevention: [
        'Avoid overly dense planting',
        'Do not over-irrigate — avoid high humidity',
        'Remove and destroy infected plant debris',
      ],
      pesticide: 'Wettable Sulfur 80% WP — 3g/L water; or Hexaconazole 5% EC — 2mL/L',
    ),

    // ── GROUNDNUT ─────────────────────────────────────────────────────────
    LocalDisease(
      crop: 'Groundnut',
      diseaseName: 'Tikka / Leaf Spot',
      severity: 'Medium',
      symptoms:
          'Circular brown spots on upper leaf surface with yellow halo; dark spots on leaf underside; premature defoliation',
      treatment: [
        'Spray Chlorothalonil 75% WP at 2g/L water',
        'Apply Carbendazim 50% WP at 1g/L as alternative',
        'Remove severely infected leaves',
      ],
      prevention: [
        'Crop rotation — avoid groundnut in same field continuously',
        'Balanced nitrogen and calcium nutrition',
        'Remove and destroy crop debris after harvest',
      ],
      pesticide: 'Chlorothalonil 75% WP (Kavach) — 2g/L water, spray every 10–14 days',
    ),
    LocalDisease(
      crop: 'Groundnut',
      diseaseName: 'Stem Rot (White Mold)',
      severity: 'High',
      symptoms:
          'White cottony fungal mat at stem base; small mustard-seed-sized brown sclerotia; rapid wilting and plant death',
      treatment: [
        'Remove and destroy infected plants including roots and soil around them',
        'Drench soil with Carbendazim 1g/L around nearby plants',
        'Improve drainage; avoid waterlogging',
      ],
      prevention: [
        'Deep plowing before planting to bury sclerotia',
        'Soil solarization during summer',
        'Apply Trichoderma harzianum as soil treatment at 2.5kg/acre',
      ],
      pesticide: 'Carbendazim 50% WP — 1g/L soil drench; Trichoderma harzianum biological control',
    ),
    LocalDisease(
      crop: 'Groundnut',
      diseaseName: 'Rust',
      severity: 'Medium',
      symptoms:
          'Small orange-brown pustules on leaf underside; yellow pustule ring visible from top; severe defoliation in late season',
      treatment: [
        'Spray Propiconazole 25% EC at 1mL/L water at first sign',
        'Apply Mancozeb 75% WP at 2g/L as protectant spray',
        'Start sprays before 60 days after sowing in rust-prone areas',
      ],
      prevention: [
        'Early planting to escape late-season rust pressure',
        'Crop rotation with non-legume crops',
        'Remove volunteer groundnut plants from field edges',
      ],
      pesticide: 'Propiconazole 25% EC (Tilt) — 1mL/L water; 2–3 sprays at 15-day intervals',
    ),
  ];
}
