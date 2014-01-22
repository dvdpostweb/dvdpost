$(function() {
function showDebugInfo() {
	var properties = [
			'isProvisioned', 'getClientId', 'getState', 'getStateName', 'getPlaybackPercentage',
			'getVerimatrixStatusCode', 'getVerimatrixStatusName', 'getContentLength', 'getPosition',
			'getPlaybackPercentage', 'getLastResponseCode', 'getLastResponseName', 'isMuted', 'isFullscreen',
			'isMediaSeekable', 'isMediaSecure', 'getVolume', 'getBalance', 'getLastOpenedUrl', 'getSDKVersion',
			'getAspectRatio', 'isUsingHardwareDeinterlacing', 'getClientStatus', 'getQualityMetrics'
		],
		value,
		html = '<ul>',
		i;

	for (i = 0; i < properties.length; i++) {
		value = player[properties[i]].call(player);

		if (value !== null && typeof(value) === 'object') {
			value = JSON.stringify(value);
		}

		html += '<li><strong>' + properties[i] + ':</strong> ' + value + '</li>';
	}

	html += '</ul>';

	$('#debug-info').html(html);
}

var player = new ViewRightPlayer();

player.log = function() {
	$('#log')
		.append('<div class="log-info">' + arguments[0] + '</div>')
		.scrollTop($('#log')[0].scrollHeight);
};

player.error = function() {
	$('#log')
		.append('<div class="log-error">' + arguments[0] + '</div>')
		.scrollTop($('#log')[0].scrollHeight);
};

player.onPositionChanged = function() {
	$('#playback-indicator > DIV > DIV').width(player.getPlaybackPercentage() + '%');
};

return_res = player.init('#player');
if(return_res != false){
if (!player.isProvisioned()) {
	window.location.href = 'http://hls.estpak.ee/vm/order.php?id=' + player.getClientId();
}

/*var actions = {
		'#play-nasa-btn': function() {
			player.open('http://www.nasa.gov/multimedia/nasatv/NTV-Public-IPS.m3u8');
		},
		'#play-nature-btn': function() {
			player.open('http://mediamotiononline.ios.internapcdn.net/mediamotiononline/inapcms/CMS16042/flash/16042_adaptive2.mp4.m3u8');
		},
		'#play-apple-btn': function() {
			player.open('http://qthttp.apple.com.edgesuite.net/1010qwoeiuryfg/sl.m3u8');
		},
		'#play-bipbop-btn': function() {
			player.open('http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8');
		},
    '#playback-indicator > DIV, #playback-indicator > DIV > DIV': function(e) {
      var containerWidth = $('#playback-indicator').width(),
          clickPos = (e.offsetX==undefined)?e.pageX-$('#playback-indicator').offset().left:e.offsetX,
          percentage = clickPos * 100.0 / containerWidth;
      if (percentage >= 0 && percentage <=100)
      {
      player.setPlaybackPercentage(percentage);
      }
    },
		'#resume-btn': function() {
			player.resume();
		},
		'#pause-btn': function() {
			player.pause();
		},
		'#stop-btn': function() {
			player.stop();
		},
		'#mute-btn': function() {
			player.mute();
		},
		/*'#unmute-btn': function() {
			player.unmute();
		},
		'#toggle-mute-btn': function() {
			player.toggleMute();
		},
		'#rewind-btn': function() {
			player.rewind();
		},
		'#fast-forward-btn': function() {
			player.fastForward();
		},
		'#set-position-btn': function() {
			player.setPosition(player.getContentLength() / 2);
		},
		'#set-volume-btn': function() {
			player.setVolume(50);
		},
		'#enable-fullscreen-btn': function() {
			player.enableFullscreen();
		},
		'#disable-fullscreen-btn': function() {
			player.disableFullscreen();
		},
		'#enable-hardware-interlacing-btn': function() {
			player.enableHardwareInterlacing();
		},
		'#disable-hardware-interlacing-btn': function() {
			player.disableHardwareInterlacing();
		},
		'#abort-operation-btn': function() {
			player.abortOperation();
		},
		'#destroy-btn': function() {
			player.destroy();
		},
		'#debug-btn': function() {
			showDebugInfo();
		}
	},
	selector;

for (selector in actions) {
	$(selector).click(function() {
		this.action.apply(this.action, arguments);
	}.bind({ action: actions[selector] }));
}*/
window.setInterval(showDebugInfo, 100);
}
$('#resume-btn').live("click", function() {
	player.resume();
})
$('#pause-btn').live("click", function() {
	player.pause();
})
$('#enable-fullscreen-btn').live("click", function() {
	player.enableFullscreen();
})
})