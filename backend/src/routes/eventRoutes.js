const express = require('express');
const { addEvent, getUserEvents, getUserSummary } = require('../store/userEventStore');
const { computeBehaviorFeatures } = require('../services/behaviorService');
const { scoreFeatures } = require('../services/modelClient');
const { getAllSummaries } = require('../store/userEventStore');

const router = express.Router();

function parseEventInput(body) {
  if (!body || typeof body !== 'object') {
    throw new Error('Invalid request body');
  }

  if (!body.userId || !String(body.userId).trim()) {
    throw new Error('userId is required');
  }

  const timestamp = Number.isFinite(Number(body.timestamp)) ? Number(body.timestamp) : Date.now();

  const payloadBytes = Number(body.payloadBytes);
  const responseBytes = Number(body.responseBytes);

  return {
    userId: String(body.userId).trim(),
    path: String(body.path || '/'),
    method: String(body.method || 'GET').toUpperCase(),
    protocol: body.protocol || 'tcp',
    timestamp,
    payloadBytes: Number.isFinite(payloadBytes) ? payloadBytes : 0,
    responseBytes: Number.isFinite(responseBytes) ? responseBytes : 0,
  };
}

router.post('/events', async (req, res) => {
  try {
    const event = parseEventInput(req.body);
    addEvent(event.userId, event);

    const events = getUserEvents(event.userId);
    const features = computeBehaviorFeatures(events);
    const inference = await scoreFeatures(features);

    res.status(200).json({
      userId: event.userId,
      riskScore: inference.riskScore,
      decision: inference.decision,
      source: inference.source,
      warning: inference.warning,
      features,
    });
  } catch (error) {
    res.status(400).json({
      error: String(error.message || error),
    });
  }
});

router.get('/users/:userId/summary', (req, res) => {
  const userId = String(req.params.userId || '').trim();
  if (!userId) {
    res.status(400).json({ error: 'userId is required' });
    return;
  }

  const events = getUserEvents(userId);
  const features = computeBehaviorFeatures(events);
  const summary = getUserSummary(userId);

  res.status(200).json({
    ...summary,
    features,
  });
});

router.get('/dashboard/all', async (req, res) => {
  try {
    const users = getAllSummaries();
    const detailedSummaries = await Promise.all(users.map(async (user) => {
      const events = getUserEvents(user.userId);
      const features = computeBehaviorFeatures(events);
      const inference = await scoreFeatures(features);

      return {
        ...user,
        riskScore: inference.riskScore,
        decision: inference.decision,
        features
      };
    }));

    res.status(200).json(detailedSummaries);
  } catch (error) {
    res.status(500).json({error: String(error.message || error)});
  }
})

module.exports = router;
