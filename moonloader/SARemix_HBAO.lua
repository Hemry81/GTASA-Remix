script_name("SARemix_HBAO")
script_author("Hemry")
script_url("https://github.com/Hemry81/GTASA-Remix")
script_version("0.1.0")
local mad = require 'MoonAdditions'
local HBAO_firstStart = true
local HBAO_showtext = true
local HBAO_timer = 0

function main()
	wait(3000)
	while true do
		wait(0)
		if isPlayerPlaying(PLAYER_HANDLE) then
			if not isCharDead(PLAYER_PED) then
				if HBAO_firstStart then
					HBAO_timer = os.clock()
					HBAO_firstStart = false
				else
					if os.clock() - HBAO_timer > 15 then
						HBAO_showtext = false
						--mad.draw_text(string.format("elapsed time: %.2f\n", os.clock() - HBAO_timer), 10, 50, mad.font_style.MENU, 0.4, 0.9, mad.font_align.LEFT, 640, true, false, 255, 255, 255, 255, 0, 1)
					end
				end
				if HBAO_showtext then
					mad.draw_text('SA REMIX HEALTH BAR ALWAYS ON STARTED', 300, 60, mad.font_style.MENU, 0.4, 0.9, mad.font_align.LEFT, 1000, true, false, 255, 255, 255, 255, 0, 1)
                else
                    mad.draw_text('.', -10, -10, mad.font_style.MENU, 0.4, 0.9, mad.font_align.LEFT, 640, false, false, 255, 255, 255, 255, 0, 1)
                end
			end
		end
	end
end