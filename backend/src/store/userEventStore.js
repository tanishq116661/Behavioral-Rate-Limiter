const { maxEventsPerUser } = require('../config');

const store = new Map();

function getOrCreateUserBucket(userId) {
  if (!store.has(userId)) {
    store.set(userId, {
      events: [],
      createdAt: Date.now(),
      updatedAt: Date.now(),
    });
  }

  return store.get(userId);
}

function addEvent(userId, event) {
  const bucket = getOrCreateUserBucket(userId);
  bucket.events.push(event);
  bucket.updatedAt = Date.now();

  if (bucket.events.length > maxEventsPerUser) {
    bucket.events.splice(0, bucket.events.length - maxEventsPerUser);
  }

  return bucket;
}

function getUserEvents(userId) {
  return getOrCreateUserBucket(userId).events;
}

function getUserSummary(userId) {
  const bucket = getOrCreateUserBucket(userId);
  return {
    userId,
    totalEvents: bucket.events.length,
    createdAt: bucket.createdAt,
    updatedAt: bucket.updatedAt,
    latestEvent: bucket.events[bucket.events.length - 1] || null,
  };
}

function getAllSummaries() {
  const summaries = [];
  for (const [userId, bucket] of store.entries()) {
    summaries.push({
      userId,
      totalEvents: bucket.events.length,
      createdAt: bucket.createdAt,
      updatedAt: bucket.updatedAt,
      latestEvent: bucket.events[bucket.events.length - 1] || null,
    });
  }
  return summaries;
}

module.exports = {
  addEvent,
  getUserEvents,
  getUserSummary,
  getAllSummaries,
};
