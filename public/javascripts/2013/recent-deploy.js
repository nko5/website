// jade --client --no-debug views/index/recent-deploy.jade 
function recentDeploy(locals) {
var buf = [];
var locals_ = (locals || {}),team = locals_.team,lastDeploy = locals_.lastDeploy,lastDeployedAt = locals_.lastDeployedAt,relativeDate = locals_.relativeDate;buf.push("<div" + (jade.attrs({ 'data-team-id':(team.id), "class": [('recent-deploy'),('clearfix')] }, {"data-team-id":true})) + "><div class=\"row\"><div class=\"col col-lg-3 col-md-3 col-sm-3\"><div class=\"screenshot\"><img" + (jade.attrs({ 'src':("" + (team.screenshot) + "") }, {"src":true})) + "/></div></div><div class=\"col col-lg-9 col-md-9 col-sm-9\"><div class=\"actions\"><a" + (jade.attrs({ 'href':("/teams/" + (team.slug) + ""), "class": [('btn'),('btn-primary')] }, {"href":true})) + ">Show Team</a>");
if ( team.entry && team.entry.url)
{
buf.push("<a" + (jade.attrs({ 'href':("" + (team.entry.url) + ""), "class": [('btn'),('btn-primary')] }, {"href":true})) + ">Launch Site</a>");
}
buf.push("</div><div class=\"team-name\"><a" + (jade.attrs({ 'href':("/teams/" + (team.slug) + "") }, {"href":true})) + ">" + (jade.escape(null == (jade.interp = team.name) ? "" : jade.interp)) + "</a></div><div class=\"team-deployed-at\">");
if ( lastDeploy = team.lastDeploy)
{
buf.push("deployed&nbsp;");
lastDeployedAt = new Date(lastDeploy.createdAt)
buf.push(jade.escape(null == (jade.interp = relativeDate(lastDeployedAt)) ? "" : jade.interp));
}
buf.push("</div><div" + (jade.attrs({ 'data-team-id':(team.id), "class": [('team-stats'),('clearfix')] }, {"data-team-id":true})) + "><li class=\"commits\"><span class=\"count number\">" + (jade.escape(null == (jade.interp = team.stats.commits) ? "" : jade.interp)) + "</span> Commits</li><li class=\"pushes\"><span class=\"count number\">" + (jade.escape(null == (jade.interp = team.stats.pushes) ? "" : jade.interp)) + "</span> Pushes</li><li class=\"deploys\"><span class=\"count number\">" + (jade.escape(null == (jade.interp = team.stats.deploys) ? "" : jade.interp)) + "</span> Deploys</li></div></div></div></div>");;return buf.join("");
}