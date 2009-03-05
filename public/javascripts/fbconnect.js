


//   54950597511   posted a request
//   54950687511   posted an offer
//   54955797511   joined cec
//   54965487511   marble action




fb_show_dialog = function(type,data)
{
  	FB.Connect.requireSession(function(){

        if(type=="request") bundle_id = 54950597511
        if(type=="offer") bundle_id = 54950687511
        if(type=="join") bundle_id = 54955797511
        if(type=="marbles") bundle_id = 54965487511
        
        FB.Connect.showFeedDialog(bundle_id,data,null,null,null,FB.RequireConnect.promptConnect)
	})    
}
fb_post = function(type,data)
{
    console.log("fb_post: "+type)
    if (typeof(data)=='undefined') data = {}
    
    FB.ensureInit(function(){
	  	FB.Facebook.init('5a92e10fce76d5e880e9b09504ff7fd5', '/sessions/connect',
	  	  {"ifUserConnected":fb_show_dialog(type,data)} );
	})

}
fb_request = function(){fb_post("request")}
fb_offer = function(){fb_post("offer")}
fb_join = function(){fb_post("join")}
fb_marbles = function(action){fb_post("marbles",{"action":action})}


userIsConnected = function(){ if( fb=$('fb_status') ) fb.replace("| <img style='vertical-align:text-bottom' src='http://static.ak.fbcdn.net/images/fbconnect/login-buttons/connect_light_small_short.gif' alt='Facebook'/>") }
userNotConnected = function(){ if( fb=$('fb_status') ) fb.insert("<a style='display:block' onclick='FB.Connect.requireSession();return false;'><img id='fb_login_image' src='http://static.ak.fbcdn.net/images/fbconnect/login-buttons/connect_light_medium_short.gif' alt='Connect'/></a>") }
fb_setup = function()
{
    FB_RequireFeatures(["XFBML"], function(){
        FB.Facebook.init('5a92e10fce76d5e880e9b09504ff7fd5', '/sessions/connect',
           {"ifUserConnected":userIsConnected,"ifUserNotConnected":userNotConnected}
         );
    })
}



fb_logout = function()
{
  	FB.Connect.requireSession(function(){        
        FB.Connect.logoutAndRedirect("/")
	})    
}


