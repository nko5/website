db.teams.update({}, { $set: { judgeVisitedAt: new Date(0) }}, false, true)
