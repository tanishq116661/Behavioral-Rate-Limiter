const { modelMode, pythonInferenceUrl } = require('../config');

function clamp(value, min, max) {
  return Math.max(min, Math.min(max, value));
}

function decide(score) {
  if (score >= 0.50) return 'block';
  return 'allow';
}

function heuristicScore(features) {
  let score = 0;

  if (features.total_fwd_packets > 120) score += 0.30;
  if (features.flow_iat_mean > 0 && features.flow_iat_mean < 150) score += 0.15;
  if (features.iat_cv < 0.08) score += 0.30;
  if (features.flow_duration > 120000) score += 0.10;
  if (features.down_up_ratio > 6) score += 0.10;
  if (features.packet_length_std < 20) score += 0.10;

  return clamp(score, 0, 1);
}

async function inferWithPython(features) {
  const payload = { features };

  const response = await fetch(pythonInferenceUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(payload),
  });

  if (!response.ok) {
    throw new Error(`Python inference returned status ${response.status}`);
  }

  const data = await response.json();
  const riskScore = clamp(Number(data.riskScore), 0, 1);

  return {
    riskScore,
    decision: data.decision || decide(riskScore),
    source: 'python',
  };
}

async function scoreFeatures(features) {
  if (modelMode === 'python') {
    try {
      return await inferWithPython(features);
    } catch (error) {
      const fallbackScore = heuristicScore(features);
      return {
        riskScore: fallbackScore,
        decision: decide(fallbackScore),
        source: 'heuristic-fallback',
        warning: String(error.message || error),
      };
    }
  }

  const riskScore = heuristicScore(features);
  return {
    riskScore,
    decision: decide(riskScore),
    source: 'heuristic',
  };
}

module.exports = {
  scoreFeatures,
};
