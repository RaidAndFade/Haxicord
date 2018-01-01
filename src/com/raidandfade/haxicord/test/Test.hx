package com.raidandfade.haxicord.test;

import com.raidandfade.haxicord.websocket.WebSocketConnection;
import haxe.Json;
import haxe.Timer;

import com.raidandfade.haxicord.types.Guild;
import com.raidandfade.haxicord.types.GuildMember;
import com.raidandfade.haxicord.types.Message;
import com.raidandfade.haxicord.types.Snowflake;

//TODO ratelimits are broken ~ bypassed on JS and nonexistant on neko
//TODO ehm... stackoverflow on neko boiz

class Test
{

	static var discordBot:DiscordClient;

	static function main()
	{
		discordBot = new DiscordClient("");
		discordBot.onReady = onReady;
		discordBot.onMessage = onMessage;
		discordBot.onMemberJoin = onMemberJoin;

		discordBot.start();
	}

	public static function onMessage(m:Message){
		if(m.content=="!ping"){
			m.reply({"content":"pong!"});
		}
		if(m.content.substr(0,7)=="!sendto"){
			var d = m.content.split(" ");
			var i = d[1];
			var m = StringTools.replace(m.content,"!sendto "+i," ");
			discordBot.sendMessage(i,{"content":m},function(m,e){
				if(e!=null)trace(e);
			});
		}
	}

	public static function onReady(){
		trace("Loaded up.");
try{
		for(g in discordBot.guildCache){
			if(g.owner_id.equals(discordBot.user.id)){
				g.delete(function(_,e){
					if(e!=null)return trace(e);
					trace("Deleted"+g.id); 
				});
			}
		}
		discordBot.listVoiceRegions(function(r,e){
			if(e!=null)trace(e);
			discordBot.createGuild({
				name:"Haxitest",
				region:r[0].id,
				icon:"iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABGdBTUEAANkE3LLaAgAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAABmJLR0QA/wD/AP+gvaeTAAAAB3RJTUUH4QcQCToczYxQsQAAB4FJREFUWMPNl0tsnFcVx3/nfg/bMx6PPePacVxP3PSRtGrjRpg2SRFCtKpggdIFahGLdlcosC0sKRKsWFKiVKxaCSFVSLDgUSqxbJK2RqahoYWkInacRn7NeDKZ13e/ew+L77Mdp120BQmOdDUjne/e87//e57wPxb5NB+/+XPwPTBDxMZQAgZzVc97Wr5LYgbh4e/+FwG88SL8awMO7aOCMC9wAuVBhRowkn92XWAZ4a+qnAEWLq1Tr43BI9/7jADOnoI4AK+MITwp8Iwqc0DBBBFBXMSEGQE+7eGSNt5ZgI4I7yi8jPKqERqJg+Pf+RQAFl4Cr4gIDwm8oMqjJoiiocqdjMwcY3hijnh4miDOCHBJi+TGCjfW3uH6lXN06x/gnbUi/Fmz/W8ZQee/9QkAvH0aVBFj+DrwU1QOFMbvZOL+JyjXThAOVYAQCPLtAvh8paTdOs3lM6y9+xs6Gx+A6BLwvPf8WgT9/Lf32gtuNX7kJKz/kyeBn4mE0+OHvkztC89SmroXE7JjCHX5sqAJ0APpYUJPoXqA8sxRvO3QrS+Pgv+iCMtHTnLh5N3wi999DANvnoZAQJVjIvxKJJydfOCrTB19AhMawJD2UzobKxQn7iOIS6D5dlFc0qK99h6F8dsJB0LA41PHtcXfsvq3P6KaLgHfAM6pwjYTZhuAAVSpiPBDlNnq3ceYmnscIzfAtcFb1i78gUuv/4SN918Dn4D285Ww8f5rXHr9x6xd+D14C66NkTZTc49Tvfs4KAfI/KFyM+tm2+lEQISnVHmsUJ1h6oHHcuMd8Clpp8HW0gLeJjQun8H1G+D74Pu4XoPG5TN4m7C1tEDaaYBPwXUyEEceo1CdQZVHRXhKJLO5A0AVVKkCTxsThBOHTxAPBZC2wFnwFtupYzt1MGDba6TdzR0AaXcT217LdJ06trOZs2AhbREPBkwcfgQTBCHwtCpV1ZsASObM86ocGRqbojw5C0kD0vwQl6C2i3oHgDqL2ja4Prg+attolgNQ71DbA5fkACzYBuXJWYZGp1DliAjzkruPeesUiAGB40BhZPIOwsBD2s0PSCDtYwRMFgaYIMag4LrguhgUE8SZzoQYAdL+LgjbJQw8I5MHAQrAcTHw1ikwCDhLjHLUBAHF8j6wbbAJ2Oz2pH2iMGagWEE9DAyPE4ZBBjLtEoYhA8Pjma5YIQrjDECa5AwkkLYpjk5iggCUo84SIxDm9JeAWhDGxAMFsN0sxnNqECWQmPHa/dhei/HaHEY92F52a4Hx2hz9G+uM1x4gEMD2d3OEWnCOOC4QhDGp69YkK2abYf4WgyglY0ICBJJ+5plGdgAgnsrEXYyMzhAOjkDSvSmNKKPjsww//BRhPABJLzee7gJACIgwJkTZraThR5Jz6gC7A8DaHqtX3qNUqVEenyUKoozenRQigCJorrM0Ny7Tqi8zWbuPKAyyiBCB1HzEXJiHQ0+g5Z3F9fugHnyKdX2uXD7Pja11yuXpjBkkexrMHgZAs314jHPUr10i6TaZmZ0jCgyYEJf08c4i0FLo7QJQWhKw7FL7YNJuUZAiOMvqhxepry1RHp2iOFjOqMXcBOBm8RlreIqDZYYKZeprS8RBzO3774EwImm3cKkFYVkdLSQ/JYhIgEXvHe3mKrgIkpTyUIXpfYfodrZobixBYiFJoJ9kbOxZyc5vc2OJbmeL6X2HKQ9Vsn1pRLu5is9yyWJuE/PQcxlzqpwFOte3rpAmCqlQisvsG72D0eIkKyvn2dpcRvvJLohb/ms/YWtzmZWV84wOT7JvbJZSXIbUkCbK9a0rAB1VzqqHh57LnTD3gwURzne7m8eazWtUC+PQryMmYP/oQbyzLK38hbHSNJXSNINxCWOyau69o5e0qLeu0mhdpVy4jf3lg0jispowUKXZ/JBudxMRzquysJ2Kd6LAGDZVecV7P7+2fiEsTX+JWAeh3yGUgJnyPRTDEdZvrNBoXSUMBojy7GddQur6RCZm/8hBKsUpglSyEAwLJCmsrV/Ae5+K8IoxbHp/Sz/w9mkAKiL8EvjKePkQM5WjmO5GlvNNAGKwztK21+nYFtb1AYiCAQpRiWI8QmSi/E0dmEH8UJUr9UU2mv8A+JMq3wTq2/3AnjwgQl2VH4lweLN5cTZkgKnSvRjXgH4HRIgwjJoxRgcqe6MQhVTzBKQQFfDhGNfqf2ezeRFgCXght7G3H4CsQ1GF+a9xDviB4ldXm++y3FgkCYYhqoILsvqQfIwjJknm7S6AqEoSDLO8tchq810Uvwp8/3PPck79bje05wm2ZeGlrCkVyZtSODAUVZko3stoNEno3G6lVJefEkAQQThEGgRs2VXW2u/RtZvbN39eNWtKb+2MP1lbDo8aTDQUjTEST1OMqsSmQJC/oCMl8V3adoPryVW6toHHW+EztOXbcvYURAGoMibCk8AzSj6YYDASEUgOQFO8WjweoCPwDvCyKq+K0LCfdjC5Wd54EZYbcNdtVIB5EU4AR4FaXtUQaAHLwOLOaLZGvVb5D0azj5O3T2eDRAqxsHc4VWiFkDj2Otn/vfwbQ7zll8LfpQgAAAAldEVYdGRhdGU6Y3JlYXRlADIwMTctMDctMTZUMDk6NTg6MjgrMDI6MDC/fy+sAAAAJXRFWHRkYXRlOm1vZGlmeQAyMDE3LTA3LTE2VDA5OjU4OjI4KzAyOjAwziKXEAAAAABJRU5ErkJggg==",
				verification_level:0,
				default_message_notifications:0,
				roles:[],
				channels:[]
			},function(g,e){
				if(e!=null)return trace(e);
				g.createChannel({name:"test",type:"text"},function(c,e){
					if(e!=null)return trace(e);
					c.createInvite({},function(i,e){
						if(e!=null)return trace(e);
						discordBot.sendMessage("208306835638321152",{content:"Join discord.gg/"+i.code});
					});
					c.createInvite({},function(i,e){
						if(e!=null)return trace(e);
						discordBot.sendMessage("120308435639074816",{content:"Join discord.gg/"+i.code});
					});
				});
				g.createChannel({name:"test2",type:"text"},function(c,e){});
				g.createChannel({name:"test3",type:"voice"},function(c,e){});

				g.createRole({name:"Role test",permissions:0x8},function(r,e){});

				g.changeNickname("Cool Guy Owner Thing");
			});
		});
}catch(v:Dynamic){
	trace(v);
}
	}

	public static function onMemberJoin(g:Guild,m:GuildMember){
		var ri = g.roles.iterator();
		if(ri.hasNext()){
			var r = ri.next();
			
			if(r.id.equals(g.id))r = ri.next();
			trace("adding "+r.name);
			m.addRole(r.id.id,function(r,e){trace(r,e);});
		}
		g.changeNickname("GuyJoined",m);
		discordBot.sendMessage(g.id.id,{content:"Welcome "+m.user.username});
	}
}